# План реализации — Paywall Demo

Задание: `docs/Тестовое задание.txt`. Нужно приложение с флоу
**Онбординг → Paywall → Главный экран** и сохранением состояния подписки между
запусками. Реальный биллинг и бэкенд не требуются.

Отправной точкой взят внутренний Flutter-шаблон: инфраструктура (DI, роутинг,
BLoC-базы, тема, набор виджетов, логирование, тесты) уже готова, продуктовых
фич в нём нет вообще. Поэтому работа делится на «взять как есть» и «дописать».

---

## 1. Целевой флоу

Маршрутизацией управляют **гарды Auto Route** на ветке `/`. Экраны не решают,
куда идти дальше — они меняют состояние и просят роутер перепроверить гарды.

```
навигация в `/`
   │
   ├─ OnboardingGuard: онбординг не пройден ──→ redirect /onboarding
   ├─ SubscriptionGuard: подписки нет ────────→ redirect /paywall
   └─ оба пропустили ─────────────────────────→ MainShell → Home

/onboarding ─«Продолжить»→ флаг сохранён → reevaluateGuards() → /paywall
/paywall ────«Продолжить»→ покупка (эмуляция ~1.2 с) → reevaluateGuards() → Home
```

Правила, которые не должны сломаться:

1. Гард — единственное место, где принимается решение о стартовом экране.
   Никаких промежуточных экранов-загрузчиков и «мигания» главного экрана поверх
   сплэша.
2. Начальные состояния `SettingsBloc` и `SubscriptionBloc` читаются из
   `SharedPreferences` **синхронно в конструкторе** — на момент первой проверки
   гарда данные уже на руках.
3. Покупка эмулируется в репозитории; интерфейс репозитория держим таким, чтобы
   в него можно было завести реальный биллинг без правок UI и блока.
4. Флаг онбординга и статус подписки — независимые: пройденный онбординг не даёт
   подписку.
5. Ничего в флоу не зависит от сети и `API_BASE_URL`.

---

## 2. Что берём из шаблона как есть

| Что | Где | Зачем в этом проекте |
|---|---|---|
| Бутстрап `MainRunner.run()` | `feature/app/logic/runner.dart` | без изменений: репозитории уже готовы до первого кадра |
| `AuthGuard` как образец | `feature/auth/router/auth_guard.dart` | по нему пишутся `OnboardingGuard` и `SubscriptionGuard` |
| DI через scopes | `core/widget/scope/`, `feature/app/widget/app_scope.dart` | сюда добавляется `SubscriptionScope` |
| `BlocScope` / `ScopeData` | `core/widget/scope/bloc_scope.dart` | доступ к статусу подписки из виджетов |
| Auto Route + `AppRouter` | `core/router/` | флэт-роуты `/onboarding`, `/paywall` рядом с `/auth/login` |
| BLoC + freezed + `bloc_concurrency` | `core/bloc/`, `feature/settings/bloc/` | образец для `SubscriptionBloc` |
| `TypedPreferencesDao` + `SettingsDao` | `core/database/shared_preferences/` | типизированное хранение флагов и подписки |
| Иерархия `AppException` | `core/model/exceptions/` | `SubscriptionException` наследуется отсюда |
| `context.showMessage` + `*_localize_x` | `core/extension/src/messenger.dart` | ошибка покупки, «покупки не найдены» |
| `UrlLauncher.openUrl` | `core/utils/url_launcher.dart` | ссылки на условия и политику с пейвола |
| Виджеты `AppButton`, `AppCard`, `AppLoader`, `AppTopBar` | `core/widget/` | весь UI paywall/онбординга собирается из них |
| Тема `AppTheme` / `AppPalette` / `UIConfig` | `core/theme/`, `core/constant/config.dart` | цвета и размеры без инлайна |
| Локализация `app_ru.arb` + `context.l10n` | `core/constant/l10n/` | все тексты онбординга и paywall |
| Логирование `mainTalker` + `TalkerBlocObserver` | `core/utils/logger.dart` | видно переходы стейтов на скринкасте |
| `smooth_page_indicator`, `intl` (уже в pubspec) | — | индикатор страниц онбординга, формат цен |
| `test/helpers/pump_app.dart` | `test/` | база для виджет-тестов |

**Новых зависимостей не требуется.** Firebase/push, Drift, Retrofit-клиент и
авторизация остаются в проекте, но не участвуют во флоу (см. CLAUDE.md).

---

## 3. Новые фичи

