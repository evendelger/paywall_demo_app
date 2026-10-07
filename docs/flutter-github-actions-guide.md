# CI/CD для Paywall Demo на GitHub Actions

План настройки CI/CD именно для этого репозитория (`evendelger/paywall_demo_app`). За основу взят
общий гайд по Flutter + GitHub Actions, но всё ниже уже подогнано под проект: флейворы
`development` / `production`, кодогенерация без закоммиченных `*.g.dart`, отдельный пакет
`packages/client_api`, Java 21 в Gradle и модель веток `develop` → `main`.

**Итог, к которому придём:**

| Этап | Что делает | Когда запускается | Раннер | Секреты |
|---|---|---|---|---|
| 1. CI-проверки | формат, кодогенерация, анализатор, тесты | PR и push в `develop` / `main` | Ubuntu | нет |
| 2. Android dev-сборка | подписанный APK флейвора `development` | push в `develop` | Ubuntu | keystore |
| 3. iOS | проверка компиляции `production` без подписи | push в `develop` / `main`, PR в `main` | macOS | нет |
| 4. Release | APK + AAB `production` по тегу `v*` на `main` + GitHub Release | push тега | Ubuntu | keystore |
| 5. Раздача | Firebase App Distribution (опционально) | после этапа 2 | Ubuntu | Firebase |

Делайте по порядку — каждый этап работает без следующих.

> Минуты Actions: на **публичном** репозитории стандартные раннеры (включая macOS) бесплатны.
> На приватном — 2000 мин/мес, а macOS списывается с коэффициентом 10x. Если репозиторий
> приватный, iOS-джоб из этапа 3 переведите на `workflow_dispatch` (см. ниже).

---

## Модель веток

```
feature/*, fix/*, ci/*  ──PR──▶  develop  ──PR (релиз)──▶  main  ──tag v1.2.3──▶  Release
                                    ▲                        │
                                    └──── back-merge ────────┘   (после hotfix/* в main)
```

- Вся разработка идёт в `develop`, фичи приходят в него через PR.
- В `main` попадают только релизные PR из `develop` (или `release/*`) и `hotfix/*`.
- Релиз — это тег `v*` на коммите в `main`. Тег вне `main` release-workflow отклоняет.
- Релизный PR `develop → main` мёржится **merge-коммитом**, не squash: иначе истории веток
  разъедутся и следующий релизный PR покажет уже влитые коммиты как новые.

Что из этого следует для workflow:

| Событие | Что запускается |
|---|---|
| PR в `develop` | проверки (этап 1) |
| push в `develop` (= мёрж PR) | проверки + dev-APK + iOS-компиляция |
| PR в `main` | проверки + iOS-компиляция + проверка, что PR идёт из разрешённой ветки |
| push в `main` | проверки + iOS-компиляция |
| тег `v*` | релизная сборка |

---

## Шаг 0. Подготовка репозитория

Состояние проекта на момент написания и что ещё нужно сделать:

- [x] **Версия Flutter зафиксирована.** `environment.flutter: 3.44.1` в `pubspec.yaml` — точная
  версия, без `^`, иначе `subosito/flutter-action` не прочитает её из `flutter-version-file`.
  При обновлении Flutter меняйте **три** места: `.fvmrc`, `pubspec.yaml` и `--flutter-version`
  в shorebird-целях `Makefile`.
- [x] **`pubspec.lock` коммитится.** Строку из `.gitignore` нужно **удалить**, а не
  закомментировать.
- [x] **Секреты Android в `.gitignore`.** `android/.gitignore` уже исключает `key.properties`,
  `**/*.jks`, `**/*.keystore`.
- [x] **Конфиги флейворов в git.** `config/development.json` и `config/production.json`
  закоммичены: в них только заглушки `example.com`, а без файла `--dart-define-from-file`
  падает (`Did not find the file passed to "--dart-define-from-file"`). Когда в конфиге
  появятся реальные значения — переносить его в секрет GitHub (`gh secret set
  CONFIG_JSON_PRODUCTION < config/production.json`), в git оставлять `config/example.json` со
  всеми ключами, а в CI записывать файл отдельным шагом со сверкой ключей с шаблоном.
