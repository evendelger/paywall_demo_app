import 'package:paywall_demo/src/core/model/model.dart';

enum UserErrorType { unknown, updateData, getData }

final class UserException implements ApiException {
  const UserException([this.type = UserErrorType.unknown, this.message]);

  final UserErrorType type;

  @override
  final String? message;
}
