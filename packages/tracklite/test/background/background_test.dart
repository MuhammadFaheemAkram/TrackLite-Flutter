import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/background/background_runner.dart';
import 'package:tracklite/src/background/saved_config.dart';
import 'package:tracklite/src/recording/event_recorder.dart';
import 'package:tracklite/src/storage/meta_keys.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/src/upload/upload_manager.dart';
import 'package:tracklite/testing.dart';
import 'package:tracklite/tracklite.dart';

import '../helpers/fakes.dart';
import '../helpers/scripted_transport.dart';
import '../helpers/sdk.dart';

void main() {
  group('the saved config', () {
    test('round-trips what an upload needs; background uploads are off', () {
      const config = TrackLiteConfig(
        apiKey: 'demo_key',
        batchSize: 50,
        maxRetries: 3,
        maxQueueSize: 500,
        retry: RetryPolicy(base: Duration(seconds: 30)),
        debugMode: true,
      );

      final back = decodeConfig(encodeConfig(config));

      expect(back.apiKey, 'demo_key');
      expect(back.batchSize, 50);
      expect(back.maxRetries, 3);
      expect(back.maxQueueSize, 500);
      expect(back.retry, const RetryPolicy(base: Duration(seconds: 30)));
      expect(back.debugMode, isTrue);
      expect(back.backgroundUploads, isFalse);
    });

    test('withObjects adds the transport and monitor it couldn\'t save', () {
      final server = instantServer();
      final monitor = FakeNetworkMonitor();

      final config = const TrackLiteConfig(apiKey: 'k')
          .withObjects(transport: server, networkMonitor: monitor);

      expect(config.transport, same(server));
      expect(config.networkMonitor, same(monitor));
    });

    test('initialize saves it, for the background task to read', () async {
      final db = TrackLiteDatabase.inMemory();
      final client = await openTestClient(database: db);
      await client.idle;

      final saved = await db.metaDao.read(MetaKeys.backgroundConfig);
      expect(decodeConfig(saved!).apiKey, 'demo_key');
      await client.shutdown();
    });
  });

  group('runBackgroundUpload', () {
    late Directory dir;
    late File file;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('tracklite');
      file = File('${dir.path}/tracklite.sqlite');
    });
    tearDown(() => dir.deleteSync(recursive: true));

    TrackLiteDatabase openFile() => TrackLiteDatabase(NativeDatabase(file));

    Future<void> foreground(void Function(TrackLiteClientImplTrack) use) async {
      final client = await openTestClient(database: openFile());
      use(client.track);
      await client.idle;
      await client.shutdown();
    }

    test('an app that never initialized: nothing to do', () async {
      final result = await runBackgroundUpload(openDatabase: openFile);

      expect(result, isA<NothingToSend>());
    });

    test(
      'reads the saved config and uploads what is due, then closes',
      () async {
        await foreground((track) => track('tap'));
        final server = instantServer();

        final result = await runBackgroundUpload(
          openDatabase: openFile,
          transport: server,
          networkMonitor: FakeNetworkMonitor(),
        );

        expect(result, isA<Uploaded>().having((r) => r.events, 'events', 1));
        expect(server.stats.accepted, 1);
        final db = openFile();
        addTearDown(db.close);
        final runs = await db.uploadDao.newest();
        expect(runs.single.trigger, 'background');
        expect((await db.eventDao.all()).single.status, 'sent');
      },
    );

    test('respects backoff: a retry still waiting stays', () async {
      await foreground((track) => track('tap'));
      final db = openFile();
      await db.customStatement(
        "UPDATE events SET next_attempt_at = '2999-01-01T00:00:00.000Z'",
      );
      await db.close();
      final server = instantServer();

      final result = await runBackgroundUpload(
        openDatabase: openFile,
        transport: server,
        networkMonitor: FakeNetworkMonitor(),
      );

      expect(result, isA<NothingToSend>());
      expect(server.stats.requests, 0);
    });

    test('offline: nothing attempted', () async {
      await foreground((track) => track('tap'));

      final result = await runBackgroundUpload(
        openDatabase: openFile,
        transport: instantServer(),
        networkMonitor: FakeNetworkMonitor(online: false),
      );

      expect(result, isA<Offline>());
    });

    test('a saved config it can\'t read: Failed, nothing thrown', () async {
      final db = openFile();
      await db.metaDao.write(MetaKeys.backgroundConfig, '{not json');
      await db.close();

      final result = await runBackgroundUpload(openDatabase: openFile);

      expect(
        result,
        isA<Failed>().having((r) => r.reason, 'reason', contains('Format')),
      );
    });

    test('a database that won\'t open: Failed, nothing thrown', () async {
      final result = await runBackgroundUpload(
        openDatabase: () => TrackLiteDatabase(
          NativeDatabase.memory(setup: (_) => throw StateError('disk full')),
        ),
      );

      expect(result, isA<Failed>());
    });
  });

  test('two uploaders on one database never send the same event', () async {
    // The app and the background task, at the same time: each claims its
    // batches in one statement, so each event goes out exactly once.
    final dir = Directory.systemTemp.createTempSync('tracklite');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/tracklite.sqlite');
    final first = TrackLiteDatabase(NativeDatabase(file));
    final second = TrackLiteDatabase(NativeDatabase(file));
    addTearDown(first.close);
    addTearDown(second.close);
    final recorder = EventRecorder(
      database: first,
      maxQueueSize: 10000,
      logger: LogRecorder().logger(),
      newId: SequentialIds().call,
    );
    for (var i = 0; i < 100; i++) {
      recorder.record('tap', {'n': i}, userId: null, anonymousId: 'a');
    }
    await recorder.idle;

    final a = ScriptedTransport();
    final b = ScriptedTransport();
    UploadManager uploader(
      TrackLiteDatabase db,
      ScriptedTransport t,
      String id,
    ) {
      final ids = SequentialIds();
      return UploadManager(
        database: db,
        recorder: recorder,
        transport: t,
        monitor: FakeNetworkMonitor(),
        apiKey: 'k',
        batchSize: 10,
        maxRetries: 5,
        retry: const RetryPolicy(),
        logger: LogRecorder().logger(),
        // Each uploader's claim tokens are its own.
        newId: () => '$id-${ids()}',
      );
    }

    final managerA = uploader(first, a, 'app');
    final managerB = uploader(second, b, 'background');

    await Future.wait([
      managerA.upload(UploadTrigger.manual),
      managerB.upload(UploadTrigger.background),
    ]);

    final sent = [...a.sentIds, ...b.sentIds];
    expect(sent, hasLength(100));
    expect(sent.toSet(), hasLength(100));
  });

  group('the client schedules background uploads', () {
    test('enabled by the config: registered', () async {
      final background = FakeBackgroundUploads();
      final client = await openTestClient(
        config: testConfig().withBackground(enabled: true),
        background: background,
      );
      addTearDown(client.shutdown);
      await pumpEventQueue();

      expect(background.calls, ['enable']);
    });

    test('disabled: cancelled (a host with its own dispatcher)', () async {
      final background = FakeBackgroundUploads();
      final client = await openTestClient(background: background);
      addTearDown(client.shutdown);
      await pumpEventQueue();

      expect(background.calls, ['disable']);
    });

    test('a platform that can\'t: logged, the client works', () async {
      final logs = LogRecorder();
      final background = FakeBackgroundUploads()
        ..error = StateError('no plugin');
      final client = await openTestClient(
        config: testConfig().withBackground(enabled: true),
        background: background,
        logs: logs,
      );
      addTearDown(client.shutdown);
      await pumpEventQueue();

      expect(
        logs.lines.map((l) => l.$2),
        contains('scheduling background uploads failed: Bad state: no plugin'),
      );
      client.track('still_works');
      expect(await client.flush(), isA<Uploaded>());
    });
  });
}

typedef TrackLiteClientImplTrack = void Function(
  String name, {
  Map<String, Object> properties,
});

extension on TrackLiteConfig {
  TrackLiteConfig withBackground({required bool enabled}) => TrackLiteConfig(
    apiKey: apiKey,
    batchSize: batchSize,
    maxRetries: maxRetries,
    maxQueueSize: maxQueueSize,
    backgroundUploads: enabled,
    debugMode: debugMode,
    transport: transport,
    networkMonitor: networkMonitor,
  );
}
