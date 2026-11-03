import 'dart:async';

import 'package:meta/meta.dart';

/// The latest value of each of three streams, combined by [combine], each
/// time any of them changes (once all three have a value). The streams are
/// built by [a], [b] and [c] for each listener.
///
/// The SDK's own small `combineLatest`: a stream package would become every
/// host's dependency for one function. Each listener gets subscriptions of
/// its own (`Stream.multi`), so the result can be listened to more than
/// once, like the drift streams it combines.
@internal
Stream<R> combineLatest3<A, B, C, R>(
  Stream<A> Function() a,
  Stream<B> Function() b,
  Stream<C> Function() c,
  R Function(A a, B b, C c) combine,
) => Stream<R>.multi((out) {
  A? lastA;
  B? lastB;
  C? lastC;
  var hasA = false;
  var hasB = false;
  var hasC = false;

  void emit() {
    if (hasA && hasB && hasC) {
      out.add(combine(lastA as A, lastB as B, lastC as C));
    }
  }

  final subscriptions = [
    a().listen((value) {
      lastA = value;
      hasA = true;
      emit();
    }, onError: out.addError),
    b().listen((value) {
      lastB = value;
      hasB = true;
      emit();
    }, onError: out.addError),
    c().listen((value) {
      lastC = value;
      hasC = true;
      emit();
    }, onError: out.addError),
  ];
  out.onCancel = () => Future.wait([for (final s in subscriptions) s.cancel()]);
});
