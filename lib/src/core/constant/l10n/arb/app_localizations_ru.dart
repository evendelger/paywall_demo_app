// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Paywall Demo';

  @override
  String get homeLabel => 'Главная';

  @override
  String get emptyText => 'Здесь пока пусто';

  @override
  String get onboardingTitle1 => 'Всё важное — в одном месте';

  @override
  String get onboardingText1 =>
      'Собирайте задачи, заметки и прогресс в едином пространстве, чтобы ничего не терялось.';

  @override
  String get onboardingTitle2 => 'Полный доступ по подписке';

  @override
  String get onboardingText2 =>
      'Откройте все возможности приложения и работайте без ограничений.';

  @override
  String get paywallTitle => 'Полный доступ';

  @override
  String get paywallSubtitle =>
      'Оформите подписку и пользуйтесь приложением без ограничений';

  @override
  String get paywallBenefit1 => 'Все функции без ограничений';

  @override
  String get paywallBenefit2 => 'Синхронизация между устройствами';

  @override
  String get paywallBenefit3 => 'Никакой рекламы';

  @override
  String get paywallDemoNotice => 'Покупка эмулируется: списаний не будет';

  @override
  String get planMonthlyLabel => 'Месяц';

  @override
  String get planYearlyLabel => 'Год';

  @override
  String planPricePerMonth(String price) {
    return '$price / мес';
  }

  @override
  String planPricePerYear(String price) {
    return '$price / год';
  }

  @override
  String planSavingsBadge(int percent) {
    return 'Выгода $percent %';
  }

  @override
  String planTrialBadge(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня бесплатно',
      many: '$days дней бесплатно',
      few: '$days дня бесплатно',
      one: '$days день бесплатно',
    );
    return '$_temp0';
  }

  @override
  String paywallTrialDisclaimer(int days, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Первые $days дня бесплатно, затем $price',
      many: 'Первые $days дней бесплатно, затем $price',
      few: 'Первые $days дня бесплатно, затем $price',
      one: 'Первый $days день бесплатно, затем $price',
    );
    return '$_temp0';
  }

  @override
  String paywallDisclaimer(String price) {
    return 'Списание $price сразу после оформления. Отменить можно в любой момент.';
  }

  @override
  String get actionStartFree => 'Начать бесплатно';

  @override
  String get actionRestorePurchases => 'Восстановить покупки';

  @override
  String get termsLabel => 'Условия использования';

  @override
  String get privacyLabel => 'Политика конфиденциальности';

  @override
  String get darkThemeLabel => 'Темная тема';

  @override
  String get lightThemeLabel => 'Светлая тема';

  @override
  String get systemThemeLabel => 'Cистемная тема';

  @override
  String get yesLabel => 'Да';

  @override
  String get noLabel => 'Нет';

  @override
  String get actionSend => 'Отправить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionConfirm => 'Подтвердить';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionClearAll => 'Очистить все';

  @override
  String get actionUpdateNow => 'Обновить сейчас';

  @override
  String get actionUpdate => 'Обновить';

  @override
  String get actionSkip => 'Пропустить';

  @override
  String get actionNext => 'Далее';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get authorizationLabel => 'Авторизация';

  @override
  String get authorizationRequiredText =>
      'Для просмотра необходимо авторизоваться';

  @override
  String get signUpLabel => 'Регистрация';

  @override
  String get exitButtonLabel => 'Выйти';

  @override
  String get nameLabel => 'Имя';

  @override
  String get lastNameLabel => 'Фамилия';

  @override
  String get patronymicNameLabel => 'Отчество';

  @override
  String get phoneNumberLabel => 'Номер телефона';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get consentText =>
      'Я принимаю условия <1>пользовательского соглашения</1>, <2>политики конфиденциальности</2> и <3>оферты</3>.';

  @override
  String overSomeSecondsText(String seconds) {
    return 'через $seconds сек';
  }

  @override
  String get error => 'Ошибка';

  @override
  String get errorUnknown => 'Неизвестная ошибка, попробуйте позже';

  @override
  String get errorSomethingWrong => 'Что-то пошло не так.\nПопробуйте позже.';

  @override
  String get errorGetData => 'Произошла ошибка при получении данных';

  @override
  String get errorEmptyHeader => 'Пусто';

  @override
  String get errorEmptyText => 'Нет данных для отображения.';

  @override
  String get errorUserUpdate => 'Не удалось обновить данные пользователя';

  @override
  String get errorUserGet => 'Не удалось получить информацию о пользователе';

  @override
  String get errorAuthSignOut => 'Не удалось выйти из аккаунта';

  @override
  String get errorAuthSendCode => 'Не удалось отправить код';

  @override
  String get errorAuthVerifyCode => 'Неверный код или ошибка проверки';

  @override
  String get errorPurchaseFailed =>
      'Не удалось оформить подписку. Попробуйте ещё раз';

  @override
  String get errorNothingToRestore => 'Покупки не найдены';

  @override
  String get updateDialogMandatoryTitle => 'Требуется обновление!';

  @override
  String get updateDialogMandatorySubtitle =>
      'Чтобы продолжить пользоваться приложением, необходимо установить новую версию. Обновление содержит важные улучшения безопасности и новые функции.';

  @override
  String get updateDialogMandatoryButton => 'Обновить сейчас';

  @override
  String get updateDialogSimpleTitle => 'Доступно новое обновление';

  @override
  String get updateDialogSimpleSubtitle =>
      'Мы добавили удобные функции и улучшили стабильность работы. Обновите приложение, чтобы всё работало ещё быстрее и удобнее!';

  @override
  String get updateDialogSimpleButtonPrimary => 'Обновить';

  @override
  String get updateDialogSimpleButtonSecondary => 'Напомнить позже';
}
