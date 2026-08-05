import 'package:flutter/foundation.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';

/// Текст страницы онбординга, отложенный до появления локализации
typedef OnboardingText = String Function(AppLocalizations l10n);

/// {@template onboarding_page_data}
/// Данные одной страницы онбординга.
///
/// Тексты хранятся резолверами, а не строками: список страниц статический,
/// а `AppLocalizations` доступна только из `BuildContext`.
/// {@endtemplate}
@immutable
final class OnboardingPageData {
  /// {@macro onboarding_page_data}
  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });

  /// Иллюстрация страницы
  final SvgGenImage icon;

  /// Заголовок
  final OnboardingText title;

  /// Пояснение под заголовком
  final OnboardingText description;

  /// Страницы в порядке показа
  static final List<OnboardingPageData> pages = [
    OnboardingPageData(
      icon: Assets.icons.star,
      title: (l10n) => l10n.onboardingTitle1,
      description: (l10n) => l10n.onboardingText1,
    ),
    OnboardingPageData(
      icon: Assets.icons.shield,
      title: (l10n) => l10n.onboardingTitle2,
      description: (l10n) => l10n.onboardingText2,
    ),
  ];
}
