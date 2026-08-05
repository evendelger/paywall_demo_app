part of 'user_bloc.dart';

@freezed
sealed class UserState with _$UserState {
  const UserState._();

  /// Idling state
  const factory UserState.idle({
    User? user,
  }) = IdleUserState;

  /// Processing
  const factory UserState.processing({
    User? user,
  }) = ProcessingUserState;

  /// Successful
  const factory UserState.successful({
    User? user,
    String? message,
  }) = SuccessfulUserState;

  /// An error has occurred
  const factory UserState.error({
    User? user,
    AppException? exception,
  }) = ErrorUserState;

  bool get isProcessing => this is ProcessingUserState;

  /// Авторизован ли пользователь
  bool get isAuthenticated => user != null;

  AppException? get error => switch (this) {
    final ErrorUserState state => state.exception,
    _ => null,
  };

  String? get successMessage => switch (this) {
    final SuccessfulUserState state => state.message,
    _ => null,
  };
}
