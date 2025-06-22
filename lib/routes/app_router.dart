import '../domain/index.dart';
import '../shared_widgets/index.dart';
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
        AutoRoute(page: AnalyzeScannerRoute.page),

        //authentication routes
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: SignUpRoute.page),
        AutoRoute(page: ForgotPasswordRoute.page),
        AutoRoute(page: ResetPasswordRoute.page),
        AutoRoute(page: PinCodeRoute.page),

        //setting routes
        AutoRoute(page: SettingRoute.page),

        //home routes
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: HomeRoute2.page),

        //product routes
        AutoRoute(page: ProductListRoute.page),
        AutoRoute(page: ProductDetailRoute.page),
        AutoRoute(page: CategoryRoute.page),
        AutoRoute(page: UnitRoute.page),

        //Check routes
        AutoRoute(page: CheckSessionsRoute.page),

        //config admin route
        AutoRoute(
          page: UserRoute.page,
          guards: [
            AdminGuard(),
          ],
        ),
      ];

  @override
  Future<T?> push<T extends Object?>(PageRouteInfo route, {OnNavigationFailure? onFailure}) {
    navigatorKey.currentContext?.hideKeyboard();
    return super.push(route, onFailure: onFailure);
  }
}

extension AuthRouterX on AppRouter {
  void goToLogin() {
    replaceAll([LoginRoute()]);
  }

  void goToLoginByPinCode() {
    replaceAll([PinCodeRoute()]);
  }

  Future<void> goToPinCode() {
    return push(PinCodeRoute());
  }

  void goToSignUp() {
    push(SignUpRoute());
  }

  void goToForgotPassword() {
    push(ForgotPasswordRoute());
  }

  void goToResetPassword() {
    push(ResetPasswordRoute());
  }
}

extension AppRouterX on AppRouter {
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
    // replaceAll([const InventoryRoute()]);
  }

  void goToCheckSessions() {
    push(CheckSessionsRoute());
  }
}

extension HomeByRoleRouterX on AppRouter {
  void goHomeByRole(UserRole role) {
    if (role == UserRole.admin) {
      goToAdminHome();
    } else if (role == UserRole.user) {
      goToUserHome();
    }
  }

  void goToAdminHome() {
    replaceAll([const HomeRoute2()]);
  }

  void goToUserHome() {
    replaceAll([const HomeRoute2()]);
  }
}

extension AdminRouterX on AppRouter {
  void goAdminHome() {
    replaceAll(
      [const UserRoute()],
    );
  }
}

extension SettingRouterX on AppRouter {
  void goToSetting() {
    push(SettingRoute());
  }
}

class AdminGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final user = resolver.route.args as User;
    if (user.role == UserRole.admin) {
      resolver.next(true);
    } else {
      router.push(LoginRoute());
    }
  }
}

extension AppRouterInventoryX on AppRouter {
  void goToProductList() {
    push(ProductListRoute());
  }

  void goToProductDetail(Product product) {
    push(ProductDetailRoute(product: product));
  }

  void goToCategory() {
    push(CategoryRoute());
  }

  void goToUnit() {
    push(UnitRoute());
  }
}
