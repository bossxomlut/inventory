import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

export 'package:sample_app/routes/app_router.gr.dart';

export 'route_logger_observer.dart';

final AppRouter _appRouter = AppRouter();

AppRouter get appRouter => _appRouter;

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: DemoRiverpodRoute.page),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: SignUpRoute.page),
        AutoRoute(page: AnalyzeScannerRoute.page),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: HomeRoute2.page),
        AutoRoute(page: InventoryRoute.page),
      ];
}

extension AppRouterX on AppRouter {
  void goToLogin() {
    replaceAll(const [LoginRoute()]);
  }

  void goToSignUp() {
    push(SignUpRoute());
  }

  void goHome() {
    replaceAll(const [HomeRoute2()]);
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
    replaceAll([const InventoryRoute()]);
  }
}
