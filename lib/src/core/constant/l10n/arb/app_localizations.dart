import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ru')];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'Paywall Demo'**
  String get appName;

  /// No description provided for @homeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get homeLabel;

  /// No description provided for @emptyText.
  ///
  /// In ru, this message translates to:
  /// **'Здесь пока пусто'**
  String get emptyText;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ru, this message translates to:
  /// **'Всё важное — в одном месте'**
  String get onboardingTitle1;

  /// No description provided for @onboardingText1.
  ///
  /// In ru, this message translates to:
  /// **'Собирайте задачи, заметки и прогресс в едином пространстве, чтобы ничего не терялось.'**
  String get onboardingText1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ru, this message translates to:
  /// **'Полный доступ по подписке'**
  String get onboardingTitle2;

  /// No description provided for @onboardingText2.
  ///
  /// In ru, this message translates to:
  /// **'Откройте все возможности приложения и работайте без ограничений.'**
  String get onboardingText2;

  /// No description provided for @darkThemeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Темная тема'**
  String get darkThemeLabel;

  /// No description provided for @lightThemeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Светлая тема'**
  String get lightThemeLabel;

  /// No description provided for @systemThemeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Cистемная тема'**
  String get systemThemeLabel;

  /// No description provided for @yesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get yesLabel;

  /// No description provided for @noLabel.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get noLabel;

  /// No description provided for @actionSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get actionSend;

  /// No description provided for @actionDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get actionDelete;

  /// No description provided for @actionSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get actionConfirm;

  /// No description provided for @actionRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get actionRetry;

  /// No description provided for @actionClearAll.
  ///
  /// In ru, this message translates to:
  /// **'Очистить все'**
  String get actionClearAll;

  /// No description provided for @actionUpdateNow.
  ///
  /// In ru, this message translates to:
  /// **'Обновить сейчас'**
  String get actionUpdateNow;

  /// No description provided for @actionUpdate.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get actionUpdate;

  /// No description provided for @actionSkip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get actionSkip;

  /// No description provided for @actionNext.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get actionNext;

  /// No description provided for @actionContinue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get actionContinue;

  /// No description provided for @authorizationLabel.
  ///
  /// In ru, this message translates to:
  /// **'Авторизация'**
  String get authorizationLabel;

  /// No description provided for @authorizationRequiredText.
  ///
  /// In ru, this message translates to:
  /// **'Для просмотра необходимо авторизоваться'**
  String get authorizationRequiredText;

  /// No description provided for @signUpLabel.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get signUpLabel;

  /// No description provided for @exitButtonLabel.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get exitButtonLabel;

  /// No description provided for @nameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get nameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия'**
  String get lastNameLabel;

  /// No description provided for @patronymicNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Отчество'**
  String get patronymicNameLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get phoneNumberLabel;

  /// No description provided for @emailLabel.
  ///
  /// In ru, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get passwordLabel;

  /// No description provided for @consentText.
  ///
  /// In ru, this message translates to:
  /// **'Я принимаю условия <1>пользовательского соглашения</1>, <2>политики конфиденциальности</2> и <3>оферты</3>.'**
  String get consentText;

  /// No description provided for @overSomeSecondsText.
  ///
  /// In ru, this message translates to:
  /// **'через {seconds} сек'**
  String overSomeSecondsText(String seconds);

  /// No description provided for @error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;

  /// No description provided for @errorUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестная ошибка, попробуйте позже'**
  String get errorUnknown;

  /// No description provided for @errorSomethingWrong.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так.\nПопробуйте позже.'**
  String get errorSomethingWrong;

  /// No description provided for @errorGetData.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка при получении данных'**
  String get errorGetData;

  /// No description provided for @errorEmptyHeader.
  ///
  /// In ru, this message translates to:
  /// **'Пусто'**
  String get errorEmptyHeader;

  /// No description provided for @errorEmptyText.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных для отображения.'**
  String get errorEmptyText;

  /// No description provided for @errorUserUpdate.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить данные пользователя'**
  String get errorUserUpdate;

  /// No description provided for @errorUserGet.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить информацию о пользователе'**
  String get errorUserGet;

  /// No description provided for @errorAuthSignOut.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выйти из аккаунта'**
  String get errorAuthSignOut;

  /// No description provided for @errorAuthSendCode.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить код'**
  String get errorAuthSendCode;

  /// No description provided for @errorAuthVerifyCode.
  ///
  /// In ru, this message translates to:
  /// **'Неверный код или ошибка проверки'**
  String get errorAuthVerifyCode;

  /// No description provided for @updateDialogMandatoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Требуется обновление!'**
  String get updateDialogMandatoryTitle;

  /// No description provided for @updateDialogMandatorySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы продолжить пользоваться приложением, необходимо установить новую версию. Обновление содержит важные улучшения безопасности и новые функции.'**
  String get updateDialogMandatorySubtitle;

  /// No description provided for @updateDialogMandatoryButton.
  ///
  /// In ru, this message translates to:
  /// **'Обновить сейчас'**
  String get updateDialogMandatoryButton;

  /// No description provided for @updateDialogSimpleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Доступно новое обновление'**
  String get updateDialogSimpleTitle;

  /// No description provided for @updateDialogSimpleSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Мы добавили удобные функции и улучшили стабильность работы. Обновите приложение, чтобы всё работало ещё быстрее и удобнее!'**
  String get updateDialogSimpleSubtitle;

  /// No description provided for @updateDialogSimpleButtonPrimary.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get updateDialogSimpleButtonPrimary;

  /// No description provided for @updateDialogSimpleButtonSecondary.
  ///
  /// In ru, this message translates to:
  /// **'Напомнить позже'**
  String get updateDialogSimpleButtonSecondary;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
