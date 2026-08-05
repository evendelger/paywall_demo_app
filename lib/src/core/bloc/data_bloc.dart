import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_bloc.freezed.dart';

class DataBloc<T, P> extends Bloc<DataEvent<T, P>, DataState<T>> {
  DataBloc({required this.load}) : super(const DataState.idle()) {
    on<_FetchData<T, P>>(_onFetch);
    on<_UpdateData<T, P>>(_onUpdate);
  }

  final Future<T> Function({P? param}) load;

  Future<void> _onFetch(
    _FetchData<T, P> event,
    Emitter<DataState<T>> emit,
  ) async {
    if (state.isProcessing) return;

    if (event.force) {
      emit(DataState.processing(data: state.data));
    }

    try {
      final data = await load(param: event.param);

      emit(DataState.successful(data: data));
    } on Object catch (e) {
      emit(DataState.error(data: state.data, message: e.toString()));
    } finally {
      emit(DataState.idle(data: state.data));
    }
    return;
  }

  Future<void> _onUpdate(
    _UpdateData<T, P> event,
    Emitter<DataState<T>> emit,
  ) async {
    emit(DataState.successful(data: event.data));
    emit(DataState.idle(data: state.data));
  }
}

@freezed
sealed class DataEvent<T, P> with _$DataEvent<T, P> {
  const factory DataEvent.fetch({
    P? param,
    @Default(true) bool force,
  }) = _FetchData;

  const factory DataEvent.update({
    T? data,
  }) = _UpdateData;
}

@freezed
sealed class DataState<T> with _$DataState<T> {
  const DataState._();

  /// Idling state
  const factory DataState.idle({T? data}) = _DataState;

  /// Processing
  const factory DataState.processing({T? data}) = ProcessingDataState;

  /// Successful
  const factory DataState.successful({T? data}) = SuccessfulDataState;

  /// An error has occurred
  const factory DataState.error({T? data, String? message}) = ErrorDataState;

  bool get isProcessing => this is ProcessingDataState;

  bool get isSuccessful => this is SuccessfulDataState;

  bool get isError => this is ErrorDataState;
}
