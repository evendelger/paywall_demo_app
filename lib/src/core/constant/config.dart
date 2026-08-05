import 'dart:io' show Platform;

import 'package:flutter/widgets.dart' show Size;

/// Конфигурация приложения
abstract base class Config {
  /// Environment flavor.
  static final environment = EnvironmentFlavor.from(
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development'),
  );

  /// Base url for api.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Support url.
  static const supportUrl = String.fromEnvironment('SUPPORT_URL');

  /// Site url.
  static const siteUrl = String.fromEnvironment('SITE_URL');

  /// Store url.
  static String storeUrl = Platform.isIOS
      ? const String.fromEnvironment('APP_STORE_URL')
      : const String.fromEnvironment('PLAY_STORE_URL');

  /// Application name
  static const appName = 'Paywall Demo';

  /// Префикс ключей в SharedPreferences
  static const prefsNamespace = 'paywall_demo';

  /// DB file name
  static const dbName = 'app_database.db';

  /// Таймаут соединения с серверером
  static const connectionTimeout = Duration(seconds: 15);

  /// Текущая платформа в строковом формате: `ios` `android`
  static final platform = Platform.isIOS ? 'ios' : 'android';

  /// Дефолтные значение для длительности анимации
  static const animationDuration = Duration(milliseconds: 250);
}

/// Конфигурация UI
abstract final class UIConfig extends Config {
  /// Общий радиус скругления
  static const double kBorderRadius = 8;

  /// Отступ внутри списка
  static const double kListPadding = 16;

  /// Отступ боковых панелей от краев экрана
  static const double kSidePadding = 20;

  /// Высота картинки сбора
  static const double kCardImageHeight = 420;

  /// Размер растянутой кнопки
  static const kMaxButtonSize = Size.fromHeight(52);

  /// Размер сжатой кнопки
  static const kMinButtonSize = Size(0, 52);

  /// Высота нижнего отступа
  static const double kBottomPadding = 8;
}

/// Конфигурация окружения
enum EnvironmentFlavor {
  /// Development
  development('development'),

  /// Production
  production('production')
  ;

  /// Create environment flavor.
  const EnvironmentFlavor(this.value);

  /// Create environment flavor from string.
  factory EnvironmentFlavor.from(String? value) => switch (value
      ?.trim()
      .toLowerCase()) {
    'development' || 'debug' || 'develop' || 'dev' => development,
    'production' || 'release' || 'prod' || 'prd' => production,
    _ =>
      const bool.fromEnvironment('dart.vm.product') ? production : development,
  };

  /// development, staging, production
  final String value;

  /// Whether the environment is development.
  bool get isDevelopment => this == development;

  /// Whether the environment is production.
  bool get isProduction => this == production;
}
