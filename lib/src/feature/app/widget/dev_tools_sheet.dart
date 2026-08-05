import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/constant/constant.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/router/router.dart';
import 'package:paywall_demo/src/core/utils/utils.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:paywall_demo/src/feature/onboarding/scope/onboarding_scope.dart';
import 'package:paywall_demo/src/feature/subscription/bloc/subscription_bloc.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_status.dart';
import 'package:paywall_demo/src/feature/subscription/scope/subscription_scope.dart';

/// {@template dev_tools_sheet}
/// Панель отладки: переключение состояний онбординга и подписки.
///
/// Открывается только в development-сборке (см. `DevToolsButton`) и нужна,
/// чтобы проходить флоу целиком без переустановки приложения и добираться
/// до состояний, которых из обычного UI не достичь — например, истёкшей
/// подписки.
///
/// После каждого действия гарды ветки `/` перепроверяются, и приложение
/// само уезжает на нужный экран.
///
/// Тексты здесь намеренно не в ARB: панель не часть продукта и в
/// production-сборке не показывается.
/// {@endtemplate}
class DevToolsSheet extends StatelessWidget {
  /// {@macro dev_tools_sheet}
  const DevToolsSheet({super.key});

  /// Насколько давно «куплена» истёкшая подписка
  static const Duration _longAgo = Duration(days: 400);

  /// {@macro dev_tools_sheet}
  static Future<void> show(BuildContext context) =>
      ModalSheetUtils.openSheet<void>(
        context,
        title: 'Отладка',
        content: const DevToolsSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final onboarding = OnboardingScope.cubitOf(context);
    final subscription = SubscriptionScope.blocOf(context);

    return Padding(
      padding: EdgeInsets.only(
        left: UIConfig.kSidePadding,
        right: UIConfig.kSidePadding,
        bottom: UIConfig.kSidePadding + context.mediaQuery.padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('Онбординг'),
          _DevAction(
            label: 'Показать заново',
            onPressed: () => _run(context, onboarding.reset()),
          ),
          _DevAction(
            label: 'Отметить пройденным',
            onPressed: () => _run(context, onboarding.complete()),
          ),
          const _SectionTitle('Подписка'),
          _DevAction(
            label: 'Сбросить',
            onPressed: () => _run(
              context,
              _reset(subscription),
            ),
          ),
          for (final plan in SubscriptionPlan.values)
            _DevAction(
              label: 'Активна: ${plan.name}',
              onPressed: () => _run(
                context,
                _apply(subscription, SubscriptionStatus.purchased(plan)),
              ),
            ),
          _DevAction(
            label: 'Истекла',
            onPressed: () => _run(
              context,
              _apply(
                subscription,
                SubscriptionStatus.purchased(
                  SubscriptionPlan.yearly,
                  at: DateTime.now().subtract(_longAgo),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Закрывает панель и просит роутер перепроверить гарды.
  ///
  /// Перепроверку заказываем именно **корневому** роутеру: гарды висят на
  /// ветке `/`, а `context.router` на главном экране — это вложенный роутер
  /// вкладки, у его роутов гардов нет и перепроверять ему нечего.
  ///
  /// Действие обязательно дожидается: запись и `emit` асинхронные, а гард
  /// смотрит на состояние блока — вызов сразу после `add(event)` проверил
  /// бы старые данные.
  Future<void> _run(BuildContext context, Future<void> action) async {
    final router = context.router.root;
    final navigator = Navigator.of(context);
    final onboarding = OnboardingScope.cubitOf(context);
    final subscription = SubscriptionScope.blocOf(context);

    await action;

    navigator.pop();

    // Пока приложение развёрнуто на онбординг или пейвол, навигация в `/`
    // висит незавершённой. Довести её до конца может только перепроверка
    // гардов — и только если войти в приложение теперь можно: иначе гард
    // снова развернёт нас на тот же экран, а перепроверка не завершится
    if (router.stackData.any(_isPreAppRoute)) {
      final canEnterApp =
          onboarding.state.isPassed && subscription.state.isActive;

      if (!canEnterApp) return;

      return router.reevaluateGuards();
    }

    // Мы уже внутри `/`. Перепроверка здесь не поможет: auto_route
    // запоминает на маршруте гарды, отработавшие в прошлый раз
    // (`RouteMatch.evaluatedGuards`), и повторно их не спрашивает.
    // Поэтому заходим в `/` заново — цепочка гардов отрабатывает с нуля
    return router.navigate(const AppWrapperRoute());
  }

  /// Экраны до входа в приложение — на них нас развернул гард
  bool _isPreAppRoute(RouteData route) =>
      route.name == OnboardingRoute.name || route.name == PaywallRoute.name;

  Future<void> _reset(SubscriptionBloc bloc) {
    bloc.add(const SubscriptionEvent.reset());

    return _awaitState(bloc, (state) => !state.isActive);
  }

  Future<void> _apply(SubscriptionBloc bloc, SubscriptionStatus status) {
    bloc.add(SubscriptionEvent.applyStatus(status: status));

    return _awaitState(bloc, (state) => state.status == status);
  }

  Future<void> _awaitState(
    SubscriptionBloc bloc,
    bool Function(SubscriptionState state) test,
  ) async {
    if (test(bloc.state)) return;

    await bloc.stream.firstWhere(test);
  }
}

/// Заголовок группы действий
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: UIConfig.kListPadding, bottom: 8),
    child: Text(title, style: context.textTheme.titleMedium),
  );
}

/// Одно действие панели
class _DevAction extends StatelessWidget {
  const _DevAction({required this.label, required this.onPressed});

  final String label;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AppButton(
      title: label,
      variant: AppButtonVariant.secondary,
      onPressed: onPressed,
    ),
  );
}
