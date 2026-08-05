import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';

typedef CubitNullaryWithContext<C extends Cubit<S>, S> =
    FutureOr<void> Function(
      BuildContext context,
      C cubit,
    );

typedef CubitUnaryWithContext<C extends Cubit<S>, S, A> =
    FutureOr<void> Function(
      BuildContext context,
      C cubit,
      A argument,
    );

@immutable
class CubitScope<S extends Object?, C extends Cubit<S>> {
  const CubitScope({this._listenByDefault = false});

  final bool _listenByDefault;

  C _cubit(BuildContext context) => context.read<C>();

  ScopeData<D> data<D extends Object?>(
    D Function(BuildContext context, S state) data,
  ) =>
      (BuildContext context, {bool? listen}) => (listen ?? _listenByDefault)
      ? context.select<C, D>((cubit) => data(context, cubit.state))
      : data(context, _cubit(context).state);

  ScopeData<D> select<D extends Object?>(D Function(S state) selector) =>
      data((_, state) => selector(state));

  NullaryScopeMethod nullary(CubitNullaryWithContext<C, S> method) =>
      (BuildContext context) => method(context, _cubit(context));

  UnaryScopeMethod<A> unary<A extends Object?>(
    CubitUnaryWithContext<C, S, A> method,
  ) =>
      (BuildContext context, A argument) =>
          method(context, _cubit(context), argument);
}
