import 'package:paywall_demo/src/core/model/model.dart';

enum AuthErrorType {
  unknown,
  sendCode,
  verifyCode,
  signOut,
}

final class AuthException implements ApiException {
  const AuthException([
    this.type = AuthErrorType.unknown,
    this.message,
  ]);

  final AuthErrorType type;

  @override
  final String? message;
}
