import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:paywall_demo/src/feature/onboarding/cubit/onboarding_cubit.dart';

/// {@template onboarding_scope}
/// Scope онбординга.
///
/// Живёт выше роутера: состояние нужно `OnboardingGuard` при первой
/// навигации, ещё до того, как построится первый экран.
/// {@endtemplate}
class OnboardingScope extends StatelessWidget {
  /// {@macro onboarding_scope}
  const OnboardingScope({required this.child, super.key});

  final Widget child;

  static const CubitScope<OnboardingState, OnboardingCubit> _scope =
      CubitScope();

  /// Доступ к самому кубиту — нужен для `OnboardingGuard`
  static OnboardingCubit cubitOf(BuildContext context) =>
      context.read<OnboardingCubit>();

  // --- Data --- //

  static ScopeData<bool> get isPassedOf => _scope.select(
    (state) => state.isPassed,
  );

  // --- Methods --- //

  /// Пометить онбординг пройденным
  static NullaryScopeMethod get complete => _scope.nullary(
    (context, cubit) => cubit.complete(),
  );

  /// Сбросить состояние — чтобы пройти флоу заново
  static NullaryScopeMethod get reset => _scope.nullary(
    (context, cubit) => cubit.reset(),
  );

  @override
  Widget build(BuildContext context) => BlocProvider<OnboardingCubit>(
    lazy: false,
    create: (context) => OnboardingCubit(
      repository: context.repository.onboarding,
    ),
    child: child,
  );
}
