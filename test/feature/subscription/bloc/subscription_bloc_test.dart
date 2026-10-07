import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:paywall_demo/src/feature/subscription/bloc/subscription_bloc.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_exception.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_plan.dart';
import 'package:paywall_demo/src/feature/subscription/model/subscription_status.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('SubscriptionBloc', () {
    test('годовой тариф выбран по умолчанию', () {
      final bloc = _createBloc();

      expect(bloc.state.selectedPlan, SubscriptionPlan.yearly);
    });

    test('начальный статус поднимается из репозитория синхронно', () {
      // На это состояние опирается SubscriptionGuard при первой проверке
      final bloc = _createBloc(
        repository: FakeSubscriptionRepository(status: _activeStatus),
      );

      expect(bloc.state.isActive, isTrue);
      expect(bloc.state.status.plan, SubscriptionPlan.yearly);
    });

    test('выбор тарифа меняет только выбор', () {
      final bloc = _createBloc()
        ..add(
          const SubscriptionEvent.selectPlan(plan: SubscriptionPlan.monthly),
        );

      return expectLater(
        bloc.stream.first.then((state) => state.selectedPlan),
        completion(SubscriptionPlan.monthly),
      );
    });

    test('покупка проходит через processing к активной подписке', () async {
      final bloc = _createBloc();
      final states = _collect(bloc);

      bloc.add(const SubscriptionEvent.purchase());
      await pumpEventQueue();

      expect(states.first.isProcessing, isTrue);
      expect(states.last, isA<SubscriptionStateSuccessful>());
      expect(bloc.state.isActive, isTrue);
      expect(bloc.state.status.plan, SubscriptionPlan.yearly);
      expect(bloc.state.status.isTrial, isTrue);
    });

    test('повторная покупка во время обработки отбрасывается', () async {
      final gate = Completer<void>();
      final repository = FakeSubscriptionRepository()..pending = gate;
      final bloc = _createBloc(repository: repository)
        ..add(const SubscriptionEvent.purchase());
      await pumpEventQueue();

      // Двойной тап по кнопке, пока первая покупка ещё идёт
      bloc.add(const SubscriptionEvent.purchase());
      await pumpEventQueue();

      gate.complete();
      await pumpEventQueue();

      expect(repository.purchaseCount, 1);
    });

    test('восстановление без покупки заканчивается ошибкой', () async {
      final bloc = _createBloc()..add(const SubscriptionEvent.restore());
      await pumpEventQueue();

      expect(bloc.state.isActive, isFalse);
      expect(
        bloc.state.error,
        isA<SubscriptionException>().having(
          (error) => error.type,
          'type',
          SubscriptionErrorType.nothingToRestore,
        ),
      );
    });

    test(
      'восстановление показывает тариф, который действительно куплен',
      () async {
        final bloc = _createBloc(
          repository: FakeSubscriptionRepository(status: _activeStatus),
        )..add(const SubscriptionEvent.restore());
        await pumpEventQueue();

        expect(bloc.state.isActive, isTrue);
        expect(bloc.state.selectedPlan, SubscriptionPlan.yearly);
      },
    );

    test('сброс возвращает состояние к отсутствию подписки', () async {
      final bloc = _createBloc(
        repository: FakeSubscriptionRepository(status: _activeStatus),
      )..add(const SubscriptionEvent.reset());
      await pumpEventQueue();

      expect(bloc.state.isActive, isFalse);
      expect(bloc.state.selectedPlan, SubscriptionPlan.yearly);
    });
  });
}

/// Активная подписка «куплена только что»
final SubscriptionStatus _activeStatus = SubscriptionStatus(
  plan: SubscriptionPlan.yearly,
  purchasedAt: DateTime.now(),
  expiresAt: DateTime.now().add(const Duration(days: 30)),
);

SubscriptionBloc _createBloc({FakeSubscriptionRepository? repository}) {
  final bloc = SubscriptionBloc(
    subscriptionRepository: repository ?? FakeSubscriptionRepository(),
  );

  addTearDown(bloc.close);

  return bloc;
}

List<SubscriptionState> _collect(SubscriptionBloc bloc) {
  final states = <SubscriptionState>[];
  final subscription = bloc.stream.listen(states.add);

  addTearDown(subscription.cancel);

  return states;
}
