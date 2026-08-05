import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:paywall_demo/src/core/router/app_router.dart';
import 'package:paywall_demo/src/core/router/app_router_observer.dart';

typedef RouterWidgetBuilder =
    Widget Function(
      BuildContext context,
      RouterConfig<Object>? routerConfig,
    );

/// Контейнер для роутера
class AppRouterBuilder extends StatefulWidget {
  const AppRouterBuilder({
    required this.builder,
    this.rootGuards = const [],
    super.key,
  });

  final RouterWidgetBuilder builder;

  /// Гарды ветки `/` — собираются выше, в `AppConfiguration`
  final List<AutoRouteGuard> rootGuards;

  @override
  State<AppRouterBuilder> createState() => _AppRouterBuilderState();
}

class _AppRouterBuilderState extends State<AppRouterBuilder> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(rootGuards: widget.rootGuards);
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    _appRouter.config(
      navigatorObservers: () => [
        AppRouterObserver(),
      ],
    ),
  );
}
