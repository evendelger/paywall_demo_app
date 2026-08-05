import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class ApiResponse<T> with _$ApiResponse<T> {
  factory ApiResponse({
    T? data,
    @Default(false) bool success,
    String? message,
    PaginationMetaDto? meta,
  }) = _ApiResponse;

  factory ApiResponse.fromJson(
    Map<String, Object?> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

@freezed
abstract class PaginationMetaDto with _$PaginationMetaDto {
  factory PaginationMetaDto({
    required int currentPage,
    required int perPage,
    required int lastPage,
    int? total,
    String? path,
    int? from,
    int? to,
    String? firstPageUrl,
    String? lastPageUrl,
    String? nextPageUrl,
    String? prevPageUrl,
  }) = _PaginationMetaDto;

  factory PaginationMetaDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaDtoFromJson(json);
}
