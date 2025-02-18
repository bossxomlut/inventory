import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

export 'route_logger_observer.dart';

final AppRouter _appRouter = AppRouter();

AppRouter get appRouter => _appRouter;

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: DemoRiverpodRoute.page),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: InventoryRoute.page),
      ];
}

extension AppRouterX on AppRouter {
  void goHome() {
    //todo: fix
    replaceAll(const [HomeRoute()]);
  }

  void pushAndRemoveUntilHome(PageRouteInfo route) {
    pushAndPopUntil(route, predicate: (r) => r.isFirst);
  }

  void pushAndReplaceAll(PageRouteInfo route) {
    pushAndPopUntil(route, predicate: (r) => false);
  }
}

extension InventoryRouterX on AppRouter {
  void goInventory() {
    push(const InventoryRoute());
  }
}