### 3.1 `feature/onboarding` — онбординг

| Файл | Содержимое |
|---|---|
| `model/onboarding_page_data.dart` | `final class OnboardingPageData` (иконка, заголовок, описание) + `const` список из 2 страниц. Без codegen — данные статические |
| `view/onboarding_screen.dart` | `@RoutePage()` `OnboardingScreen`: `PageView` + `SmoothPageIndicator`, кнопка «Далее» на первой странице и «Продолжить» на последней |
| `widget/onboarding_page.dart` | одна страница: иллюстрация (иконка + градиент, без ассетов), заголовок, текст |
| `router/onboarding_routes.dart` | `OnboardingRoutes.routes` → путь `/onboarding` |
| `router/onboarding_guard.dart` | `OnboardingGuard(SettingsBloc)`: `state.data.isOnboardingPassed ? resolver.next() : resolver.redirectUntil(const OnboardingRoute())` |

Завершение: `SettingsScope.setOnboardingPassed(context, true)`; переход делает не
экран, а `BlocListener` на `isOnboardingPassed == true` → `context.router.reevaluateGuards()`.

### 3.2 `feature/subscription` — paywall и состояние подписки

| Файл | Содержимое |
|---|---|
| `model/subscription_plan.dart` | `enum SubscriptionPlan { monthly, yearly }` с полями `price`, `months`, `trialDays`. Ориентир: 399 ₽/мес; 2 990 ₽/год с 7-дневным триалом. Геттеры: `hasTrial`, `pricePerMonth` (`price / months`), `savingsPercent` — считается из `pricePerMonth` относительно месячного тарифа, **ни разу не хардкодится вторым числом** |
| `model/subscription_status.dart` | freezed `SubscriptionStatus` (`isActive`, `plan`, `purchasedAt`, `isTrial`) + `const SubscriptionStatus.inactive()` |
| `model/subscription_exception.dart` | `SubscriptionException` + `SubscriptionErrorType { purchaseFailed, nothingToRestore, unknown }` |
| `extension/subscription_exception_localize_x.dart` | локализация типов ошибок |
| `database/subscription_dao.dart` | `ISubscriptionDao` / `SubscriptionDao extends TypedPreferencesDao`, entries: `isActive` (bool), `plan` (string), `purchasedAt` (int, millis), `isTrial` (bool). Имя DAO `subscription`, префикс ключей — `Config.prefsNamespace` |
| `data/repository/subscription_repository.dart` | `ISubscriptionRepository`: `SubscriptionStatus get currentStatus` (синхронно, для начального состояния блока), `Future<SubscriptionStatus> purchase(SubscriptionPlan)` (задержка ~1.2 с + запись, триал проставляется из `plan.hasTrial`), `Future<SubscriptionStatus> restore()` (перечитывает prefs, кидает `nothingToRestore`, если пусто), `Future<void> clear()` (сброс для демо) |
| `bloc/subscription_bloc.dart` + `subscription_event.dart` + `subscription_state.dart` | начальное состояние — `currentStatus` из репозитория + **`selectedPlan = SubscriptionPlan.yearly`**; события `selectPlan`, `purchase`, `restore`, `reset`; состояние несёт `status` и `selectedPlan` на всех ветках (`idle/processing/successful/error`). `purchase` и `restore` — `droppable`, двойной тап не покупает дважды |
| `scope/subscription_scope.dart` | `SubscriptionScope`: `statusOf`, `isActiveOf`, `selectedPlanOf`, `isProcessingOf`; методы `selectPlan`, `purchase`, `restore`, `reset` |
| `view/paywall_screen.dart` | `@RoutePage()` `PaywallScreen` — состав ниже |
| `widget/subscription_plan_card.dart` | карточка тарифа: название, цена за период, **цена в пересчёте на месяц** (у годового), **бейдж экономии**, **бейдж триала**, состояние «выбран» |
| `widget/paywall_benefits.dart` | список преимуществ (иконка + строка) |
| `widget/paywall_legal_links.dart` | **ссылки «Условия использования» и «Политика конфиденциальности»** → `UrlLauncher.openUrl(Config.termsUrl / Config.privacyUrl)` |
| `widget/subscription_listener.dart` | `BlocListener`: подписка стала активной → `context.router.reevaluateGuards()`; ошибка → `context.showMessage(...)` с локализованным текстом |
| `router/subscription_routes.dart` | `SubscriptionRoutes.routes` → путь `/paywall` |
| `router/subscription_guard.dart` | `SubscriptionGuard(SubscriptionBloc)`: `state.status.isActive ? resolver.next() : resolver.redirectUntil(const PaywallRoute())` |

