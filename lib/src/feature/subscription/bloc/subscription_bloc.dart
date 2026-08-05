import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:paywall_demo/src/core/model/model.dart';
import 'package:paywall_demo/src/core/utils/logger.dart';
import 'package:paywall_demo/src/feature/subscription/data/repository/subscription_repository.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_exception.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_status.dart';

part 'subscription_bloc.freezed.dart';
part 'subscription_event.dart';
part 'subscription_state.dart';

/// {@template subscription_bloc}
/// Состояние подписки и выбранного на пейволе тарифа.
///
/// Начальное состояние собирается из репозитория **синхронно**: на него
/// смотрит `SubscriptionGuard` при первой навигации, дожидаться асинхронной
/// загрузки там уже некогда.
/// {@endtemplate}
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  /// {@macro subscription_bloc}
  SubscriptionBloc({required ISubscriptionRepository subscriptionRepository})
    : _subscriptionRepository = subscriptionRepository,
      super(
        SubscriptionState.idle(
          status: subscriptionRepository.currentStatus,
          selectedPlan: defaultPlan,
        ),
      ) {
    on<SubscriptionEvent>(
      (event, emit) => switch (event) {
        _SelectPlan() => _selectPlan(event, emit),
        _Purchase() => _purchase(event, emit),
        _Restore() => _restore(event, emit),
        _ApplyStatus() => _applyStatus(event, emit),
        _Reset() => _reset(event, emit),
      },
      // Покупка и восстановление уходят в «стор»: пока сценарий не закончился,
      // повторные события отбрасываются — двойной тап не купит дважды
      transformer: bloc_concurrency.droppable(),
    );
  }

  /// Тариф, выбранный на пейволе по умолчанию — выгодный для пользователя
  static const SubscriptionPlan defaultPlan = SubscriptionPlan.yearly;

  final ISubscriptionRepository _subscriptionRepository;

  void _selectPlan(_SelectPlan event, Emitter<SubscriptionState> emit) => emit(
    SubscriptionState.idle(status: state.status, selectedPlan: event.plan),
  );

  Future<void> _purchase(
    _Purchase event,
    Emitter<SubscriptionState> emit,
  ) async {
    final plan = state.selectedPlan;

    emit(SubscriptionState.processing(status: state.status, selectedPlan: plan));

    try {
      final status = await _subscriptionRepository.purchase(plan);

      emit(SubscriptionState.successful(status: status, selectedPlan: plan));
    } on SubscriptionException catch (error) {
      emit(_errorState(plan: plan, exception: error));
    } on Object catch (error, stackTrace) {
      mainTalker.handle(error, stackTrace, 'Покупка завершилась ошибкой');

      emit(_errorState(plan: plan));
    }
  }

  Future<void> _restore(
    _Restore event,
    Emitter<SubscriptionState> emit,
  ) async {
    final plan = state.selectedPlan;

    emit(SubscriptionState.processing(status: state.status, selectedPlan: plan));

    try {
      final status = await _subscriptionRepository.restore();

      emit(
        SubscriptionState.successful(
          status: status,
          // Показываем тот тариф, который действительно куплен
          selectedPlan: status.plan ?? plan,
        ),
      );
    } on SubscriptionException catch (error) {
      emit(_errorState(plan: plan, exception: error));
    } on Object catch (error, stackTrace) {
      mainTalker.handle(error, stackTrace, 'Восстановление завершилось ошибкой');

      emit(_errorState(plan: plan));
    }
  }

  Future<void> _applyStatus(
    _ApplyStatus event,
    Emitter<SubscriptionState> emit,
  ) async {
    await _subscriptionRepository.applyStatus(event.status);

    emit(
      SubscriptionState.idle(
        status: event.status,
        selectedPlan: state.selectedPlan,
      ),
    );
  }

  Future<void> _reset(_Reset event, Emitter<SubscriptionState> emit) async {
    await _subscriptionRepository.clear();

    emit(
      const SubscriptionState.idle(
        status: SubscriptionStatus.inactive,
        selectedPlan: defaultPlan,
      ),
    );
  }

  /// Ошибка без деталей — уже известный статус и тариф остаются на месте,
  /// чтобы экран не мигал пустотой
  SubscriptionState _errorState({
    required SubscriptionPlan plan,
    AppException? exception,
  }) => SubscriptionState.error(
    status: state.status,
    selectedPlan: plan,
    exception: exception ?? const SubscriptionException(),
  );
}
