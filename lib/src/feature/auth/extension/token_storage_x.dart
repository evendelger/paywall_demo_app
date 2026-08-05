import 'package:flutter_secure_storage/flutter_secure_storage.dart';

extension TokenSecureStorageX on FlutterSecureStorage {
  static const _tokenKey = 'auth_token';

  Future<String?> get token => read(key: _tokenKey);

  Future<void> setToken(String token) => write(key: _tokenKey, value: token);

  Future<void> removeToken() => delete(key: _tokenKey);
}
