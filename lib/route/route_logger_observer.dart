import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../logger/logger.dart';

class RouteLoggerObserver extends AutoRouterObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    routeLogger.i('go-to ${route.settings.name}');
  }

  @override
  Future<void> didPop(Route route, Route? previousRoute) async {
    routeLogger.i('back-to ${previousRoute?.settings.name}');
  }
}