- [x] **Строгий линтер.** `very_good_analysis` + override-лист в `analysis_options.yaml`,
  `flutter analyze --fatal-infos` локально чистый.
- [ ] **Кодогенерация `core/bloc`.** В `build.yaml` в глобы `freezed` добавлен
  `lib/src/core/bloc/**`. Без этого на чистом раннере не появятся `data_bloc.freezed.dart` и
  `paginated_data_bloc.freezed.dart` (локально они остались от старых запусков и маскируют
  проблему).
- [ ] **Форматирование.** `dart format --set-exit-if-changed` сейчас падает на 8 файлах
  (`config.dart`, `open_connection_io.dart`, `subscription_bloc.dart`, `paywall_screen.dart`,
  `api_response.dart`, двух тестах подписки, `tool/rename.dart`). Починить: `dart format .`.

### Решение по сгенерированному коду

`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.gen.dart` в `.gitignore` — значит, **CI всегда
генерирует код сам**, в двух местах:

1. `packages/client_api` — Retrofit `ClientApi` и DTO, свой `build.yaml`, свой `pub get`;
2. корень проекта — freezed/json/drift/auto_route/flutter_gen.

Локализация (`app_localizations*.dart`) закоммичена и дополнительно перегенерируется на
`flutter pub get` (`generate: true` в `pubspec.yaml`).

Следствие: генерация нужна в **каждом** джобе, который компилирует Dart — анализ, тесты,
Android, iOS, релиз. Чтобы не копировать четыре шага по всем workflow, они вынесены в
composite action (шаг 1).

---

## Шаг 1. Проверки на pull request

### Общий action: Flutter + зависимости + кодогенерация

`.github/actions/setup-flutter/action.yaml`:

```yaml
name: Setup Flutter
description: Flutter из pubspec.yaml, зависимости и кодогенерация (client_api + приложение)

runs:
  using: composite
  steps:
    - uses: subosito/flutter-action@v2
      with:
        flutter-version-file: pubspec.yaml
        channel: stable
        cache: true

    - name: Install dependencies
      shell: bash
      run: flutter pub get

    - name: Generate code (client_api)
      shell: bash
      working-directory: packages/client_api
      run: |
        dart pub get
        dart run build_runner build --delete-conflicting-outputs

    - name: Generate code (app)
      shell: bash
      run: dart run build_runner build --delete-conflicting-outputs
```

Composite action подключается локальным путём, поэтому `actions/checkout` должен идти **до** него.

### Workflow проверок

`.github/workflows/ci.yaml`:

```yaml
name: CI

on:
  pull_request:
    branches: [develop, main]
  push:
    branches: [develop, main]

# PR-сборки отменяем при новом пуше, сборки веток доводим до конца —
# иначе быстрый второй мёрж в develop отменит dev-сборку первого.
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

jobs:
  analyze:
    name: Analyze & test
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - uses: actions/checkout@v4

      - uses: ./.github/actions/setup-flutter

      # Только отслеживаемые git файлы: сгенерированный код к этому моменту
      # уже лежит на диске, но его формат нас не интересует.
      - name: Check formatting
        run: git ls-files -z '*.dart' | xargs -0 dart format --output=none --set-exit-if-changed

      - name: Analyze
        run: flutter analyze --fatal-infos

      - name: Run tests
        run: flutter test --coverage --test-randomize-ordering-seed random

      - name: Upload coverage
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/lcov.info
          retention-days: 7
```

Почему так, а не как в исходном гайде:

- **Формат проверяется по `git ls-files`**, а не по `.`: так шаг не зависит от того, стоит он до
  или после кодогенерации, и не валится на форматировании чужого сгенерированного кода.
- **`--test-randomize-ordering-seed random`** ловит тесты, зависящие от порядка запуска (общий
  `SharedPreferences.setMockInitialValues`, синглтоны). Seed печатается в логе — по нему падение
  воспроизводится локально.
