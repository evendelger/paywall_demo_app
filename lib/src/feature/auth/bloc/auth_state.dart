part of 'auth_bloc.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.idle({
    User? user,
  }) = AuthIdle;

  const AuthState._();

  bool get isAuthenticated => user != null;

  bool get isUnAuthenticated => !isAuthenticated;
}
