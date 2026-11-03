import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/scheduling/app_lifecycle.dart';

// No binding in this file on purpose (a `testWidgets` anywhere in it would
// create one as soon as it is declared): a host that calls `initialize`
// before `WidgetsFlutterBinding.ensureInitialized()` must get a warning,
// not an exception. Flutter's own lifecycle is tested next door.
void main() {
  test(
    'without a widgets binding: always in the foreground, with a warning',
    () {
      final warnings = <String>[];

      final lifecycle = createAppLifecycle(warnings.add);

      expect(lifecycle, isA<ForegroundOnly>());
      expect(lifecycle.isForeground, isTrue);
      expect(warnings.single, startsWith('no widgets binding yet'));
    },
  );
}