- **`--fatal-infos`** строже локального `flutter analyze` из `CLAUDE.md` — это намеренно.
- `flutter test` не требует `--dart-define-from-file`: тесты не читают `Config`. Если когда-то
  начнут — добавьте `--dart-define-from-file=config/development.json`.

### Проверка ветки для PR в `main`

В тот же `ci.yaml` — джоб, который краснеет, если в `main` пытаются влить фичу напрямую:

```yaml
  release-source:
    name: Release PR source
    if: github.event_name == 'pull_request' && github.base_ref == 'main'
    runs-on: ubuntu-latest
    timeout-minutes: 1
    steps:
      - name: Only develop, release/* or hotfix/* may target main
        env:
          HEAD_REF: ${{ github.head_ref }}
        run: |
          case "$HEAD_REF" in
            develop|release/*|hotfix/*) echo "OK: $HEAD_REF" ;;
            *) echo "::error::В main можно вливать только develop, release/* или hotfix/* (получено: $HEAD_REF)"; exit 1 ;;
          esac
```

`head_ref` задаёт автор PR, поэтому он передаётся через `env`, а не подставляется в скрипт
выражением `${{ }}` — так имя ветки не может стать частью shell-команды.

---

## Шаг 2. Android: подписанная dev-сборка

### Что уже есть в проекте

- `android/app/build.gradle.kts` читает `android/key.properties` и создаёт `signingConfig`
  `release`. **Если файла нет — release-сборка собирается неподписанной** (а не debug-ключом,
  как в типовом шаблоне): её нельзя установить на устройство, но компиляция проверяется.
- Gradle собран под **Java 21** (`JavaVersion.VERSION_21`) — в CI ставим 21, не 17.
- Флейворы: `development` (`com.test.paywalldemo.dev`, имя «Paywall Demo (dev)») и `production`
  (`com.test.paywalldemo`). Обе версии ставятся на одно устройство рядом.
- `storeFile` резолвится от `android/app/` (`file(it)` в модуле `app`).

### Создайте keystore

Через цель Makefile (кладёт файл в `android/app/keystore.jks` и пишет `android/key.properties`):

```bash
make setup-android KEY_STORE_PASS=<пароль> KEY_ALIAS_PASS=<пароль>
```

Пароль сохраните в менеджере паролей, а сам `.jks` — вне репозитория (например, рядом с
паролем). Потерянный upload-ключ = невозможность обновить приложение в Google Play.

Проверьте локально:

```bash
flutter build apk --release --flavor development --dart-define-from-file=config/development.json

# apksigner из Android SDK build-tools
"$(ls -d ~/Library/Android/sdk/build-tools/*/ | sort -V | tail -1)apksigner" \
  verify --print-certs build/app/outputs/flutter-apk/app-development-release.apk

# сравнить с отпечатком ключа
keytool -list -keystore android/app/keystore.jks
```

Ожидаемо: `Verified using v2 scheme: true`, `Signer #1 certificate DN: CN=Android Release, …` и
SHA-256 сертификата совпадает с отпечатком записи `upload` в keystore.

`keytool -printcert -jarfile <apk>` здесь **не подходит**: он проверяет только v1-подпись (JAR),
а при `minSdk` ≥ 24 AGP подписывает APK только схемой v2, и `keytool` честно отвечает
`Not a signed jar file` даже для правильно подписанного файла.

Первая release-сборка локально идёт около 2 минут, в CI без прогретого Gradle-кэша — 5–8.

#### Версии Android-тулчейна

Под Flutter 3.44.1 подняты до минимально поддерживаемых (на AGP 8.x — AGP 9 несёт breaking
changes):

| Что | Было | Стало | Где |
|---|---|---|---|
| Gradle | 8.12 | 8.14.3 | `android/gradle/wrapper/gradle-wrapper.properties` |
| AGP | 8.9.1 | 8.11.1 | `android/settings.gradle.kts`, `com.android.application` |
| Kotlin | 2.1.0 | 2.2.20 | `android/settings.gradle.kts`, `org.jetbrains.kotlin.android` |

