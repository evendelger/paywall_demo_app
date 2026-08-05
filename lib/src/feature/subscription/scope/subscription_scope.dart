import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:paywall_demo/src/feature/subscription/bloc/subscription_bloc.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_status.dart';

/// {@template subscription_scope}
/// Scope подписки.
///
/// Живёт выше роутера: состояние нужно `SubscriptionGuard` при первой
/// навигации, ещё до того, как построится первый экран.
/// {@endtemplate}
class SubscriptionScope extends StatelessWidget {
  /// {@macro subscription_scope}
  const SubscriptionScope({required this.child, super.key});

  final Widget child;

  static const BlocScope<SubscriptionEvent, SubscriptionState, SubscriptionBloc>
  _scope = BlocScope();

  /// Доступ к самому блоку — нужен для `SubscriptionGuard`
  static SubscriptionBloc blocOf(BuildContext context) =>
      context.read<SubscriptionBloc>();

  // --- Data --- //

  /// Статус подписки целиком: тариф, дата покупки, срок действия
  static ScopeData<SubscriptionStatus> get statusOf => _scope.select(
    (state) => state.status,
  );

  /// Действует ли подписка
  static ScopeData<bool> get isActiveOf => _scope.select(
    (state) => state.isActive,
  );

  /// Тариф, выбранный на пейволе
  static ScopeData<SubscriptionPlan> get selectedPlanOf => _scope.select(
    (state) => state.selectedPlan,
  );

  /// Идёт ли покупка или восстановление
  static ScopeData<bool> get isProcessingOf => _scope.select(
    (state) => state.isProcessing,
  );

  // --- Methods --- //

  /// Выбрать тариф
  static UnaryScopeMethod<SubscriptionPlan> get selectPlan => _scope.unary(
    (context, plan) => SubscriptionEvent.selectPlan(plan: plan),
  );

  /// Купить выбранный тариф
  static NullaryScopeMethod get purchase => _scope.nullary(
    (context) => const SubscriptionEvent.purchase(),
  );

  /// Восстановить покупки
  static NullaryScopeMethod get restore => _scope.nullary(
    (context) => const SubscriptionEvent.restore(),
  );

  /// Подменить статус — только для dev-инструментов
  static UnaryScopeMethod<SubscriptionStatus> get applyStatus => _scope.unary(
    (context, status) => SubscriptionEvent.applyStatus(status: status),
  );

  /// Сбросить подписку — чтобы пройти флоу заново
  static NullaryScopeMethod get reset => _scope.nullary(
    (context) => const SubscriptionEvent.reset(),
  );

  @override
  Widget build(BuildContext context) => BlocProvider<SubscriptionBloc>(
    lazy: false,
    create: (context) => SubscriptionBloc(
      subscriptionRepository: context.repository.subscription,
    ),
    child: child,
  );
}
