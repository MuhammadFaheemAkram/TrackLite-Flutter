import 'dart:async';

import 'package:tracklite/tracklite.dart';

/// A transport that answers each upload with the next scripted outcome (an
/// exception, or a success), and remembers every batch it got. Past the
/// script, it succeeds.
class ScriptedTransport implements AnalyticsTransport {
  ScriptedTransport([List<Object> script = const []])
    : _script = List.of(script);

  final List<Object> _script;
  final List<UploadBatch> batches = [];

  /// Holds each upload until the test completes it (to see a run in
  /// flight).
  Completer<void>? gate;

  void then(Object outcome) => _script.add(outcome);

  /// The ids of every event sent, in order (duplicates included).
  List<String> get sentIds => [
    for (final batch in batches) ...batch.events.map((e) => e.id),
  ];

  @override
  Future<UploadResponse> upload(UploadBatch batch) async {
    batches.add(batch);
    if (gate case final gate?) await gate.future;
    if (_script.isNotEmpty) {
      final outcome = _script.removeAt(0);
      if (outcome is UploadResponse) return outcome;
      throw outcome;
    }
    return UploadResponse(accepted: batch.events.length);
  }
}