В Kotlin 2.2 блок `android { kotlinOptions { … } }` — ошибка компиляции, поэтому `jvmTarget`
перенесён в `kotlin { compilerOptions { jvmTarget = JvmTarget.JVM_21 } }`.

Осталось одно предупреждение — миграция на Built-in Kotlin: KGP применяет само приложение и
`firebase_core`, который подключён, но не используется (пуши выключены). Миграцию ждём от новой
версии `firebase_core`; `android.builtInKotlin=false` в `gradle.properties` пока не трогаем.

### Секреты GitHub

```bash
base64 -i android/app/keystore.jks | pbcopy
```

**Settings → Secrets and variables → Actions → New repository secret:**

| Имя | Значение |
|---|---|
| `KEYSTORE_BASE64` | результат команды выше |
| `STORE_PASSWORD` | `KEY_STORE_PASS` |
| `KEY_PASSWORD` | `KEY_ALIAS_PASS` |
| `KEY_ALIAS` | `upload` |

Секреты маскируются в логах и **не передаются** в workflow из PR с форков.

### Джоб сборки

В `ci.yaml`. Запускается только после мёржа в `develop`: на PR проверок достаточно, а секретов
у PR с форков всё равно нет.

```yaml
  build-android:
    name: Build Android (development)
    if: github.event_name == 'push' && github.ref == 'refs/heads/develop'
    needs: analyze
    runs-on: ubuntu-latest
    timeout-minutes: 25

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'
          cache: gradle

      - uses: ./.github/actions/setup-flutter

      - name: Configure signing
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}
          STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
        run: |
          echo "$KEYSTORE_BASE64" | base64 --decode > android/app/upload-keystore.jks
          cat > android/key.properties <<EOF
          storePassword=$STORE_PASSWORD
          keyPassword=$KEY_PASSWORD
          keyAlias=$KEY_ALIAS
          storeFile=upload-keystore.jks
          EOF

      - name: Build APK
        run: |
          flutter build apk --release \
            --flavor development \
            --dart-define-from-file=config/development.json \
            --build-number=${{ github.run_number }} \
            --obfuscate --split-debug-info=build/symbols

      - uses: actions/upload-artifact@v4
        with:
          name: app-development-apk
          path: build/app/outputs/flutter-apk/app-development-release.apk
          retention-days: 14

      - uses: actions/upload-artifact@v4
        with:
          name: android-debug-symbols-development
          path: build/symbols
          retention-days: 30
```

Детали:

