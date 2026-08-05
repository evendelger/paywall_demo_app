# Старт реального проекта из шаблона

Порядок действий после копирования репозитория. Пункты 1–2 обязательны,
без них проект остаётся «шаблоном» и мешает работе.

## 1. Переименование

```sh
make rename NAME=my_app BUNDLE_ID=com.company.myapp APP_NAME="My App" DOMAIN=myapp.com
```

Скрипт переименует Dart-пакет и все импорты, описание в `pubspec.yaml`,
`Config.appName` и `Config.prefsNamespace`, ключ `appName` в ARB,
Android `namespace`/`applicationId`/`MainActivity` (вместе с каталогом),
iOS bundle id и отображаемые имена, схему и домен deep links. Затем сам
прогонит `flutter pub get`, `flutter gen-l10n` и `build_runner`.

Проверка: `flutter analyze` и `flutter test` должны быть зелёными.

## 2. CLAUDE.md

**Это самый важный шаг после переименования.** Файл написан для шаблона и
открывается двумя ограничениями — «не добавляй продуктовые фичи» и «экраны и
бизнес-логика принадлежат производным проектам». Если их не убрать, Claude
Code будет сопротивляться ровно той работе, ради которой заведён проект.

### Убрать или переписать

| Что | Где |
|---|---|
| Вводная рамка «This is a project template» и два ограничения под ней | начало файла |
| Команда `make rename` | раздел Commands |
| Раздел Rename tooling | ближе к концу Architecture |
| Оговорки «config ship with `example.com` placeholders», «assets ship empty», «Keep this feature dormant in the template», «in a derived project» | разделы API client, Theme & assets, Push notifications, Authentication |
| Конвенция `TODO(template):` | раздел Conventions |

### Оставить без изменений

- Весь раздел Architecture: слои и направление зависимостей, DI через scopes,
  роутинг Auto Route, BLoC и базовые классы, data-слой и обработка ошибок,
  Drift и типизированные SharedPreferences, API-клиент
- Commands и планка приёмки: `flutter analyze` + `flutter test` + реальная
  сборка при изменении платформенного конфига или ассетов
- Ловушка `build.yaml` (файл вне glob'ов молча не генерируется) и список
  генерируемых файлов
- Разделы Conventions и Linting

### Дописать под проект

То, чего в шаблоне быть не может:

- назначение приложения в двух-трёх строках
- окружения и реальные API-адреса
- решение по авторизации: подключён ли `AuthGuard` или пользователь остаётся
  гостём
- включены ли push-уведомления
- доменные термины и сущности предметной области
- внешние сервисы и интеграции (аналитика, карты, платежи, крашлитика)

## 3. Конфигурация

- `config/development.json` и `config/production.json` — `API_BASE_URL`,
  `SITE_URL`, `SUPPORT_URL`, ссылки на сторы. Значения читаются только через
  `Config`, инлайнить их в коде нельзя
- `packages/client_api` — эндпоинты и DTO под своё API, после правок
  `build_runner` запускается **внутри этого пакета**

## 4. Ресурсы и оформление

- Иконка приложения и splash в `assets/`, затем `make splash`
  (каталоги `assets/images/` и `assets/splash/` в шаблоне пустые, в них лежит
  `.gitkeep` — удалять его нельзя, пустой объявленный каталог ассетов ломает
  сборку)
- Шрифт проекта: секция `fonts:` в `pubspec.yaml` + `fontFamily:
  FontFamily.<name>` в `AppTheme._buildTheme()`. По умолчанию системный
- Палитра в `AppPalette`, размеры и отступы в `UIConfig`

## 5. Push-уведомления (если нужны)

1. `flutterfire configure` — появятся `lib/firebase_options.dart`,
   `google-services.json` и `GoogleService-Info.plist`
2. Раскомментировать блок `Firebase.initializeApp()` +
   `NotificationService.setup()` в `MainRunner.run()`
3. В `notification_service.dart` заменить `Firebase.initializeApp()` на
   вариант с `DefaultFirebaseOptions`

Оба места помечены `TODO(template)`.

## 6. Авторизация (если обязательна)

По умолчанию вход необязателен: приложение стартует на главном экране,
неавторизованный пользователь — штатный гость, `UserScope.userOf` возвращает
`null`. Подставлять фейкового `User`, чтобы обойти проверку на null, нельзя.

Чтобы сделать вход обязательным:

1. Повесить `AuthGuard` на нужную ветку роутов — закомментированный пример в
   `AppRoutes.root`
2. Раскомментировать редирект в `AppListeners`
3. Реализовать вход в `AuthRepository` (помечено `TODO(template)`) и форму в
   `LoginScreen`

## 7. Остальное

- `README.md` — в нём та же шаблонная рамка, переписать под проект
- `android/key.properties` и keystore: `make setup-android`
- Deep links: файлы `apple-app-site-association` и `assetlinks.json` в шаблоне
  не поставляются, их нужно выложить на домен проекта
- Версия Flutter зафиксирована в `.fvmrc`, версия в `make shorebird-*` должна
  ей соответствовать
