// ignore_for_file: strict_raw_type

import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class AppRouterObserver extends AutoRouterObserver {
  static const _logName = 'Router';

  @override
  void didPush(Route route, Route? previousRoute) {
    _log(
      action: 'PUSH   ',
      from: _routeName(previousRoute),
      to: _routeName(route),
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _log(
      action: 'POP    ',
      from: _routeName(route),
      to: _routeName(previousRoute),
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _log(
      action: 'REPLACE',
      from: _routeName(oldRoute),
      to: _routeName(newRoute),
    );
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    log('TAB INIT  /${route.path}', name: _logName);
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    log('TAB       /${previousRoute.path} → /${route.path}', name: _logName);
  }

  String? _routeName(Route? route) {
    final settings = route?.settings;
    if (settings is AutoRoutePage) {
      final path = settings.routeData.match;
      return path.isEmpty ? null : path;
    }
    final raw = settings?.name;
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  void _log({required String action, String? from, String? to}) {
    final fromPart = from != null ? '$from  →  ' : '';
    final toPart = to ?? '—';
    log('$action  $fromPart$toPart', name: _logName);
  }
}
