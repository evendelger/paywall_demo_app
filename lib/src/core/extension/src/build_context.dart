import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/database/database.dart';
import 'package:paywall_demo/src/core/model/model.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension BuildContextX on BuildContext {
  IDependenciesStorage get dependencies => DependenciesScope.of(this);

  Dio get dio => dependencies.dio;

  AppDatabase get database => dependencies.database;

  SharedPreferences get sharedPreferences => dependencies.sharedPreferences;

  IRepositoryStorage get repository => RepositoryScope.of(this);

  AppLocalizations get l10n => AppLocalizations.of(this);

  MaterialLocalizations get materialLocalizations =>
      MaterialLocalizations.of(this);

  ScaffoldMessengerState get messenger => ScaffoldMessenger.of(this);

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;
}
