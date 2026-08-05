import 'package:client_api/client_api.dart';
import 'package:dio/dio.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/feature/user/data/mappers/user_api_mapper.dart';
import 'package:paywall_demo/src/feature/user/database/dao/user_dao.dart';
import 'package:paywall_demo/src/feature/user/model/user.dart';
import 'package:paywall_demo/src/feature/user/model/user_exception.dart';

abstract interface class IUserRepository {
  Future<User> getUserData();
}

final class UserRepository implements IUserRepository {
  UserRepository({required this._userDao, required this._client});

  final IUserDao _userDao;

  final ClientApi _client;

  @override
  Future<User> getUserData() async {
    const baseException = UserException(UserErrorType.getData);

    try {
      final response = await _client.getUser();

      final user = response.data?.toDomain();
      if (user == null) {
        Error.throwWithStackTrace(baseException, StackTrace.current);
      }

      await _userDao.upsertUser(user);

      return user;
    } on DioException catch (error) {
      error.throwCustom(
        error.stackTrace,
        unknownError: baseException,
        errorBuilder: (error) => UserException(UserErrorType.unknown, error),
      );
    } on UserException {
      rethrow;
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(baseException, stackTrace);
    }
  }
}
