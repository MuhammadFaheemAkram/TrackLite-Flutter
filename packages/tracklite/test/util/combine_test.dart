import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/util/combine.dart';

void main() {
  test('emits once all have a value, then on every change', () async {
    final a = StreamController<int>();
    final b = StreamController<String>();
    final c = StreamController<bool>();
    final seen = <String>[];
    final subscription = combineLatest3(
      () => a.stream,
      () => b.stream,
      () => c.stream,
      (x, y, z) => '$x$y$z',
    ).listen(seen.add);

    a.add(1);
    b.add('x');
    await pumpEventQueue();
    expect(seen, isEmpty);

    c.add(true);
    a.add(2);
    c.add(false);
    await pumpEventQueue();
    expect(seen, ['1xtrue', '2xtrue', '2xfalse']);

    await subscription.cancel();
    expect(a.hasListener || b.hasListener || c.hasListener, isFalse);
    await Future.wait([a.close(), b.close(), c.close()]);
  });

  test('each listener gets streams of its own', () async {
    var built = 0;
    Stream<int> one() {
      built++;
      return Stream.value(built);
    }

    final combined = combineLatest3(one, one, one, (x, y, z) => [x, y, z]);

    expect(await combined.first, [1, 2, 3]);
    expect(await combined.first, [4, 5, 6]);
  });
}
