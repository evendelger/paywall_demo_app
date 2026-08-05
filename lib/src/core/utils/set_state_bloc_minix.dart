import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

mixin SetStateBlocMixin<State extends Object?> implements Emittable<State> {
  final ValueNotifier<int> notifier = ValueNotifier(0);

  void setState(State state) {
    emit(state);
    notifier.value++;
  }
}
