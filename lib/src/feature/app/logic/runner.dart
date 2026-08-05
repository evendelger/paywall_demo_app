import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/model/model.dart';
import 'package:paywall_demo/src/core/utils/utils.dart';
import 'package:paywall_demo/src/feature/app/app_root.dart';
import 'package:paywall_demo/src/feature/app/widget/app_error.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_settings.dart';

/// {@template main_runner}
/// Точка входа приложения: инициализация биндингов, логирования,
/// зависимостей и репозиториев.
/// {@endtemplate}
mixin MainRunner {
  static void _amendFlutterError() {
    const log = AppLogger.logFlutterError;

    FlutterError.onError = FlutterError.onError?.amend(log) ?? log;
  }

  static void _runZoned<T>(T Function() body) =>
      runZonedGuarded(body, AppLogger.logZoneError);

  /// {@macro main_runner}
  static Future<void> run() async => _runZoned(
    () async {
      final wb = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: wb);

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // TODO(template): Push-уведомления.
      // Раскомментировать после того, как в проект будут добавлены
      // firebase_options.dart (flutterfire configure), google-services.json
      // и GoogleService-Info.plist:
      //
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      // await NotificationService.setup();

      _amendFlutterError();

      Bloc.observer = TalkerBlocObserver(
        talker: mainTalker,
        settings: TalkerBlocLoggerSettings(
          printCreations: true,
          printClosings: true,
          printStateFullData: false,
          transitionFilter: (bloc, transition) => true,
          eventFilter: (bloc, event) => true,
        ),
      );

      try {
        final sharedPreferences = await SharedPreferences.getInstance();

        final dependencies = await DependenciesStorage.create(
          sharedPreferences: sharedPreferences,
        );

        final repositories = RepositoryStorage(
          appDatabase: dependencies.database,
          sharedPreferences: sharedPreferences,
          client: dependencies.client,
          tokenStorage: dependencies.tokenStorage,
          dio: dependencies.dio,
        );

        final initialUser = await dependencies.database.userDao.getUser();

        FlutterNativeSplash.remove();

        return runApp(
          AppRoot(
            dependencies: dependencies,
            repositories: repositories,
            initialUser: initialUser,
          ),
        );
      } on Object catch (error, stackTrace) {
        mainTalker.handle(error, stackTrace);
        FlutterNativeSplash.remove();
        return runApp(AppError(error: error));
      }
    },
  );
}
