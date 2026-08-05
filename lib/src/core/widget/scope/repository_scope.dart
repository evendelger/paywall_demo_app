import 'package:flutter/material.dart';
import 'package:paywall_demo/src/core/model/model.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';

class RepositoryScope extends Scope {
  const RepositoryScope({
    required this.storage,
    required super.child,
    super.key,
  });

  static const DelegateAccess<_RepositoryScopeDelegate> _delegateOf =
      Scope.delegateOf<RepositoryScope, _RepositoryScopeDelegate>;

  final IRepositoryStorage storage;

  static IRepositoryStorage of(BuildContext context) =>
      _delegateOf(context).storage;

  @override
  ScopeDelegate<RepositoryScope> createDelegate() => _RepositoryScopeDelegate();
}

class _RepositoryScopeDelegate extends ScopeDelegate<RepositoryScope> {
  IRepositoryStorage get storage => widget.storage;
}