#### Обязательный состав экрана `/paywall`

Чек-лист — всё перечисленное должно быть на экране:

- [ ] **Триал.** Бейдж «7 дней бесплатно» на тарифе с триалом; CTA меняется на
      «Начать бесплатно», когда выбран такой тариф, и на «Продолжить» — когда нет.
- [ ] **Цена в пересчёте на месяц у годового.** Под ценой года — «249 ₽/мес»,
      значение считается из `pricePerMonth`, а не пишется строкой.
- [ ] **Процент экономии у годовой подписки.** Бейдж «Экономия 38 %», значение
      считается из цен обоих тарифов.
- [ ] **Годовой тариф выбран по умолчанию** — начальное состояние `SubscriptionBloc`.
- [ ] **Кнопка «Восстановить покупки»** — шлёт `SubscriptionEvent.restore()`;
      нашли активную подписку → уходим на главный, не нашли → тост
      «Покупки не найдены».
- [ ] **Ссылки на условия и политику конфиденциальности** — внизу экрана,
      открываются во внешнем браузере.
- [ ] Кнопка «Продолжить» с лоадером на время эмуляции покупки.
- [ ] Сноска: что списывается после триала и что покупка эмулируется.

Цены и проценты в UI берутся только из `SubscriptionPlan` — если поменять цену в
enum, весь экран пересчитается сам.

---

## 4. Правки существующего кода

1. **`feature/settings/data/repository/settings_repository.dart`** — `defaultData`
   сейчас возвращает захардкоженный `isOnboardingPassed: true`, а реальное чтение
   закомментировано. Читать из DAO: `_settingsDao.isOnboardingPassed.value ?? false`.
   Без этого `OnboardingGuard` всегда пропускает и онбординг не показывается.
2. **`core/model/storages/repository_storage.dart`** — добавить
   `ISubscriptionRepository get subscription` в интерфейс и `late final` в реализацию
   (DAO строится из уже прокинутого `_sharedPreferences`).
3. **`feature/app/widget/app_scope.dart`** — добавить `SubscriptionScope` в
   композицию (внутри `SettingsScope`, рядом с `AuthScope`), `lazy: false` —
   блок должен существовать до первой проверки гарда.
4. **`feature/app/router/app_routes.dart`** — `AppRoutes` принимает
   `List<AutoRouteGuard> guards` и вешает их на корневой `AutoRoute('/')`
   (в шаблоне для этого уже оставлен закомментированный пример). Порядок:
   `[OnboardingGuard, SubscriptionGuard]`.
5. **`core/router/app_router.dart`** — `AppRouter({List<AutoRouteGuard> rootGuards})`,
   прокидывает их в `AppRoutes`; плюс `...OnboardingRoutes.routes` и
   `...SubscriptionRoutes.routes` в корневых роутах. Гарды висят только на `/`,
   у `/onboarding` и `/paywall` гардов нет — циклов не будет.
6. **`core/router/app_router_builder.dart`** — принять
   `List<AutoRouteGuard> rootGuards` и передать в `AppRouter(...)`. Тип из
   auto_route, импорта фич в `core` не появляется.
7. **`feature/app/widget/app_configuration.dart`** — сделать `StatefulWidget`:
   в `initState` собрать гарды из блоков (`context.read<SettingsBloc>()`,
   `context.read<SubscriptionBloc>()`) и передать в `AppRouterBuilder`. Гарды
   создаются один раз — блоки живут выше и не пересоздаются.
8. **`feature/home/view/home_screen.dart`** — вместо заглушки: плашка активной
   подписки (тариф, признак триала, дата покупки) и список карточек контента.
   Плюс кнопка «Сбросить состояние» под `Config.environment.isDevelopment` —
   шлёт `reset` в оба блока и вызывает `reevaluateGuards()`, чтобы на скринкасте
   повторно показать весь флоу без переустановки приложения.
9. **`core/constant/config.dart` + `config/development.json` / `config/production.json`** —
   добавить `TERMS_URL` и `PRIVACY_URL` (плейсхолдеры на `example.com`) и
   геттеры `Config.termsUrl` / `Config.privacyUrl`. Инлайнить ссылки в виджете нельзя.
