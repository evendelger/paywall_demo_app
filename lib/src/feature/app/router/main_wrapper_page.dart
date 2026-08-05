import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paywall_demo/src/feature/app/widget/app_listeners.dart';

@RoutePage()
class MainWrapperPage extends StatelessWidget implements AutoRouteWrapper {
  const MainWrapperPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return AppListeners(child: this);
  }

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
