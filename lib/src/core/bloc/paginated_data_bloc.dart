import 'package:client_api/client_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:paywall_demo/src/core/extension/mappers/mappers.dart';
import 'package:paywall_demo/src/core/model/model.dart';

part 'paginated_data_bloc.freezed.dart';

class PaginatedDataBloc<T, P>
    extends Bloc<PaginatedDataEvent<T, P>, PaginatedDataState<T, P>> {
  PaginatedDataBloc({required this.load})
    : super(
        const PaginatedDataState.idle(
          data: [],
          hasReachedMax: false,
          page: 0,
        ),
      ) {
    on<_LoadFirstPage<T, P>>(_onLoadFirstPage);
    on<_LoadNextPage<T, P>>(_onLoadNextPage);
    on<_UpdateList<T, P>>(_onUpdateList);
  }

  final Future<ApiResponse<List<T>>> Function({required int page, P? param})
  load;

  Future<void> _onLoadFirstPage(
    _LoadFirstPage<T, P> event,
    Emitter<PaginatedDataState<T, P>> emit,
  ) async {
    // Если уже грузим и это не force, то игнорируем
    if (state.isProcessing && !event.force) return;

    emit(
      PaginatedDataState.processing(
        data: event.force ? [] : state.data,
        hasReachedMax: false,
        page: 0,
        param: event.param, // Сохраняем новые параметры (фильтры)
      ),
    );

    try {
      const initialPage = 1;
      final response = await load(page: initialPage, param: event.param);

      final newData = response.data ?? [];
      final meta = response.meta?.toDomain();

      emit(
        PaginatedDataState.successful(
          data: newData,
          hasReachedMax: _checkIfMaxReached(meta, newData),
          page: initialPage,
          param: event.param,
        ),
      );
    } on Object catch (e) {
      emit(
        PaginatedDataState.error(
          data: state.data,
          message: e.toString(),
          hasReachedMax: state.hasReachedMax,
          page: state.page,
          param: event.param,
        ),
      );
    } finally {
      if (state is! ErrorPaginatedState) {
        emit(
          PaginatedDataState.idle(
            data: state.data,
            hasReachedMax: state.hasReachedMax,
            page: state.page,
            param: state.param,
          ),
        );
      }
    }
  }

  Future<void> _onLoadNextPage(
    _LoadNextPage<T, P> event,
    Emitter<PaginatedDataState<T, P>> emit,
  ) async {
    if (state.isProcessing || state.hasReachedMax) return;

    // Используем сохраненные параметры от первой страницы
    final currentParam = state.param;

    emit(
      PaginatedDataState.processing(
        data: state.data,
        hasReachedMax: state.hasReachedMax,
        page: state.page,
        param: currentParam,
      ),
    );

    try {
      final nextPage = state.page + 1;
      final response = await load(page: nextPage, param: currentParam);

      final newItems = response.data ?? [];
      final meta = response.meta?.toDomain();

      emit(
        PaginatedDataState.successful(
          data: List.of(state.data)..addAll(newItems),
          hasReachedMax: _checkIfMaxReached(meta, newItems),
          page: nextPage,
          param: currentParam,
        ),
      );
    } on Object catch (e) {
      emit(
        PaginatedDataState.error(
          data: state.data,
          message: e.toString(),
          hasReachedMax: state.hasReachedMax,
          page: state.page,
          param: currentParam,
        ),
      );
    } finally {
      if (state is! ErrorPaginatedState) {
        emit(
          PaginatedDataState.idle(
            data: state.data,
            hasReachedMax: state.hasReachedMax,
            page: state.page,
            param: currentParam,
          ),
        );
      }
    }
  }

  Future<void> _onUpdateList(
    _UpdateList<T, P> event,
    Emitter<PaginatedDataState<T, P>> emit,
  ) async {
    emit(state.copyWith(data: event.updatedList));
  }

  bool _checkIfMaxReached(PaginationMeta? meta, List<T> items) {
    if (meta != null) {
      return meta.currentPage >= meta.lastPage;
    }
    return items.isEmpty;
  }
}

@freezed
sealed class PaginatedDataEvent<T, P> with _$PaginatedDataEvent<T, P> {
  const factory PaginatedDataEvent.loadFirstPage({
    P? param,
    @Default(true) bool force,
  }) = _LoadFirstPage;

  const factory PaginatedDataEvent.loadNextPage() = _LoadNextPage;

  const factory PaginatedDataEvent.updateList({
    required List<T> updatedList,
  }) = _UpdateList;
}

@freezed
sealed class PaginatedDataState<T, P> with _$PaginatedDataState<T, P> {
  const PaginatedDataState._();

  const factory PaginatedDataState.idle({
    required List<T> data,
    required bool hasReachedMax,
    required int page,
    P? param,
  }) = _IdlePaginatedState;

  const factory PaginatedDataState.processing({
    required List<T> data,
    required bool hasReachedMax,
    required int page,
    P? param,
  }) = ProcessingPaginatedState;

  const factory PaginatedDataState.successful({
    required List<T> data,
    required bool hasReachedMax,
    required int page,
    P? param,
  }) = SuccessfulPaginatedState;

  const factory PaginatedDataState.error({
    required List<T> data,
    required bool hasReachedMax,
    required int page,
    P? param,
    String? message,
  }) = ErrorPaginatedState;

  bool get isProcessing => this is ProcessingPaginatedState;
}