10. **`core/utils/price_formatter.dart`** (новый) + экспорт в `core/utils/utils.dart` —
    формат цены через `intl` (`NumberFormat.currency(locale: 'ru', symbol: '₽',
    decimalDigits: 0)`), чтобы «2 990 ₽» и «249 ₽/мес» не собирались строками по месту.
11. **`core/constant/l10n/arb/app_ru.arb`** — новые ключи:
    `onboardingTitle1/2`, `onboardingText1/2`, `actionContinue`,
    `paywallTitle`, `paywallSubtitle`, `paywallBenefit1..3`,
    `planMonthlyLabel`, `planYearlyLabel`, `planPricePerMonth`,
    `planSavingsBadge`, `planTrialBadge`, `actionStartFree`,
    `actionRestorePurchases`, `paywallDisclaimer`, `termsLabel`, `privacyLabel`,
    `subscriptionActiveLabel`, `subscriptionTrialLabel`, `subscriptionSince`,
    `errorPurchaseFailed`, `errorNothingToRestore`, `actionResetState`.
    Затем `flutter gen-l10n`.
12. **`README.md`** — переписан под проект: архитектура, структура, что улучшил бы
    (требование ТЗ, п. 3 «Что прислать»).
13. **`docs/NEW_PROJECT.md`** — чек-лист старта из шаблона, уже отработан.
    Оставляем как есть либо удаляем при финальной уборке — на код не влияет.

`MainRunner.run()` менять не нужно: репозитории создаются до `runApp`, блоки
читают из них синхронно, гардам этого достаточно.

---

## 5. Как работает маршрутизация на гардах

Механика Auto Route 11.1.0 (проверено по исходникам пакета):

- Гард получает `NavigationResolver`. Пропуск — `resolver.next()`, разворот —
  `resolver.redirectUntil(const PaywallRoute())`. `redirectUntil` — **временный**
  редирект: резолвер остаётся незавершённым, а когда он всё-таки завершится
  через `next(true)`, редиректный роут сам снимается со стека.
- Разбудить незавершённый резолвер можно `context.router.reevaluateGuards()` —
  он повторно прогоняет цепочку гардов и, если состояние изменилось, доводит
  исходную навигацию в `/` до конца.
- Отсюда правило: **`reevaluateGuards()` вызывается из `BlocListener` на нужное
  состояние, а не сразу после `add(event)`.** Запись в prefs и `emit` асинхронные;
  вызов сразу после `add` перепроверит гард на старом состоянии и никуда не уведёт.

Почему гарды, а не вычисление маршрута в бутстрапе:

- решение живёт в одном месте и работает не только на холодном старте — истечение
  подписки, сброс состояния, выход из аккаунта обрабатываются тем же кодом;
- ветка `/` защищена целиком, включая вложенные табы и будущие overlay-роуты:
  прямой переход или диплинк вглубь приложения тоже пройдёт через гард;
- в шаблоне уже есть `AuthGuard` и закомментированный слот `guards:` в
  `AppRoutes.root` — подход не изобретается, а достраивается.

Плата: начальные состояния блоков обязаны быть корректными синхронно (п. 2
раздела «Правила»), иначе первая проверка гарда отработает на пустых данных.
`SettingsBloc` так уже устроен (`super(SettingsState.idle(data: repo.defaultData))`),
`SubscriptionBloc` пишем так же.

Альтернатива на будущее: `config(reevaluateListenable: ReevaluateListenable.stream(...))`
— роутер сам перепроверяет гарды на каждый эмит блока, ручные вызовы не нужны.
Не берём сейчас: слушатель нужно создавать и диспозить вручную, а перепроверка
будет дёргаться в том числе на промежуточном `processing`.

---

## 6. Порядок работ

- [ ] **Этап 1. Хранение.** `SubscriptionDao` → `SubscriptionRepository` →
      регистрация в `RepositoryStorage`; фикс `SettingsRepository.defaultData`
- [ ] **Этап 2. Состояние.** `SubscriptionPlan`, `SubscriptionStatus`,
      `SubscriptionException`, `SubscriptionBloc` (годовой по умолчанию,
      синхронное начальное состояние), `SubscriptionScope` → `make runner`
- [ ] **Этап 3. Гарды и роутинг.** `OnboardingGuard`, `SubscriptionGuard`,
      правки `AppRoutes` / `AppRouter` / `AppRouterBuilder` / `AppConfiguration` /
      `AppScope` → `make runner`
- [ ] **Этап 4. Онбординг.** фича + роут `/onboarding` + `reevaluateGuards()` по
      факту сохранения флага → `make runner`
