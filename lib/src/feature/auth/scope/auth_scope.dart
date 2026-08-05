import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/scope/bloc_scope.dart';
import 'package:paywall_demo/src/feature/auth/bloc/auth_bloc.dart';
import 'package:paywall_demo/src/feature/user/model/user.dart';

class AuthScope extends StatelessWidget {
  const AuthScope({
    required this.initialUser,
    required this.child,
    super.key,
  });

  final User? initialUser;

  final Widget child;

  static const BlocScope<AuthEvent, AuthState, AuthBloc> _scope = BlocScope();

  /// Доступ к самому блоку — нужен, например, для `AuthGuard`
  static AuthBloc blocOf(BuildContext context) => context.read<AuthBloc>();

  static ScopeData<User?> get userOf => _scope.data(
    (context, state) => state.user,
  );

  static ScopeData<bool> get isAuthenticatedOf => _scope.data(
    (context, state) => state.isAuthenticated,
  );

  static NullaryScopeMethod get logout => _scope.nullary(
    (context) => const AuthEvent.logout(),
  );

  @override
  Widget build(BuildContext context) => BlocProvider<AuthBloc>(
    lazy: false,
    create: (context) => AuthBloc(
      authRepository: context.repository.auth,
      initialUser: initialUser,
    ),
    child: child,
  );
}
