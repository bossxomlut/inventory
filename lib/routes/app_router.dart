import 'package:flutter/material.dart';

import '../domain/index.dart';
import '../features/authentication/provider/auth_provider.dart';
import '../provider/index.dart';
import '../shared_widgets/index.dart';
import '../shared_widgets/toast.dart';
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
        AutoRoute(page: CheckRoute.page),

        //Price and Order routes
        AutoRoute(page: ConfigProductPriceRoute.page),
        AutoRoute(page: CreateOrderRoute.page),
        AutoRoute(page: OrderDetailRoute.page),
        AutoRoute(page: OrderStatusListRoute.page),

        //data management routes
        AutoRoute(page: CreateSampleDataRoute.page),
        AutoRoute(page: ExportDataRoute.page),
        AutoRoute(page: DeleteDataRoute.page),

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

  //get context
  BuildContext? get context {
    return navigatorKey.currentContext;
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
    switch (role) {
      case UserRole.admin:
        goToAdminHome();
      case UserRole.user:
        goToUserHome();
      case UserRole.guest:
        goToAdminHome();
        break;
    }
  }

  void goToAdminHome() {
    replaceAll([const HomeRoute2()]);
  }

  void goToUserHome() {
    replaceAll([const HomeRoute2()]);
  }
}

extension PriceAndOrderRouterX on AppRouter {
  void goToConfigProductPrice() {
    push(ConfigProductPriceRoute());
  }

  Future<dynamic> goToCreateOrder({Order? order}) {
    return push(CreateOrderRoute(order: order));
  }

  Future<dynamic> goToUpdateDraftOrder(Order order) {
    return replace(CreateOrderRoute(order: order));
  }

  Future<dynamic> goToOrderDetail(Order order) {
    return push(OrderDetailRoute(order: order));
  }

  void goToOrderStatusList() {
    push(OrderStatusListRoute());
  }
}

extension AdminRouterX on AppRouter {
  void goToUserManagement() {
    push(const UserRoute());
  }
}

extension SettingRouterX on AppRouter {
  void goToSetting() {
    push(SettingRoute());
  }
}

extension DataManagementRouterX on AppRouter {
  void goToCreateSampleData() {
    push(CreateSampleDataRoute());
  }

  void goToExportData() {
    push(ExportDataRoute());
  }

  void goToDeleteData() {
    push(DeleteDataRoute());
  }
}

class AdminGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Access the BuildContext from the resolver
    final context = router.navigatorKey.currentContext;

    if (context != null) {
      // Read the provider using the context
      //get user by ref
      final user = context.read(authControllerProvider);
      user.when(
        authenticated: (User user, DateTime? lastLoginTime) {
          if (user.role == UserRole.admin || user.role == UserRole.guest) {
            resolver.next();
          } else {
            showError(message: 'Bạn không có quyền truy cập vào trang này');
            resolver.next(false);
          }
        },
        unauthenticated: () {
          router.push(LoginRoute());
          resolver.next(false);
        },
        initial: () {
          router.push(LoginRoute());
          resolver.next(false);
        },
      );
    } else {
      // Handle case where context is null (e.g., redirect to error or login)
      router.push(LoginRoute());
      resolver.next(false);
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
