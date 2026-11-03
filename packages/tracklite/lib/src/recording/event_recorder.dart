import 'dart:async';
import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/recording/event_validator.dart';
import 'package:tracklite/src/storage/event_mapper.dart';
import 'package:tracklite/src/storage/meta_keys.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';

/// One change waiting for the database, in call order.
@internal
sealed class PendingWrite {
  const PendingWrite();
}

@internal
final class InsertEvent extends PendingWrite {
  const InsertEvent(this.row);

  final EventsCompanion row;
}

/// Sets a `meta` value, or removes it when [value] is `null`.
@internal
final class SetMeta extends PendingWrite {
  const SetMeta(this.name, this.value);

  final String name;
  final String? value;
}

@internal
final class AddToCounter extends PendingWrite {
  const AddToCounter(this.name, this.by);

  final String name;
  final int by;
}

/// Turns `track()` calls into stored events.
///
/// [record] is synchronous: it validates, stamps the event (id, time, the
/// identity *now*) and queues it, then returns. The host never waits for
/// the disk. Every queued change is written in call order by one drain at a
/// time, and a drain writes everything queued so far in **one
/// transaction**: a burst of 100 `track()` calls in one frame is one
/// commit, not 100. Identity changes go through the same queue, so an
/// event and a `setUserId` after it are stored in the order they were made.
@internal
final class EventRecorder {
  EventRecorder({
    required this._database,
    required this.maxQueueSize,
    required this._logger,
    required this._newId,
    Clock? clock,
  }) : _clock = clock ?? const Clock();

  final TrackLiteDatabase _database;
  final int maxQueueSize;
  final TrackLiteLogger _logger;
  final String Function() _newId;
  final Clock _clock;

  /// Told how many events each drain stored (the scheduler's threshold).
  void Function(int stored)? onStored;

  final Queue<PendingWrite> _queue = Queue();
  Completer<void>? _drained;
  bool _closed = false;

  /// Validates and queues one event, tracked at [at] (now, unless it was
  /// buffered before the SDK started), for [userId] and [anonymousId].
  void record(
    String name,
    Map<String, Object> properties, {
    required String? userId,
    required String anonymousId,
    DateTime? at,
  }) {
    switch (validateEvent(name, properties)) {
      case Rejected(:final reason):
        _logger.warning('track("$name") rejected: $reason');
        enqueue(const AddToCounter(MetaKeys.rejectedTotal, 1));
      case Valid(:final name):
        enqueue(
          InsertEvent(
            EventsCompanion.insert(
              id: _newId(),
              name: name,
              timestamp: (at ?? _clock.now()).toUtc(),
              userId: Value(userId),
              anonymousId: anonymousId,
              properties: encodeProperties(properties),
              status: 'pending',
            ),
          ),
        );
        _logger.debug('track("$name", $properties) queued');
    }
  }

  /// Queues [write] behind everything queued before it.
  void enqueue(PendingWrite write) {
    if (_closed) return;
    _queue.add(write);
    if (_drained == null) {
      _drained = Completer<void>();
      // A microtask, not now: the calls made in the same frame join the
      // queue first, and go into the same transaction.
      scheduleMicrotask(_drain);
    }
  }

  /// Completes once everything queued so far is stored.
  Future<void> get idle => _drained?.future ?? Future.value();

  /// Whether nothing is waiting to be stored, right now.
  bool get isIdle => _drained == null;

  /// Stores what is queued, then refuses new writes.
  Future<void> close() async {
    await idle;
    _closed = true;
  }

  Future<void> _drain() async {
    while (_queue.isNotEmpty) {
      final batch = List.of(_queue);
      _queue.clear();
      try {
        await _database.transaction(() => _apply(batch));
        final stored = batch.whereType<InsertEvent>().length;
        if (stored > 0) onStored?.call(stored);
      } on Object catch (error, stackTrace) {
        // A full disk or a broken file: the batch can't be stored. It is
        // logged, and the SDK carries on rather than fail the host.
        _logger.error(
          'storing ${batch.length} queued writes failed',
          error,
          stackTrace,
        );
      }
    }
    final drained = _drained!;
    _drained = null;
    drained.complete();
  }

  Future<void> _apply(List<PendingWrite> batch) async {
    final rows = [
      for (final write in batch)
        if (write case InsertEvent(:final row)) row,
    ];
    final events = _database.eventDao;
    final meta = _database.metaDao;
    for (final write in batch) {
      switch (write) {
        case InsertEvent():
          break; // inserted together below, in order
        case SetMeta(:final name, value: final value?):
          await meta.write(name, value);
        case SetMeta(:final name):
          await meta.remove(name);
        case AddToCounter(:final name, :final by):
          await meta.increment(name, by);
      }
    }
    if (rows.isEmpty) return;
    await events.insertAll(rows);
    await meta.increment(MetaKeys.trackedTotal, rows.length);

    // The queue is bounded: past the limit, the oldest unsent events go,
    // counted, in the same transaction. Without a limit, a device offline
    // for weeks would fill its disk with analytics.
    final over = await events.unsentCount() - maxQueueSize;
    if (over > 0) {
      final dropped = await events.dropOldestUnsent(over);
      await meta.increment(MetaKeys.droppedTotal, dropped);
      _logger.warning('queue full: dropped the $dropped oldest unsent events');
    }
  }
}
