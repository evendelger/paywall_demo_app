import 'package:client_api/client_api.dart';
import 'package:dio/dio.dart';
import 'package:paywall_demo/src/core/database/drift/app_database.dart';
import 'package:paywall_demo/src/feature/auth/data/repositories/auth_repository.dart';
import 'package:paywall_demo/src/feature/auth/data/repositories/token_storage.dart';
import 'package:paywall_demo/src/feature/notification/data/notifications_repository.dart';
import 'package:paywall_demo/src/feature/settings/data/repository/settings_repository.dart';
import 'package:paywall_demo/src/feature/settings/database/settings_dao.dart';
import 'package:paywall_demo/src/feature/user/data/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IRepositoryStorage {
  ISettingsRepository get settings;
  IAuthRepository get auth;
  IUserRepository get user;
  INotificationsRepository get notifications;
}

final class RepositoryStorage implements IRepositoryStorage {
  RepositoryStorage({
    required this._appDatabase,
    required this._sharedPreferences,
    required this._client,
    required this._tokenStorage,
    required Dio dio,
  });

  final AppDatabase _appDatabase;

  final SharedPreferences _sharedPreferences;

  final ITokenStorage _tokenStorage;

  final ClientApi _client;

  @override
  late final ISettingsRepository settings = SettingsRepository(
    settingsDao: SettingsDao(sharedPreferences: _sharedPreferences),
    client: _client,
  );

  @override
  late final IAuthRepository auth = AuthRepository(
    client: _client,
    tokenStorage: _tokenStorage,
    userDao: _appDatabase.userDao,
  );

  @override
  late final IUserRepository user = UserRepository(
    client: _client,
    userDao: _appDatabase.userDao,
  );

  @override
  late final INotificationsRepository notifications = NotificationsRepository(
    client: _client,
  );
}