- **Путь к APK содержит флейвор**: `app-development-release.apk`, а не `app-release.apk`.
- `cache: gradle` в `setup-java` заменяет ручной `actions/cache` для `~/.gradle`.
- Секреты идут в скрипт через `env`, а не подстановкой `${{ secrets.* }}` в текст heredoc:
  спецсимволы в пароле (`$`, `` ` ``) не будут интерпретированы shell.
- `--obfuscate --split-debug-info` — символы храните дольше самой сборки, без них стектрейс
  из обфусцированного билда не читается.

---

## Шаг 3. iOS: проверка компиляции

Подписать сборку без Apple Developer Program нельзя, но проверить, что `production`-флейвор
компилируется (поды, deployment target 15.0, нативный код плагинов, Firebase-поды), — можно.
Схемы `development` / `production` уже есть в `ios/Runner.xcodeproj/xcshareddata/xcschemes`.

```yaml
  build-ios:
    name: Build iOS (no codesign)
    if: github.event_name == 'push' || github.base_ref == 'main'
    needs: analyze
    runs-on: macos-latest
    timeout-minutes: 40

    steps:
      - uses: actions/checkout@v4

      - uses: ./.github/actions/setup-flutter

      # ios/Podfile.lock в .gitignore — ключ кэша строим по pubspec.lock и Podfile.
      - name: Cache CocoaPods
        uses: actions/cache@v4
        with:
          path: ios/Pods
          key: pods-${{ runner.os }}-${{ hashFiles('pubspec.lock', 'ios/Podfile') }}
          restore-keys: pods-${{ runner.os }}-

      - name: Build
        run: |
          flutter build ios --release --no-codesign \
            --flavor production \
            --dart-define-from-file=config/production.json

      - name: Package .app
        run: cd build/ios/iphoneos && zip -r Runner.app.zip Runner.app

      - uses: actions/upload-artifact@v4
        with:
          name: ios-app-unsigned
          path: build/ios/iphoneos/Runner.app.zip
          retention-days: 7
```

- Условие `if` гоняет macOS только на push в `develop` / `main` и на релизных PR в `main` —
  обычные фичевые PR остаются быстрыми.
- **Приватный репозиторий:** вынесите джоб в `.github/workflows/ios.yaml` с триггерами
  `workflow_dispatch` + `pull_request: branches: [main]`.
- Не коммитьте `Podfile.lock`, пока он в `.gitignore`: стабильность подов в CI держится на
  `pubspec.lock`. Если начнутся конфликты версий подов — тогда стоит убрать его из `.gitignore`
  и закоммитить.

---

## Шаг 4. Релиз по тегу на `main`

`.github/workflows/release.yaml`:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write   # нужно для создания GitHub Release

jobs:
  release:
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0   # нужна история main для проверки ниже

      - name: Ensure tag points to main
        run: |
          git merge-base --is-ancestor "$GITHUB_SHA" origin/main \
            || { echo "::error::Тег $GITHUB_REF_NAME не на ветке main"; exit 1; }

      - name: Extract version from tag
        id: version
        run: echo "version=${GITHUB_REF_NAME#v}" >> "$GITHUB_OUTPUT"

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'
          cache: gradle

      - uses: ./.github/actions/setup-flutter

      - name: Configure signing
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}
          STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
        run: |
          echo "$KEYSTORE_BASE64" | base64 --decode > android/app/upload-keystore.jks
          cat > android/key.properties <<EOF
          storePassword=$STORE_PASSWORD
          keyPassword=$KEY_PASSWORD
          keyAlias=$KEY_ALIAS
          storeFile=upload-keystore.jks
          EOF

      - name: Build APK and AAB
        env:
          BUILD_ARGS: >-
            --release
            --flavor production
            --dart-define-from-file=config/production.json
            --build-name=${{ steps.version.outputs.version }}
            --build-number=${{ github.run_number }}
            --obfuscate --split-debug-info=build/symbols
        run: |
          flutter build apk $BUILD_ARGS
          flutter build appbundle $BUILD_ARGS

      - name: Package debug symbols
        run: cd build && zip -r symbols.zip symbols

      - name: Create GitHub Release
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          gh release create "$GITHUB_REF_NAME" \
            --title "$GITHUB_REF_NAME" \
            --generate-notes \
            build/app/outputs/flutter-apk/app-production-release.apk \
            build/app/outputs/bundle/productionRelease/app-production-release.aab \
            build/symbols.zip
```

Процесс релиза:

```bash
# 1. PR develop → main, дождаться зелёных проверок, смёржить merge-коммитом
# 2. Тег на main
git switch main && git pull
git tag v1.0.0
git push origin v1.0.0
```

### Про версионирование

- `--build-name` (видит пользователь) берётся из тега и перекрывает `version: 1.0.0+1` в
  `pubspec.yaml`. Держите `pubspec.yaml` в синхроне с тегами, чтобы локальные сборки не
  выглядели «старше» релизных.
- `--build-number` = `github.run_number` **release-workflow**: он монотонно растёт только в
  пределах одного workflow. У dev-сборок из `ci.yaml` свой счётчик, но они не идут в стор и
  имеют другой `applicationId` (`.dev`), так что пересечение номеров не мешает.
- `--generate-notes` собирает changelog из заголовков PR между тегами — пишите PR в стиле
  conventional commits (`feat:`, `fix:`, `ci:`), как уже принято в истории репозитория.
- **Shorebird** (`make shorebird-*`) в CI пока не подключаем: ему нужен `SHOREBIRD_TOKEN` и
  аккаунт. Когда понадобится — это отдельный джоб в `release.yaml` вместо `flutter build`.

---

## Шаг 5. Раздача dev-сборок (опционально)

Firebase App Distribution бесплатен и не требует Google Play Console. Важно: для раздачи **не
нужно** добавлять Firebase в само приложение (`google-services.json`, `firebase_options.dart`) —
пуш-уведомления в проекте остаются выключенными, App Distribution работает с готовым APK.

1. Firebase Console → проект → добавить Android-приложение с `applicationId`
   **`com.test.paywalldemo.dev`** (раздаём флейвор `development`).
2. App Distribution → Get started, создать группу `testers`.
3. Google Cloud → service account с ролью **Firebase App Distribution Admin** → JSON-ключ.
4. Секреты: `FIREBASE_APP_ID` (App ID из настроек приложения) и `FIREBASE_SERVICE_ACCOUNT`
   (содержимое JSON).

Шаг в конец джоба `build-android`:

```yaml
      - name: Distribute to testers
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          groups: testers
          file: build/app/outputs/flutter-apk/app-development-release.apk
          releaseNotes: ${{ github.event.head_commit.message }}
```

---

## Шаг 6. Наведение порядка

### Ветка по умолчанию

**Settings → General → Default branch → `develop`.** Тогда новые PR (и PR Dependabot) по
умолчанию открываются в `develop`, а не в `main`.

### Защита веток

**Settings → Rules → Rulesets** (или Branches → Add rule), два правила:

| | `develop` | `main` |
|---|---|---|
| Require a pull request before merging | да | да |
| Required status checks | `Analyze & test` | `Analyze & test`, `Release PR source`, `Build iOS (no codesign)` |
| Require branches to be up to date | да | да |
| Allowed merge methods | squash | merge commit |
| Block force pushes | да | да |

Имя проверки — это `name:` джоба. Оно появится в списке выбора только после первого запуска
workflow, поэтому защиту включайте **после** первого тестового PR.

### Бейдж в README

```markdown
![CI](https://github.com/evendelger/paywall_demo_app/actions/workflows/ci.yaml/badge.svg?branch=develop)
```

### Dependabot

`.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "pub"
    directory: "/"
    target-branch: "develop"
    schedule:
      interval: "weekly"
  - package-ecosystem: "pub"
    directory: "/packages/client_api"
    target-branch: "develop"
    schedule:
      interval: "weekly"
  - package-ecosystem: "github-actions"
    directory: "/"
    target-branch: "develop"
    schedule:
      interval: "monthly"
```

Без `target-branch` Dependabot шлёт PR в ветку по умолчанию — явное указание защищает от
случайных PR прямо в `main`.

---

## Тестовый PR: проверка, что CI работает

```bash
git push -u origin develop          # develop должен существовать на remote
git switch -c ci/github-actions
```

Коммиты:

1. `chore: track pubspec.lock` — удалить строку из `.gitignore`, добавить `pubspec.lock`
2. `chore: pin flutter version in pubspec`
3. `fix(build): include core/bloc in freezed generation` — `build.yaml`
4. `chore(android): bump gradle, agp, kotlin` — wrapper, `settings.gradle.kts`,
   `kotlinOptions` → `compilerOptions` в `app/build.gradle.kts`
5. `ci: add analyze & test workflow` — composite action + `ci.yaml`
6. `docs: add CI/CD setup guide` — этот файл

Открыть PR в `develop`. Ожидаемый сценарий:

1. **Первый прогон — красный** на `Check formatting` (8 неотформатированных файлов). Это
   доказывает, что проверка действительно ловит проблемы.
2. Коммит `style: apply dart format` → прогон **зелёный**.
3. (Опционально) временно убрать шаг `Generate code (app)` → `Analyze` падает на отсутствующих
   `*.freezed.dart`. Вернуть.
4. Включить защиту `develop` с `Analyze & test`, смёржить PR.
5. После мёржа push в `develop` запустит `Build iOS` (и `Build Android`, когда появятся секреты
   из шага 2) — APK скачивается из вкладки Summary запуска.

Дальше по шагам 2–4: отдельный PR на каждый этап, релизный PR `develop → main` и тег `v1.0.0`
как финальная проверка всей цепочки.

---

## Частые проблемы

**`Unable to determine Flutter version from pubspec.yaml`** — в `environment.flutter` диапазон
вместо точной версии.

**`Target of URI hasn't been generated: '....freezed.dart'`** на `Analyze` — не отработала
кодогенерация: файл вне глобов `build.yaml` (см. `CLAUDE.md`, раздел Codegen paths) или забыт
шаг генерации в `packages/client_api`. Локально такое не видно, потому что старые
сгенерированные файлы остаются на диске; воспроизводится через `git clean -xfd lib packages`
(осторожно: удалит все неотслеживаемые файлы в этих папках) и `make runner`.

**`Could not find an option named "delete-conflicting-output"`** — опечатка во флаге, правильно
`--delete-conflicting-outputs` (с `s`).

**`Unsupported class file major version` / `invalid source release: 21`** — в `setup-java`
указана Java 17, а проект требует 21.

**`Gradle build failed to produce an .apk file`** или «файл не найден» при upload — путь без
флейвора: правильно `app-development-release.apk` / `app-production-release.apk`,
AAB — `bundle/productionRelease/app-production-release.aab`.

**APK собрался, но не ставится на телефон** — не нашёлся `key.properties`, Gradle собрал
неподписанный release (в логе `⚠️ key.properties not found`). Проверьте секреты и
`storeFile=upload-keystore.jks` (путь от `android/app/`). Подпись проверяйте через
`apksigner verify --print-certs <apk>`, а не `keytool -printcert -jarfile`: тот не видит
v2-подпись и пишет `Not a signed jar file` даже на корректном APK.

**Тесты проходят локально, но падают в CI** — зависимость от порядка, времени или локали.
Повторите с seed из лога: `flutter test --test-randomize-ordering-seed <seed>`.

**iOS падает на `pod install`** — сбросьте кэш подов (поменяйте префикс ключа `pods-` в
workflow) или локально `make clean` и проверьте, что сборка проходит.

**Джоб «висит» на macOS** — очередь на macOS-раннеры в пиковые часы 5–10 минут, это нормально.

---

## Куда двигаться дальше

- **Матричная сборка флейворов** — `strategy.matrix.flavor: [development, production]` в
  `build-android`, чтобы на релизных PR проверялись оба.
- **Покрытие в PR** — комментарий с процентом покрытия из `coverage/lcov.info`.
- **Fastlane** — для стора избыточен без аккаунтов, но `Fastfile` стоит прочитать.
- **Shorebird в release-workflow** — `shorebird release` вместо `flutter build` + отдельный
  `workflow_dispatch` для `shorebird patch`.
- **Self-hosted runner на своём Mac** — только для приватного репозитория: в публичном любой PR
  с изменённым workflow выполнит произвольный код на вашей машине.

## Что из этого говорить на собеседовании

Честно можно сказать: настраивал GitHub Actions для Flutter-проекта с флейворами и
кодогенерацией — проверки на PR (формат, анализатор, тесты), модель веток `develop`/`main` с
защитой и проверкой источника релизных PR, подписанные Android-сборки, проверка iOS-компиляции,
обфускация с выгрузкой символов, релизы по тегам в GitHub Releases, раздача через Firebase App
Distribution.

Нельзя честно сказать, что настраивали публикацию в App Store и Google Play — для этого нужны
реальные аккаунты. Так и говорите: «стор-заливку не настраивал, но понимаю, как устроено:
service account для Play через `supply`, App Store Connect API Key и `match` для iOS».
