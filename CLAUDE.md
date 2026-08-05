# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**This is a project template** (`flutter_starter`), not an application. The architecture is complete
and load-bearing; the feature set is deliberately minimal (a single Home screen). New apps are
started by copying the repo and running `make rename`.

Two consequences for any change made here:

1. **Preserve the architecture.** Patterns below are the product of this repo. Do not swap them for
   alternatives (no GetIt, no Riverpod, no go_router, no second `Talker`). If a pattern seems wrong,
   raise it — don't silently replace it.
2. **Don't add product features.** Screens, business logic, and API endpoints belong to the projects
   derived from this template. Additions here must be infrastructure or template scaffolding, and
   anything left as a stub is marked with `TODO(template):`.

## Commands

Flutter is pinned via FVM (`.fvmrc`, currently 3.44.1) — prefix commands with `fvm` when the global
Flutter doesn't match. Most tasks have Makefile targets.

```bash
# Start a new project from this template (package name, bundle id, app name, deep links)
make rename NAME=my_app BUNDLE_ID=com.company.myapp APP_NAME="My App" DOMAIN=myapp.com

# Run (flavor is mandatory — the app will not build without --dart-define-from-file)
make run                       # development
flutter run --flavor development --dart-define-from-file=config/development.json
flutter run --flavor production  --dart-define-from-file=config/production.json

# Codegen — after touching models, blocs, routes, drift schemas or assets
make runner                    # dart run build_runner build -d
make watch-runner

# Localization only
flutter gen-l10n

# Checks (run all three before declaring work done)
flutter analyze                # must be "No issues found!"
flutter test
dart fix --apply

# Build
make build-android             # appbundle, production
make build-ios                 # ipa, production
make shorebird-android         # / make shorebird-ios
```

Verification bar for any change: `flutter analyze` clean, `flutter test` green, and for changes
touching platform config or assets — an actual build
(`flutter build apk --debug --flavor development --dart-define-from-file=config/development.json`).

## Architecture

### Entry point & bootstrap

`lib/main.dart` → `MainRunner.run()` (`lib/src/feature/app/logic/runner.dart`):

1. Flutter bindings + native splash preserved
2. `FlutterError.onError` and `runZonedGuarded` wired to `AppLogger` (`lib/src/core/utils/logger.dart`)
3. `Bloc.observer = TalkerBlocObserver(talker: mainTalker)`
4. `DependenciesStorage.create()` — Dio, `AppDatabase`, `TokenStorage`, `FlutterSecureStorage`, `ClientApi`
5. `RepositoryStorage` — auth, user, settings, notifications repositories
6. Initial user loaded from the local DB, then `runApp(AppRoot(...))`
7. Any failure in that block → `runApp(AppError(error: error))`

New global initialization goes inside this sequence — not into widget `initState`.

### Layer layout

```
lib/src/
  core/          # Infrastructure shared by all features
    api/         #   ApiClient (Dio config), AuthInterceptor
    bloc/        #   DataBloc / PaginatedDataBloc base classes
    constant/    #   Config, UIConfig, generated assets, l10n
    database/    #   Drift AppDatabase + typed SharedPreferences DAOs
    extension/   #   BuildContext / Dio / String / num extensions
    model/       #   Exceptions, shared models, Dependencies & Repository storages
    router/      #   AppRouter, router builder, observer, custom pages
    theme/       #   AppTheme, AppPalette, typography, animations
    utils/       #   logger (mainTalker), converters, modal helpers
    widget/      #   Reusable App* widgets + scope wrappers
  feature/<name>/
    bloc/        # BLoC + freezed event/state (part files)
    cubit/       # Cubit, when a full BLoC is overkill
    data/        #   repository/ + mappers/ (DTO ↔ domain)
    database/    # Feature DAO / drift table
    model/       # freezed domain models, feature exceptions
    router/      # <Feature>Routes with tabRoutes / overlayRoutes
    scope/       # <Feature>Scope — DI + typed accessors
    view/        # Screens annotated with @RoutePage()
    widget/      # Feature-local widgets
```

Current features: `app`, `auth`, `user`, `settings`, `notification`, `home`.

Direction of dependencies: `feature/*` may import `core/*`; `core/*` must **not** import `feature/*`.
Cross-feature imports are allowed only for `model/`, `data/` and `scope/` — never another feature's
`view/` or `bloc/` internals.

### Dependency injection — scopes, not a service locator

Manual `InheritedWidget` scopes, composed in `AppRoot`:

```
DependenciesScope → RepositoryScope → AppScope( SettingsScope → AuthScope ) → AppConfiguration
                                                                              └ UserScope (in AppWrapperPage)
```

Access through the `BuildContext` extensions in `core/extension/src/build_context.dart`:

```dart
context.dependencies   // IDependenciesStorage
context.repository     // IRepositoryStorage — context.repository.user, .auth, ...
context.database       // AppDatabase
context.l10n           // AppLocalizations
context.theme / context.textTheme / context.colorScheme
```

A feature scope exposes state through `BlocScope`/`CubitScope` helpers rather than raw
`context.watch`, so widgets depend on values, not on bloc types:

