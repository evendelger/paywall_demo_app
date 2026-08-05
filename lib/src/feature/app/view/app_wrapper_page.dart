import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/feature/user/scope/user_scope.dart';

@RoutePage()
class AppWrapperPage extends StatelessWidget implements AutoRouteWrapper {
  const AppWrapperPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return UserScope(child: this);
  }

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
