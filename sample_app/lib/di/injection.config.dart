// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:tracklite/tracklite.dart' as _i171;
import 'package:tracklite_sample/data/analytics/demo_network_monitor.dart'
    as _i590;
import 'package:tracklite_sample/data/analytics/tracklite_analytics_service.dart'
    as _i140;
import 'package:tracklite_sample/di/app_module.dart' as _i602;
import 'package:tracklite_sample/domain/analytics/analytics_service.dart'
    as _i23;
import 'package:tracklite_sample/domain/network/device_network.dart' as _i906;
import 'package:tracklite_sample/domain/shop/product_catalog.dart' as _i21;
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart'
    as _i352;
import 'package:tracklite_sample/features/home/cubit/home_cubit.dart' as _i915;
import 'package:tracklite_sample/features/product/cubit/product_cubit.dart'
    as _i601;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i171.TrackLiteClient>(() => appModule.trackLite);
    gh.lazySingleton<_i21.ProductCatalog>(() => const _i21.ProductCatalog());
    gh.lazySingleton<_i171.NetworkMonitor>(
      () => appModule.deviceMonitor(),
      instanceName: 'device',
    );
    gh.lazySingleton<_i23.AnalyticsService>(
      () => _i140.TrackLiteAnalyticsService(gh<_i171.TrackLiteClient>()),
    );
    gh.lazySingleton<_i590.DemoNetworkMonitor>(
      () => appModule.demoNetwork(
        gh<_i171.NetworkMonitor>(instanceName: 'device'),
      ),
    );
    gh.factory<_i915.HomeCubit>(
      () => _i915.HomeCubit(gh<_i23.AnalyticsService>()),
    );
    gh.factoryParam<_i601.ProductCubit, String, dynamic>(
      (productId, _) => _i601.ProductCubit(
        productId,
        gh<_i21.ProductCatalog>(),
        gh<_i23.AnalyticsService>(),
      ),
    );
    gh.lazySingleton<_i906.DeviceNetwork>(
      () => appModule.deviceNetwork(gh<_i590.DemoNetworkMonitor>()),
    );
    gh.factory<_i352.DashboardCubit>(
      () => _i352.DashboardCubit(
        gh<_i23.AnalyticsService>(),
        gh<_i906.DeviceNetwork>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i602.AppModule {}