```dart
class SomeScope extends StatelessWidget {
  static const BlocScope<SomeEvent, SomeState, SomeBloc> _scope = BlocScope();

  static ScopeData<Item?> get itemOf => _scope.select((state) => state.item);
  static NullaryScopeMethod get refresh =>
      _scope.nullary((context) => const SomeEvent.refresh());
}

// usage: final item = SomeScope.itemOf(context, listen: true);
```

New repositories are registered in `RepositoryStorage`; new low-level clients/storages in
`DependenciesStorage`. Both expose an `I*` interface — depend on the interface, not the impl.

### Navigation (Auto Route)

`AppRouter` (`core/router/app_router.dart`) is the root router, Cupertino transitions by default,
`replaceInRouteName: 'Screen|Page|Shell|Sheet,Route'` — so `HomeScreen` → `HomeRoute`.

```
AuthRoutes              → /auth/login   (flat, not the start destination)
AppRoutes (/)           → AppWrapperPage (provides UserScope)
  └ MainRoutes          → MainWrapperPage (provides AppListeners)
      └ MainRoute       → MainShell (AutoTabsRouter, currently one Home tab)
```

Each feature owns a `<Feature>Routes` class exposing `tabRoutes` (children of the tab shell) and,
when needed, `overlayRoutes` (pushed over the tabs). `MainRoutes` composes them.

**Adding a tab:** create the feature → add `...<Feature>Routes.tabRoutes` to `MainRoutes.routes` →
add the route to `MainShell._tabs` and an item to `AppBottomNavBar.items` (keep the order identical;
the bar renders only when there is more than one tab) → `make runner`.

`app_router.gr.dart` is generated. Never hand-edit it, and always rerun `build_runner` after touching
`@RoutePage()` or `@AutoRoute` — a stale `.gr.dart` is invisible to `flutter analyze` because
generated files are excluded from analysis, and it breaks the build instead.

### State management (BLoC)

- Reusable bases in `core/bloc/`: `DataBloc<T, P>` (one resource, `DataEvent.fetch/update`,
  `DataState.idle/processing/successful/error`) and `PaginatedDataBloc<T, P>` for paginated lists
  (`AppPaginatedCustomScrollView` is its widget counterpart).
- Feature blocs either extend those bases or are plain `Bloc`s with freezed event/state in
  `part 'x_event.dart'` / `part 'x_state.dart'`.
- States are freezed sealed classes with an `idle / processing / successful / error` shape and
  convenience getters (`isProcessing`, `error`, …). Keep carried data on every state so the UI
  doesn't flicker on transitions.
- Concurrency is explicit: `bloc_concurrency` transformers (`sequential`, `droppable`, `restartable`).
- Subscriptions are cancelled in `close()` (`cancel_subscriptions` and `close_sinks` are lint errors).
- `SetStateBlocMixin` exists for pushing states from an external stream.

### Data layer & error handling

Repositories return **domain models**, never DTOs. Mapping lives in `data/mappers/`
(`user_api_mapper.dart` — DTO → domain, `user_db_mapper.dart` — drift row ↔ domain).

Errors follow one hierarchy: `AppException` (`core/model/exceptions/`) → `ApiException`,
`NetworkException`, `UnauthorizedException`, plus feature exceptions such as `UserException`.
Repositories convert Dio failures with the `DioX.throwCustom` extension:

```dart
try {
  final response = await _client.getUser();
  ...
} on DioException catch (error) {
  error.throwCustom(
    error.stackTrace,
    unknownError: baseException,
    errorBuilder: (message) => UserException(UserErrorType.unknown, message),
  );
}
```

Blocs catch the typed exception and put it into the error state; the UI localizes it via the
`*_exception_localize_x.dart` extensions and shows it through `context.showMessage(...)`
(see `UserListener`). Never surface a raw `DioException` or `toString()` to the user.

### Database

- **Drift** — `AppDatabase` in `core/database/drift/`, tables and `@DriftAccessor` DAOs under
  `feature/<name>/database/`. Every DAO implements an `I*Dao` interface. Schema change → bump
  `schemaVersion`, extend `MigrationStrategy.onUpgrade`, rerun `build_runner`.
- **SharedPreferences** — typed DAOs only (`TypedPreferencesDao`, see `SettingsDao`), never raw
  `getString`/`setInt` at call sites. Keys are namespaced with `Config.prefsNamespace`.

### API client

`packages/client_api` is a separate package: Retrofit `ClientApi` + freezed/json DTOs. Endpoints and
DTOs are added there, then `build_runner` is run **inside that package**. `core/api/ApiClient` only
configures Dio (timeouts, headers, `TalkerDioLogger`); `AuthInterceptor` handles the token and logout.

`config/*.json` ship with `example.com` placeholders — each derived project replaces them. Values are
read only through `Config` (`String.fromEnvironment`), never inline in code.

### Authentication — optional by design

Auth is **not required**: the app starts on Home, and an unauthenticated user is a normal "guest"
(`AuthScope.userOf`, `UserScope.userOf`, and `UserState.user` are nullable). Never reintroduce a
placeholder/fake `User` to dodge a null check.

