import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/extension/src/app_exception_localized_ext.dart';
import 'package:paywall_demo/src/feature/subscription/bloc/subscription_bloc.dart';

/// {@template subscription_listener}
/// Реакция на смену состояния подписки: навигация и сообщения об ошибках.
///
/// Экран сам никуда не уходит — подписка стала активной, значит гарды
/// нужно перепроверить, а куда идти, решат они. Вызов сделан именно
/// по факту нового состояния: сразу после `add(event)` запись в
/// `SharedPreferences` ещё не завершена и гард увидел бы старые данные.
/// {@endtemplate}
class SubscriptionListener extends StatelessWidget {
  /// {@macro subscription_listener}
  const SubscriptionListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Подписка появилась — покупка или восстановление прошли
        BlocListener<SubscriptionBloc, SubscriptionState>(
          listenWhen: (previous, current) =>
              !previous.isActive && current.isActive,
          // Гарды висят на ветке `/` — перепроверяет их корневой роутер
          listener: (context, state) => unawaited(
            context.router.root.reevaluateGuards(),
          ),
        ),
        // Ошибка сценария — показываем локализованный текст
        BlocListener<SubscriptionBloc, SubscriptionState>(
          listenWhen: (previous, current) => current.error != null,
          listener: (context, state) => unawaited(
            context.showMessage(
              state.error?.localized(context),
              dialogType: MessageType.error,
            ),
          ),
        ),
      ],
      child: child,
    );
  }
}
