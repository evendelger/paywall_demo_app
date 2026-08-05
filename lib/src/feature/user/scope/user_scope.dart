import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/extension/src/app_exception_localized_ext.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:paywall_demo/src/feature/auth/scope/auth_scope.dart';
import 'package:paywall_demo/src/feature/user/bloc/user_bloc.dart';
import 'package:paywall_demo/src/feature/user/model/user.dart';

/// {@template user_scope}
/// Scope текущего пользователя.
///
/// Авторизация необязательна: если пользователь не авторизован,
/// [userOf] вернёт `null`, а [isAuthenticatedOf] — `false`.
/// {@endtemplate}
class UserScope extends StatelessWidget {
  /// {@macro user_scope}
  const UserScope({required this.child, super.key});

  final Widget child;

  static const BlocScope<UserEvent, UserState, UserBloc> _scope = BlocScope();

  static ScopeData<bool> get isLoadingOf =>
      _scope.data((context, state) => state.isProcessing);

  static ScopeData<User?> get userOf =>
      _scope.data((context, state) => state.user);

  static ScopeData<bool> get isAuthenticatedOf =>
      _scope.data((context, state) => state.isAuthenticated);

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.userOf(context);

    return BlocProvider<UserBloc>(
      lazy: false,
      create: (context) => UserBloc(
        user: user,
        authRepository: context.repository.auth,
        userRepository: context.repository.user,
      ),
      child: child,
    );
  }
}

class UserListener extends StatelessWidget {
  const UserListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Показ уведомления об ошибке
        BlocListener<UserBloc, UserState>(
          listenWhen: (pr, cu) => cu.error != null,
          listener: (context, state) {
            unawaited(
              context.showMessage(
                state.error?.localized(context),
                dialogType: MessageType.error,
              ),
            );
          },
        ),
        // Показ уведомления при успехе
        BlocListener<UserBloc, UserState>(
          listenWhen: (pr, cu) => cu.successMessage != null,
          listener: (context, state) {
            unawaited(
              context.showMessage(
                state.successMessage,
                dialogType: MessageType.success,
              ),
            );
          },
        ),
      ],
      child: child,
    );
  }
}
