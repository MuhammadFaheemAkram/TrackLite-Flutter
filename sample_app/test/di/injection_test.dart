import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/app/analytics_config.dart';
import 'package:tracklite_sample/data/analytics/tracklite_analytics_service.dart';
import 'package:tracklite_sample/di/injection.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:tracklite_sample/features/home/cubit/home_cubit.dart';
import 'package:tracklite_sample/features/product/cubit/product_cubit.dart';

import '../helpers/app_harness.dart';

void main() {
  tearDown(tearDownSample);

  test('the graph builds once the SDK has started, as in main()', () async {
    await startSdk();
    configureDependencies();

    expect(getIt<TrackLiteClient>(), same(TrackLite.instance));
    expect(getIt<AnalyticsService>(), isA<TrackLiteAnalyticsService>());
    expect(getIt<HomeCubit>(), isNot(same(getIt<HomeCubit>())));
    expect(getIt<DashboardCubit>(), isA<DashboardCubit>());
    expect(
      getIt<ProductCubit>(param1: 'grinder').state.product?.name,
      'Hand grinder',
    );
  });

  test('the sample configures the SDK with a valid config', () {
    expect(sampleTrackLiteConfig.problems, isEmpty);
    expect(sampleTrackLiteConfig.apiKey, 'demo_key');
    // No transport: the SDK's own fake server, with its demo latency and
    // failure rate.
    expect(sampleTrackLiteConfig.transport, isNull);
  });
}
