import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

typedef ScopeData<D extends Object?> =
    D Function(
      BuildContext context, {
      bool listen,
    });

typedef NullaryScopeMethod = void Function(BuildContext context);

typedef UnaryScopeMethod<A extends Object?> =
    void Function(
      BuildContext context,
      A argument,
    );

@immutable
class BlocScope<E extends Object?, S extends Object?, B extends Bloc<E, S>> {
  const BlocScope({
    this._listenByDefault = false,
  });

  final bool _listenByDefault;

  B _bloc(BuildContext context) => context.read<B>();

  ScopeData<D> data<D extends Object?>(
    D Function(BuildContext context, S state) data,
  ) {
    return (BuildContext context, {bool? listen}) {
      final shouldListen = listen ?? _listenByDefault;

      if (shouldListen) {
        // Используем context.select для подписки на изменения
        return context.select<B, D>(
          (bloc) => data(context, bloc.state),
        );
      } else {
        // Просто читаем текущее состояние без подписки
        return data(context, _bloc(context).state);
      }
    };
  }

  ScopeData<D> select<D extends Object?>(D Function(S state) selector) {
    // Передаем в data функцию, которая игнорирует context
    return data((_, state) => selector(state));
  }

  NullaryScopeMethod nullary(
    E? Function(BuildContext context) createEvent,
  ) {
    return (BuildContext context) {
      final event = createEvent(context);
      if (event != null) {
        _bloc(context).add(event);
      }
    };
  }

  UnaryScopeMethod<A> unary<A extends Object?>(
    E? Function(BuildContext context, A argument) createEvent,
  ) {
    return (BuildContext context, A argument) {
      final event = createEvent(context, argument);
      if (event != null) {
        _bloc(context).add(event);
      }
    };
  }
}