To make login mandatory in a derived project: attach `AuthGuard` to a route branch (commented example
in `AppRoutes.root`), uncomment the redirect in `AppListeners`, implement sign-in in `AuthRepository`
(marked `TODO(template)`) and the form in `LoginScreen`.

### Push notifications — opt-in

`lib/src/feature/notification/` and the Firebase dependencies stay in the project, but **nothing is
initialized** and there are no `firebase_options.dart` / `google-services.json` /
`GoogleService-Info.plist`. To enable: run `flutterfire configure`, uncomment the
`Firebase.initializeApp()` + `NotificationService.setup()` block in `MainRunner.run()`, and switch to
the `DefaultFirebaseOptions` variant in `notification_service.dart` (both `TODO(template)`).

Keep this feature dormant in the template — do not wire it into bootstrap here.

### Theme & assets

`AppTheme` builds a Material 3 theme from `AppPalette` + `_createTextTheme()`. The system font is the
default: a project font is declared in `pubspec.yaml` and then referenced as
`fontFamily: FontFamily.<name>` in `_buildTheme()`. Colors go into `AppPalette`, never as inline
`Color(0x...)` in widgets; sizes/paddings/radii into `UIConfig`.

`assets/images/` and `assets/splash/` ship empty (`.gitkeep` — required, an empty declared asset dir
breaks the build); `assets/icons/` holds a generic SVG set. Assets are referenced through generated
Flutter Gen constants (`Assets.icons.home.svg()`), never by string path.

### Localization

ARB files in `lib/src/core/constant/l10n/arb/`, template `app_ru.arb`, `ru` is the only locale.
All user-facing strings go through `context.l10n` — no hardcoded UI text. Keys stay generic
(template-level), not product-specific. After editing: `flutter gen-l10n` (or `make runner`).
A new locale needs `app_<locale>.arb` plus an entry in `CFBundleLocalizations` in `ios/Runner/Info.plist`.

### Codegen paths (build.yaml)

`build.yaml` restricts builders to globs — **a file outside them is silently skipped by codegen**,
which is the most common "why isn't my `.freezed.dart` generated" trap:

- `freezed` → `feature/**/model/**`, `core/model/models/**`, `feature/**/bloc/**`, `feature/**/cubit/**`
- `json_serializable` → `feature/**/model/**`, `core/model/models/**`
- `drift_dev` → `feature/**/database/**`, `core/database/drift/**`

Generated, never hand-edited: `*.g.dart`, `*.freezed.dart`, `*.gr.dart`,
`lib/src/core/constant/gen/`, `lib/src/core/constant/l10n/arb/app_localizations*.dart`.

### Rename tooling

`tool/rename.dart` (via `make rename`) rewrites the Dart package name and all imports, the pubspec
description, `Config.appName` / `Config.prefsNamespace`, the ARB `appName`, Android
namespace/applicationId/`MainActivity` package **and its directory**, iOS bundle ids and display
names, and the deep-link scheme/domain. It reads current values from the project rather than
hardcoding them, so it stays correct after the first rename.

Anything newly hardcoding the app name, bundle id, scheme or domain must also be handled there.

`docs/NEW_PROJECT.md` is the checklist for starting a real project from this template — including
which parts of **this file** must be rewritten once the template becomes an actual app. Keep the two
in sync: a change to the template-only framing here belongs in that checklist too.

## Conventions

- **Comments and doc comments are in Russian**, matching the codebase. Public APIs get
  `/// {@template name}` … `/// {@macro name}` blocks, as in the existing widgets and scopes.
- Interfaces are prefixed `I` (`IAuthRepository`, `IUserDao`); implementations are `final class`.
- Widgets are `App*` in `core/widget/`; screens are `*Screen`, tab shells `*Shell`,
  bottom sheets `*Sheet`, route wrappers `*Page` (matters — `replaceInRouteName` derives route names
  from these suffixes).
- Scope accessors are named `<thing>Of` and return `ScopeData<T>`.
- One public class per file, `snake_case` filenames; barrel files (`widget.dart`, `utils.dart`,
  `extension.dart`, `model.dart`) re-export a directory — add new files to the matching barrel.
- Logging goes exclusively through `mainTalker` from `core/utils/logger.dart`. No `print`, no
  `debugPrint`, no second logger package.
- Async: `unawaited(...)` for deliberately un-awaited futures; never swallow an error silently —
  either handle it or pass it to `mainTalker`.
- Stubs are marked `TODO(template):` and must explain what to do to activate them.

### Linting

`very_good_analysis` with a strict override list in `analysis_options.yaml`. Escalated to **errors**:
`avoid_dynamic_calls`, `cancel_subscriptions`, `close_sinks`, `always_declare_return_types`,
`avoid_returning_null_for_future`, `avoid_setters_without_getters`. Generated files are excluded from
analysis — which is exactly why stale generated code must be caught by building, not by `analyze`.

Prefer fixing the code over adding `// ignore:`. When an ignore is unavoidable, keep it on the
narrowest scope and add a one-line reason in Russian.