- [ ] **Этап 5. Paywall.** экран по чек-листу из §3.2, карточки тарифов,
      восстановление покупок, легальные ссылки, листенер → `make runner`
- [ ] **Этап 6. Главный экран.** контент, плашка подписки, dev-сброс
- [ ] **Этап 7. Конфиг и локализация.** `TERMS_URL` / `PRIVACY_URL`,
      `price_formatter`, ключи в `app_ru.arb` → `flutter gen-l10n`
- [ ] **Этап 8. Тесты и проверка.** тесты ниже + `flutter analyze` +
      `flutter test` + прогон на устройстве, включая перезапуск после покупки
- [ ] **Этап 9. README** под требования ТЗ

Кодогенерация нужна после этапов 2, 3, 4, 5 (freezed-модели и блоки, `@RoutePage`).
Напоминание из `build.yaml`: файл вне glob'ов молча не генерируется, а устаревший
`.gr.dart` не ловится `flutter analyze` — только сборкой.

---

## 7. Тесты

| Тест | Проверяет |
|---|---|
| `test/feature/subscription/model/subscription_plan_test.dart` | `pricePerMonth` и `savingsPercent` считаются из цен; поменяли цену — цифры на экране поедут вслед, а не разъедутся |
| `test/feature/subscription/data/subscription_repository_test.dart` | покупка пишет статус в prefs, `currentStatus` его читает, `restore()` без покупки кидает `nothingToRestore`, `clear()` сбрасывает. `SharedPreferences.setMockInitialValues({})` |
| `test/feature/subscription/bloc/subscription_bloc_test.dart` | годовой тариф выбран в начальном состоянии; начальный статус поднимается из репозитория синхронно; `purchase` даёт `processing → successful`; повторный `purchase` во время обработки отбрасывается |
| `test/feature/app/start_flow_test.dart` | цепочка гардов целиком: три комбинации prefs (пусто / онбординг пройден / подписка активна) → на экране `OnboardingScreen`, `PaywallScreen`, `HomeScreen` соответственно |
| `test/feature/subscription/view/paywall_screen_test.dart` | по чек-листу §3.2: обе карточки, бейдж триала, цена за месяц у годового, бейдж экономии, годовой выбран по умолчанию, тап по месячному меняет выбор, «Восстановить покупки» шлёт событие, ссылки на условия и политику присутствуют |
| `test/feature/home/view/home_screen_test.dart` (правка) | существующий тест ждёт `Config.appName` в тексте — обновить под новый контент |

---

## 8. Вне объёма

Осознанно не делаем — но проговариваем на видео и в README:

- реальный биллинг (`in_app_purchase` / RevenueCat), валидация чеков, настоящее
  восстановление покупок из стора (сейчас `restore()` читает локальные prefs);
- бэкенд, синхронизация подписки между устройствами, срок действия, автопродление
  и реальное окончание триала;
- авторизация (остаётся гостевой), push-уведомления (остаются выключенными);
- вторая локаль и тёмная тема (`AppTheme.darkTheme` сейчас = светлая);
- анимации переходов сверх дефолтных Cupertino.

## 9. Что улучшил бы при большем времени (для README)

- Подписка как источник правды из стора + серверная валидация, `expiresAt` и
  реакция на истечение в рантайме — гарды для этого уже на месте, достаточно
  подключить `reevaluateListenable`.
- A/B тарифов и конфиг пейвола с сервера — сейчас цены и триал живут в enum.
- Тёмная тема и адаптивность пейвола под маленькие экраны.
- Аналитика воронки: показ онбординга → показ пейвола → выбор тарифа → покупка →
  восстановление.
- Golden-тесты на paywall и интеграционный тест всего флоу, включая перезапуск.

---

## 10. Приёмка

- [ ] `flutter analyze` → «No issues found!»
- [ ] `flutter test` → зелёный
- [ ] `make run`: первый запуск → онбординг; «Продолжить» → paywall; покупка →
      главный экран; **kill + повторный запуск → сразу главный экран**
- [ ] на пейволе присутствуют все шесть обязательных элементов из §3.2
- [ ] «Восстановить покупки» без покупки → тост, после покупки → главный экран
- [ ] ссылки на условия и политику открываются во внешнем браузере
- [ ] сброс состояния (dev-кнопка) → флоу повторяется с онбординга
- [ ] нет хардкод-строк в UI, нет инлайновых `Color(0x...)`, нет `print`
