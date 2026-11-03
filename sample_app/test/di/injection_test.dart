import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/testing.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/app/analytics_config.dart';
import 'package:tracklite_sample/data/analytics/demo_network_monitor.dart';
import 'package:tracklite_sample/data/analytics/fake_server_demo.dart';
import 'package:tracklite_sample/data/analytics/tracklite_analytics_debug.dart';
import 'package:tracklite_sample/data/analytics/tracklite_analytics_service.dart';
import 'package:tracklite_sample/di/injection.dart';
import 'package:tracklite_sample/domain/analytics/analytics_debug.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/domain/demo/demo_backend.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:tracklite_sample/features/home/cubit/home_cubit.dart';
import 'package:tracklite_sample/features/product/cubit/product_cubit.dart';
import 'package:tracklite_sample/features/profile/cubit/profile_cubit.dart';

import '../helpers/app_harness.dart';

void main() {
  tearDown(tearDownSample);

  test('the graph builds once the SDK has started, as in main()', () async {
    await startSdk();

    expect(getIt<TrackLiteClient>(), same(TrackLite.instance));
    expect(getIt<AnalyticsService>(), isA<TrackLiteAnalyticsService>());
    expect(getIt<HomeCubit>(), isNot(same(getIt<HomeCubit>())));
    expect(getIt<DashboardCubit>(), isA<DashboardCubit>());
    expect(getIt<ProfileCubit>(), isA<ProfileCubit>());
    expect(getIt<AnalyticsDebug>(), isA<TrackLiteAnalyticsDebug>());
    expect(getIt<DemoBackend>(), isA<FakeServerDemo>());
    expect(
      getIt<ProductCubit>(param1: 'grinder').state.product?.name,
      'Hand grinder',
    );
  });

  test('the sample configures the SDK with a valid config', () {
    final monitor = DemoNetworkMonitor(FakeNetworkMonitor());
    final server = FakeAnalyticsServer();
    final config = sampleTrackLiteConfig(
      networkMonitor: monitor,
      transport: server,
    );

    expect(config.problems, isEmpty);
    expect(config.apiKey, 'demo_key');
    // The SDK's fake server, made by the app (for the demo controls), and
    // the sample's monitor, with the demo switch.
    expect(config.transport, same(server));
    expect(config.networkMonitor, same(monitor));
    expect(config.backgroundUploads, isTrue);
  });

  test(
    'the demo monitor is the SDK\'s monitor and the Dashboard\'s port',
    () async {
      await startSdk();

      expect(getIt<DeviceNetwork>(), same(getIt<DemoNetworkMonitor>()));
    },
  );
}
