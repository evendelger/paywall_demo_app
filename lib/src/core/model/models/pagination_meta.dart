import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_meta.freezed.dart';

@freezed
abstract class PaginationMeta with _$PaginationMeta {
  factory PaginationMeta({
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
  }) = _PaginationMeta;

  const PaginationMeta._();
}
