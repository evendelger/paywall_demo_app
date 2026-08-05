import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:paywall_demo/src/core/utils/utils.dart';
import 'package:paywall_demo/src/feature/auth/data/repositories/auth_repository.dart';
import 'package:paywall_demo/src/feature/user/model/user.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>
    with SetStateBlocMixin<AuthState> {
  AuthBloc({
    required this._authRepository,
    required User? initialUser,
  }) : super(AuthState.idle(user: initialUser)) {
    on<_LogoutEvent>(_onLogout);

    _userSubscription = _authRepository.user
        .where((user) => user != state.user)
        .map<AuthState>(
          (user) => AuthState.idle(user: user),
        )
        .listen(setState, cancelOnError: false);
  }

  final IAuthRepository _authRepository;

  late StreamSubscription<AuthState> _userSubscription;

  Future<void> _onLogout(
    _LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthState.idle());
  }

  @override
  Future<void> close() {
    unawaited(_userSubscription.cancel());
    return super.close();
  }
}
