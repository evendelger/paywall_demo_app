import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paywall_demo/src/feature/auth/bloc/auth_bloc.dart';
import 'package:paywall_demo/src/feature/settings/bloc/settings_bloc.dart';
import 'package:paywall_demo/src/feature/settings/scope/settings_scope.dart';

/// {@template app_listeners}
/// Провайдер для слушателей
/// {@endtemplate}
class AppListeners extends StatelessWidget {
  /// {@macro app_listeners}
  const AppListeners({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) async {
          if (state is SettingsStateRequiredToUpdate) {
            final forceUpdate = state.data.config?.app?.forceUpdate ?? false;
            return SettingsScope.openUpdateDialog(
              context,
              forceUpdate: forceUpdate,
            );
          }
        },
      ),

      // Реакция на выход из аккаунта.
      // Авторизация необязательна, поэтому по умолчанию на главном экране
      // просто остаётся «гость». Если вход обязателен — раскомментируйте
      // редирект и подключите `AuthGuard` (см. `AppRoutes.root`).
      BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.isAuthenticated && current.isUnAuthenticated,
        listener: (context, state) {
          // context.router.root.replaceAll([const LoginRoute()]);
        },
      ),
    ],
    child: child,
  );
}
