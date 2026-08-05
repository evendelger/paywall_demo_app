import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/model/model.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';

class DependenciesScope extends Scope {
  const DependenciesScope({
    required this.storage,
    required super.child,
    super.key,
  });

  static const DelegateAccess<_DependenciesScopeDelegate> _delegateOf =
      Scope.delegateOf<DependenciesScope, _DependenciesScopeDelegate>;

  final IDependenciesStorage storage;

  static IDependenciesStorage of(
    BuildContext context,
  ) => _delegateOf(context).storage;

  @override
  ScopeDelegate<DependenciesScope> createDelegate() =>
      _DependenciesScopeDelegate();
}

class _DependenciesScopeDelegate extends ScopeDelegate<DependenciesScope> {
  IDependenciesStorage get storage => widget.storage;

  @override
  void dispose() {
    storage.close();
    super.dispose();
  }
}
