import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:paywall_demo/src/core/model/model.dart';
import 'package:paywall_demo/src/feature/auth/data/repositories/auth_repository.dart';
import 'package:paywall_demo/src/feature/user/data/repository/user_repository.dart';
import 'package:paywall_demo/src/feature/user/model/user.dart';
import 'package:paywall_demo/src/feature/user/model/user_exception.dart';

part 'user_bloc.freezed.dart';
part 'user_event.dart';
part 'user_state.dart';

/// {@template user_bloc}
/// Состояние текущего пользователя.
///
/// Авторизация в шаблоне необязательна, поэтому `state.user` может быть
/// `null` — это штатная ситуация «гость».
/// {@endtemplate}
class UserBloc extends Bloc<UserEvent, UserState> {
  /// {@macro user_bloc}
  UserBloc({
    required User? user,
    required this._authRepository,
    required this._userRepository,
  }) : super(UserState.idle(user: user)) {
    on<UserEvent>(
      (event, emit) => switch (event) {
        _GetUserData() => _getUserData(event, emit),
        _UpdateUserState() => _onUpdateUserState(event, emit),
        // _UpdateUser() => _onUpdateUser(event, emit),
      },
      transformer: bloc_concurrency.sequential(),
    );

    _userSubscription = _authRepository.user
        .where((user) => !identical(user, state.user))
        .map<UserState>((user) => UserState.idle(user: user))
        .listen(
          (state) => add(UserEvent.updateUserState(state: state)),
          cancelOnError: false,
        );

    // Данные с сервера подтягиваем только для авторизованного пользователя
    if (user != null) {
      add(const UserEvent.getUserData());
    }
  }

  final IAuthRepository _authRepository;

  final IUserRepository _userRepository;

  late StreamSubscription<UserState> _userSubscription;

  Future<void> _getUserData(_GetUserData event, Emitter<UserState> emit) async {
    final user = state.user;

    try {
      // emit(UserState.processing(user: state.user));
      await _userRepository.getUserData();
      // emit(UserState.successful(user: user));
    } on UserException catch (error) {
      emit(UserState.error(exception: error, user: user));
    } finally {
      emit(UserState.idle(user: user));
    }
  }

  // Future<void> _onUpdateUser(_UpdateUser event, Emitter<UserState> emit) async {
  //   try {
  //     final user = state.user;
  //     if (user == null) return;

  //     emit(UserState.processing(user: state.user));

  //     final request = event.request;

  //     await _userRepository.updateUser(request: request);

  //     emit(
  //       UserState.successful(
  //         user: state.user,
  //         message: 'Данные пользователя обновлены!',
  //       ),
  //     );
  //   } on UserException catch (error) {
  //     emit(UserState.error(exception: error, user: state.user));
  //   } finally {
  //     emit(UserState.idle(user: state.user));
  //   }
  // }

  void _onUpdateUserState(_UpdateUserState event, Emitter<UserState> emit) {
    emit(event.state);
  }

  @override
  Future<void> close() async {
    await _userSubscription.cancel();
    return super.close();
  }
}
