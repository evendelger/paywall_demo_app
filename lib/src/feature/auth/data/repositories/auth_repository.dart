import 'dart:async';

import 'package:client_api/client_api.dart';
import 'package:paywall_demo/src/feature/auth/data/repositories/token_storage.dart';
import 'package:paywall_demo/src/feature/user/database/dao/user_dao.dart';
import 'package:paywall_demo/src/feature/user/model/user.dart';

/// {@template auth_repository}
/// Репозиторий авторизации.
///
/// В шаблоне реализован только выход из аккаунта и поток текущего
/// пользователя. Вход добавляется здесь — через `ClientApi.login` /
/// `ClientApi.register` с сохранением токена в [ITokenStorage]
/// и пользователя в [UserDao].
/// {@endtemplate}
abstract interface class IAuthRepository {
  /// Поток текущего пользователя: `null` — не авторизован
  Stream<User?> get user;

  // TODO(template): метод входа, например
  // Future<User> signIn({required LoginRequest request});

  /// Выход из аккаунта: очистка токена и локальных данных
  Future<void> signOut();
}

/// {@macro auth_repository}
final class AuthRepository implements IAuthRepository {
  /// {@macro auth_repository}
  AuthRepository({
    required this._client,
    required this.tokenStorage,
    required this.userDao,
  });

  /// Зарезервировано под реализацию входа
  // ignore: unused_field
  final ClientApi _client;

  /// Хранилище токенов
  final ITokenStorage tokenStorage;

  /// DAO пользователя
  final UserDao userDao;

  @override
  Future<void> signOut() async {
    await tokenStorage.removeToken();
    await userDao.removeAll();
  }

  @override
  Stream<User?> get user => userDao.user;
}
