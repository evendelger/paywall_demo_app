import 'package:client_api/client_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paywall_demo/src/core/api/api_client.dart';
import 'package:paywall_demo/src/core/api/auth_interceptor.dart';
import 'package:paywall_demo/src/core/constant/config.dart';
import 'package:paywall_demo/src/core/database/database.dart';
import 'package:paywall_demo/src/core/utils/logger.dart';
import 'package:paywall_demo/src/feature/auth/data/repositories/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IDependenciesStorage {
  Dio get dio;
  AppDatabase get database;
  SharedPreferences get sharedPreferences;
  ITokenStorage get tokenStorage;
  ClientApi get client;
  FlutterSecureStorage get secureStorage;

  void close();
}

final class DependenciesStorage implements IDependenciesStorage {
  DependenciesStorage._({
    required this.dio,
    required this.database,
    required this.sharedPreferences,
    required this.tokenStorage,
    required this.client,
    required this.secureStorage,
  });

  static Future<DependenciesStorage> create({
    required SharedPreferences sharedPreferences,
  }) async {
    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(secureStorage: secureStorage);
    await tokenStorage.init();

    final apiClient = ApiClient(
      talker: mainTalker,
      baseUrl: Config.apiBaseUrl,
    );
    final dio = apiClient.dio;
    final database = AppDatabase(name: Config.dbName);

    dio.interceptors.add(
      AuthInterceptor(
        dio,
        onLogout: database.userDao.removeAll,
        tokenStorage: tokenStorage,
      ),
    );

    final client = ClientApi(
      dio,
      baseUrl: Config.apiBaseUrl,
    );

    return DependenciesStorage._(
      dio: dio,
      database: database,
      sharedPreferences: sharedPreferences,
      tokenStorage: tokenStorage,
      client: client,
      secureStorage: secureStorage,
    );
  }

  @override
  final Dio dio;

  @override
  final AppDatabase database;

  @override
  final SharedPreferences sharedPreferences;

  @override
  final ITokenStorage tokenStorage;

  @override
  final ClientApi client;

  @override
  final FlutterSecureStorage secureStorage;

  @override
  Future<void> close() async {
    dio.close();
    await database.close();
  }
}
