import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/scheduling/upload_scheduler.dart';
import 'package:tracklite/src/upload/upload_manager.dart';
import 'package:tracklite/testing.dart';
import 'package:tracklite/tracklite.dart';

import '../helpers/fakes.dart';
import '../helpers/sdk.dart';

// The scheduler on its own, in fake time: every trigger, and every reason
// not to fire. The uploads it asks for are recorded, not run.
void main() {
  late List<UploadTrigger> uploads;
  late FakeNetworkMonitor monitor;
  late FakeAppLifecycle lifecycle;
  late int due;
  late DateTime? nextRetry;
  late bool paused;

  setUp(() {
    uploads = [];
    monitor = FakeNetworkMonitor();
    lifecycle = FakeAppLifecycle();
    due = 0;
    nextRetry = null;
    paused = false;
  });

  UploadScheduler scheduler(FakeAsync async) => UploadScheduler(
    upload: (trigger) async {
      uploads.add(trigger);
      return const NothingToSend();
    },
    dueCount: () async => due,
    nextRetryAt: () async => nextRetry,
    monitor: monitor,
    lifecycle: lifecycle,
    interval: const Duration(seconds: 30),
    threshold: 20,
    paused: () => paused,
    logger: LogRecorder().logger(),
    clock: async.getClock(testNow),
  );

  void run(void Function(FakeAsync async, UploadScheduler scheduler) body) =>
      fakeAsync((async) {
        final s = scheduler(async)..start();
        body(async, s);
        s.stop();
        async.flushMicrotasks();
      });

  test('interval: every 30 s in the foreground', () {
    run((async, _) {
      async.elapse(const Duration(seconds: 29));
      expect(uploads, isEmpty);
      async.elapse(const Duration(seconds: 61));
      expect(uploads, [
        UploadTrigger.interval,
        UploadTrigger.interval,
        UploadTrigger.interval,
      ]);
    });
  });

  test(
    'paused: uploads once going to the background, then the timers stop',
    () {
      run((async, _) {
        lifecycle.foreground = false;
        async.flushMicrotasks();
        expect(uploads, [UploadTrigger.paused]);

        async.elapse(const Duration(minutes: 5));
        expect(uploads, [
          UploadTrigger.paused,
        ], reason: 'no interval in the background');

        lifecycle.foreground = true;
        async.elapse(const Duration(seconds: 30));
        expect(uploads.last, UploadTrigger.interval);
      });
    },
  );

  test(
    'reconnect: offline → online uploads; the first value is not a change',
    () {
      run((async, _) {
        async.flushMicrotasks();
        expect(uploads, isEmpty);

        monitor.online = false;
        async.flushMicrotasks();
        monitor.online = true;
        async.flushMicrotasks();

        expect(uploads, [UploadTrigger.reconnect]);
      });
    },
  );

  test('threshold: a write that leaves a full batch due', () {
    run((async, s) {
      due = 19;
      s.stored(19);
      async.flushMicrotasks();
      expect(uploads, isEmpty);

      due = 20;
      s.stored(1);
      async.flushMicrotasks();
      expect(uploads, [UploadTrigger.threshold]);

      s.stored(0);
      async.flushMicrotasks();
      expect(uploads, hasLength(1), reason: 'nothing stored, nothing checked');
    });
  });

  test('retryDue: one timer, for the earliest retry, re-armed after a run', () {
    run((async, s) {
      nextRetry = testNow.add(const Duration(seconds: 10));
      // A run re-arms the timer (here: the threshold's).
      due = 20;
      s.stored(20);
      async.flushMicrotasks();
      expect(uploads, [UploadTrigger.threshold]);

      nextRetry = null;
      async.elapse(const Duration(seconds: 10));
      expect(uploads, [UploadTrigger.threshold, UploadTrigger.retryDue]);

      async.elapse(const Duration(seconds: 15));
      expect(uploads.where((t) => t == UploadTrigger.retryDue), hasLength(1));
    });
  });

  test('a retry time already past arms nothing: the interval sends it (an '
      'unreachable server keeps the old time, and "at once" would loop)', () {
    run((async, _) {
      nextRetry = testNow.subtract(const Duration(minutes: 1));
      async.elapse(const Duration(seconds: 29));
      expect(uploads, isEmpty);

      async.elapse(const Duration(seconds: 31));
      expect(uploads, [UploadTrigger.interval, UploadTrigger.interval]);
    });
  });

  test('offline: no trigger asks for an upload', () {
    run((async, s) {
      monitor.online = false;
      due = 50;
      s.stored(50);
      lifecycle.foreground = false;
      lifecycle.foreground = true;
      async.elapse(const Duration(minutes: 2));

      expect(uploads, isEmpty);
    });
  });

  test('a rejected API key: no automatic upload', () {
    run((async, s) {
      paused = true;
      due = 50;
      s.stored(50);
      monitor.online = false;
      monitor.online = true;
      async.elapse(const Duration(minutes: 2));

      expect(uploads, isEmpty);
    });
  });

  test('stop: no timer and no listener left', () {
    fakeAsync((async) {
      final s = scheduler(async)..start();
      s.stop();
      async.flushMicrotasks();

      async.elapse(const Duration(minutes: 5));
      monitor.online = false;
      monitor.online = true;
      async.flushMicrotasks();

      expect(uploads, isEmpty);
      expect(async.pendingTimers, isEmpty);
      expect(monitor.hasListener, isFalse);
    });
  });

  test('started in the background: no timers until it comes back', () {
    fakeAsync((async) {
      lifecycle.foreground = false;
      final s = scheduler(async)..start();
      async.elapse(const Duration(minutes: 2));
      expect(uploads, isEmpty);

      lifecycle.foreground = true;
      async.elapse(const Duration(seconds: 30));
      expect(uploads, [UploadTrigger.interval]);
      s.stop();
      async.flushMicrotasks();
    });
  });

  test('TrackLiteTesting.disableTimers: no interval or retry timer, the '
      'event triggers still work', () {
    TrackLiteTesting.disableTimers();
    addTearDown(TrackLiteTesting.enableTimers);
    fakeAsync((async) {
      nextRetry = testNow.add(const Duration(seconds: 5));
      final s = scheduler(async)..start();
      async.flushMicrotasks();
      expect(async.pendingTimers, isEmpty);

      monitor.online = false;
      monitor.online = true;
      async.flushMicrotasks();
      expect(uploads, [UploadTrigger.reconnect]);
      expect(async.pendingTimers, isEmpty);
      s.stop();
      async.flushMicrotasks();
    });
  });
}
