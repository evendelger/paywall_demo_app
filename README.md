# Flutter Starter

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]

Шаблон Flutter-приложения: слоистая feature-архитектура, BLoC, DI через scope,
Auto Route, Drift, Retrofit-клиент, тема и набор базовых виджетов.
Из функционала — только главный экран; всё остальное готово к наращиванию.

---

## Новый проект из шаблона 🚀

```sh
make rename NAME=my_app BUNDLE_ID=com.company.myapp APP_NAME="My App" DOMAIN=myapp.com
```

Команда переименует Dart-пакет и все импорты, `Config.appName`, namespace
SharedPreferences, Android `namespace`/`applicationId`/`MainActivity`,
iOS bundle id и отображаемое имя, схему и домен deep links, после чего
выполнит `pub get`, `gen-l10n` и `build_runner`.

Дальше вручную:

1. **Переписать `CLAUDE.md`** — в нём шаблонная рамка, которая мешает работе над реальным проектом
2. `config/development.json` и `config/production.json` — `API_BASE_URL` и прочие ссылки
3. Иконка приложения и splash (`assets/`), затем `make splash`
4. Эндпоинты в `packages/client_api` под своё API
5. Push-уведомления — если нужны (см. ниже)

Полный порядок действий: [docs/NEW_PROJECT.md](docs/NEW_PROJECT.md).

## Запуск

Два флейвора: `development` и `production`.

```sh
make run                       # development
flutter run --flavor development --dart-define-from-file=config/development.json
flutter run --flavor production  --dart-define-from-file=config/production.json
```

Версия Flutter зафиксирована через FVM (`.fvmrc`) — при несовпадении глобальной
версии добавляйте префикс `fvm`.

## Сборка

```sh
make build-android   # appbundle, production
make build-ios       # ipa, production
```

Shorebird:

```sh
make shorebird-android
make shorebird-ios
```

## Кодогенерация

```sh
make runner          # dart run build_runner build -d
make watch-runner    # watch-режим
```

Запускать после изменения моделей (freezed/json), роутов (`@AutoRoute`),
схемы БД (drift) и ассетов.

## Что внутри

```
lib/src/
  core/          # api, bloc (DataBloc/PaginatedDataBloc), database, router,
                 # theme, utils, widget, scope-обёртки для DI
  feature/
    app/         # bootstrap, корневые роуты, оболочка с табами
    auth/        # авторизация — необязательна, см. ниже
    home/        # единственный экран
    notification/# push-уведомления — код есть, но не инициализируется
    settings/    # тема, версия приложения, конфиг
    user/        # текущий пользователь
```

### Авторизация

По умолчанию **необязательна**: приложение стартует сразу на главном экране,
неавторизованный пользователь — штатный «гость» (`UserScope.userOf` вернёт `null`).

Чтобы сделать вход обязательным:

1. Повесить `AuthGuard` на нужную ветку роутов — см. закомментированный пример
   в `AppRoutes.root` (`lib/src/feature/app/router/app_routes.dart`)
2. Раскомментировать редирект в `AppListeners`
   (`lib/src/feature/app/widget/app_listeners.dart`)
3. Реализовать вход в `AuthRepository` и форму в `LoginScreen`

### Push-уведомления

Код (`lib/src/feature/notification/`) и зависимости
(`firebase_core`, `firebase_messaging`, `flutter_local_notifications`)
оставлены в проекте, но **не инициализируются**. Чтобы включить:

1. `flutterfire configure` — появится `lib/firebase_options.dart`,
   `google-services.json` и `GoogleService-Info.plist`
2. Раскомментировать блок с `Firebase.initializeApp()` и
   `NotificationService.setup()` в `MainRunner.run()`
   (`lib/src/feature/app/logic/runner.dart`)
3. Заменить `Firebase.initializeApp()` на вариант с `DefaultFirebaseOptions`
   в `notification_service.dart` (отмечено `TODO(template)`)

### Новая вкладка

1. Создать фичу с `router/`, `view/` по образцу `feature/home`
2. Добавить `...<Feature>Routes.tabRoutes` в `MainRoutes.routes`
3. Добавить роут в `MainShell._tabs` и элемент в `AppBottomNavBar.items`
   (панель появляется автоматически, когда вкладок больше одной)
4. `make runner`

## Локализация 🌐

ARB-файлы: `lib/src/core/constant/l10n/arb/`, шаблон — `app_ru.arb` (единственная
локаль `ru`). Добавили строку → `flutter gen-l10n` (или `make runner`).

Использование:

```dart
final l10n = context.l10n;
return Text(l10n.homeLabel);
```

Новая локаль: добавить `app_<locale>.arb` рядом с шаблоном и внести локаль
в `CFBundleLocalizations` в `ios/Runner/Info.plist`.

## Тесты

```sh
flutter test
```

`test/helpers/pump_app.dart` — хелпер рендеринга виджета с локализациями.

[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
