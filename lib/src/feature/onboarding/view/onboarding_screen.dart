import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:paywall_demo/src/feature/onboarding/cubit/onboarding_cubit.dart';
import 'package:paywall_demo/src/feature/onboarding/model/onboarding_page_data.dart';
import 'package:paywall_demo/src/feature/onboarding/scope/onboarding_scope.dart';
import 'package:paywall_demo/src/feature/onboarding/widget/onboarding_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// {@template onboarding_screen}
/// Онбординг: несколько страниц с кнопкой «Далее» и «Продолжить»
/// на последней.
///
/// Экран не решает, куда вести пользователя дальше: он сохраняет флаг
/// прохождения и просит роутер перепроверить гарды — маршрут выбирает
/// цепочка гардов на ветке `/`.
/// {@endtemplate}
@RoutePage()
class OnboardingScreen extends StatefulWidget {
  /// {@macro onboarding_screen}
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  /// Страницы онбординга
  final List<OnboardingPageData> _pages = OnboardingPageData.pages;

  /// Индекс текущей страницы
  int _pageIndex = 0;

  bool get _isLastPage => _pageIndex == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _pageIndex = index);

  void _onContinuePressed() {
    if (_isLastPage) {
      OnboardingScope.complete(context);
      return;
    }

    unawaited(
      _pageController.nextPage(
        duration: Config.animationDuration,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) => !previous.isPassed && current.isPassed,
      // Флаг сохранён — пересчитываем гарды, дальше решают они
      listener: (context, state) => unawaited(context.router.reevaluateGuards()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) => OnboardingPage(
                    data: _pages[index],
                  ),
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 6,
                  activeDotColor: colorScheme.primary,
                  dotColor: colorScheme.outline,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  UIConfig.kSidePadding,
                  32,
                  UIConfig.kSidePadding,
                  UIConfig.kSidePadding,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    title: _isLastPage ? l10n.actionContinue : l10n.actionNext,
                    onPressed: _onContinuePressed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
