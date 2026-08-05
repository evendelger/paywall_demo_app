import 'package:client_api/client_api.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_code_response.freezed.dart';
part 'verify_code_response.g.dart';

@freezed
abstract class VerifyCodeResponse with _$VerifyCodeResponse {
  const factory VerifyCodeResponse({
    required bool success,
    required String token,
    required UserDto user,
  }) = _VerifyCodeResponse;

  const VerifyCodeResponse._();

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyCodeResponseFromJson(json);
}
