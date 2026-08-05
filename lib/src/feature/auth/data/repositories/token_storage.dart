import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paywall_demo/src/feature/auth/extension/token_storage_x.dart';

/// Хранилище токена авторизации
abstract interface class ITokenStorage {
  /// Текущий токен
  Future<String?> get token;

  /// Сохранить токен
  Future<void> setToken(String token);

  /// Удалить токен
  Future<void> removeToken();

  /// Токен по умолчанию
  String? get defaultToken;
}

final class TokenStorage implements ITokenStorage {
  TokenStorage({required this._secureStorage});

  final FlutterSecureStorage _secureStorage;

  String? _cachedToken; // Кэш в оперативной памяти

  bool _isInitialized = false;

  /// Прогревает кэш токена из SecureStorage.
  /// Вызывать до первого обращения к [token].
  Future<void> init() async {
    if (_isInitialized) return;
    _cachedToken = await _secureStorage.token;
    _isInitialized = true;
  }

  @override
  Future<String?> get token async {
    if (!_isInitialized) {
      await init();
    }
    return _cachedToken;
  }

  @override
  Future<void> setToken(String token) async {
    _cachedToken = token; // Сначала обновляем кэш (мгновенно)
    await _secureStorage.setToken(token);
  }

  @override
  Future<void> removeToken() async {
    _cachedToken = null;
    await _secureStorage.removeToken();
    if (defaultToken != null) {
      await setToken(defaultToken!);
    }
  }

  @override
  String? get defaultToken => null;
}
