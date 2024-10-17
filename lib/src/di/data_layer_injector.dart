
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final injector = GetIt.instance;

Future<void> initializeDataDependencies() async {
  // injector.registerLazySingleton(() => Dio()
  //   ..options.baseUrl = "https://api.cityeye.eg/api/v1/"
  //   ..interceptors.add(ChuckerDioInterceptor())
  //   ..interceptors.add(PrettyDioLogger(
  //     requestHeader: false,
  //     requestBody: true,
  //     responseBody: true,
  //     responseHeader: false,
  //     compact: false,
  //   )));

  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  injector.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

 }
