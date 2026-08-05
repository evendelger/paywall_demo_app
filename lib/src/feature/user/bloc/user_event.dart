part of 'user_bloc.dart';

@freezed
sealed class UserEvent with _$UserEvent {
  const factory UserEvent.getUserData() = _GetUserData;

  // const factory UserEvent.updateUser({
  //   required UpdateUserRequest request,
  // }) = _UpdateUser;

  const factory UserEvent.updateUserState({required UserState state}) =
      _UpdateUserState;
}
