import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config_dto.freezed.dart';
part 'app_config_dto.g.dart';

@freezed
abstract class AppConfigDto with _$AppConfigDto {
  const factory AppConfigDto({
    AppInfoDto? app,
    @Default(<FileItemDto>[]) List<FileItemDto> files,
  }) = _AppConfigDto;

  factory AppConfigDto.fromJson(Map<String, dynamic> json) =>
      _$AppConfigDtoFromJson(json);
}

@freezed
abstract class AppInfoDto with _$AppInfoDto {
  const factory AppInfoDto({
    String? version,
    bool? forceUpdate,
    String? about,
  }) = _AppInfoDto;

  factory AppInfoDto.fromJson(Map<String, dynamic> json) =>
      _$AppInfoDtoFromJson(json);
}

@freezed
abstract class FileItemDto with _$FileItemDto {
  const factory FileItemDto({
    required String url,
    required String name,
  }) = _FileItemDto;

  factory FileItemDto.fromJson(Map<String, dynamic> json) =>
      _$FileItemDtoFromJson(json);
}
