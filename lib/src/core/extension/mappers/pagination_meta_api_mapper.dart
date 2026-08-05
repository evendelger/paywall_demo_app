import 'package:client_api/client_api.dart';
import 'package:paywall_demo/src/core/model/model.dart';

extension PaginationMetaApiMapper on PaginationMetaDto {
  PaginationMeta toDomain() {
    return PaginationMeta(
      currentPage: currentPage,
      perPage: perPage,
      lastPage: lastPage,
      total: total,
      path: path,
      from: from,
      to: to,
      firstPageUrl: firstPageUrl,
      lastPageUrl: lastPageUrl,
      nextPageUrl: nextPageUrl,
      prevPageUrl: prevPageUrl,
    );
  }
}
