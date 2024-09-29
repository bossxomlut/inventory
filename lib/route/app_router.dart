import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

export 'route_logger_observer.dart';

final AppRouter _appRouter = AppRouter();

AppRouter get appRouter => _appRouter;

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: LoginRoute.page),
      ];
}
