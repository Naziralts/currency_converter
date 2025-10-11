import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../features/converter/data/datasources/rate_remote_data_source.dart';
import '../features/converter/data/repositories/rate_repository_impl.dart';
import '../features/converter/domain/repositories/rate_repository.dart';
import '../features/converter/domain/usecases/get_history.dart';
import '../features/converter/domain/usecases/get_latest_rate.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Dio
  sl.registerLazySingleton<Dio>(() => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ));

  // DataSource
  sl.registerLazySingleton<RateRemoteDataSource>(
    () => RateRemoteDataSourceImpl(
      dio: sl(),
      freeCurrencyApiKey: 'fca_live_PX53RHJtNo4EsVpTFdztAe4DRyhLpwcYtVsokRGK', // вставь свой ключ
    ),
  );

  // Репозиторий
  sl.registerLazySingleton<RateRepository>(() => RateRepositoryImpl(sl()));

  // UseCases
  sl.registerFactory<GetLatestRate>(() => GetLatestRate(sl()));
  sl.registerFactory<GetHistory>(() => GetHistory(sl()));
}
