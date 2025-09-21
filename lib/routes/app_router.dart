import 'package:flutter/material.dart';

import '../domain/entities/permission/permission.dart';
import '../domain/index.dart';
import '../shared_widgets/index.dart';
import 'app_router.gr.dart';
import 'guards.dart';

export 'package:sample_app/routes/app_router.gr.dart';

export 'route_logger_observer.dart';

final AppRouter _appRouter = AppRouter();

AppRouter get appRouter => _appRouter;

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(page: SplashRoute.page, initial: true),

        //onboarding route
        AutoRoute(page: OnboardingRoute.page),

        //authentication routes
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: SignUpRoute.page),
        AutoRoute(page: ForgotPasswordRoute.page),
        AutoRoute(page: ResetPasswordRoute.page),
        AutoRoute(page: PinCodeRoute.page),

        //setting routes
        AutoRoute(
          page: SettingRoute.page,
          guards: [
            // AdminGuard(),
          ],
        ),

        //home routes
        AutoRoute(
          page: HomeRoute.page,
          guards: [
            AuthGuard(),
          ],
        ),
        AutoRoute(page: HomeRoute2.page),

        //product routes
        AutoRoute(
          page: ProductListRoute.page,
          guards: [
            AuthGuard(),
            PermissionGuard(PermissionKey.productView),
          ],
        ),
        AutoRoute(
          page: ProductDetailRoute.page,
          guards: [
            AuthGuard(),
            PermissionGuard(PermissionKey.productView),
          ],
        ),
        AutoRoute(
          page: CategoryRoute.page,
          guards: [
            AuthGuard(),
            PermissionGuard(PermissionKey.categoryView),
          ],
        ),
        AutoRoute(
          page: UnitRoute.page,
          guards: [
            AuthGuard(),
            PermissionGuard(PermissionKey.unitView),
          ],
        ),

        //Check routes
        AutoRoute(
          page: CheckSessionsRoute.page,
          guards: [
            AuthGuard(),
            PermissionGuard(PermissionKey.inventoryView),
          ],
        ),
        AutoRoute(
          page: CheckRoute.page,
          guards: [
            AuthGuard(),
            PermissionGuard(PermissionKey.inventoryView),
          ],
        ),

        //Price and Order routes
        AutoRoute(
          page: ConfigProductPriceRoute.page,
          guards: [
            AuthGuard(),
            PermissionGuard(PermissionKey.priceUpdate),
          ],
        ),
        AutoRoute(
          page: CreateOrderRoute.page,
          guards: [
            AuthGuard(),
            PermissionGuard(PermissionKey.orderCreate),
          ],
        ),
        AutoRoute(
          page: OrderDetailRoute.page,
          guards: [
            AuthGuard(),
            PermissionGuard(PermissionKey.orderView),
          ],
        ),
        AutoRoute(
          page: OrderStatusListRoute.page,
          guards: [
            AuthGuard(),
            PermissionGuard(PermissionKey.orderView),
          ],
        ),

        //data management routes
        AutoRoute(
          page: CreateSampleDataRoute.page,
          guards: [
            PermissionGuard(PermissionKey.dataCreateSample),
          ],
        ),
        AutoRoute(
          page: ExportDataRoute.page,
          guards: [
            PermissionGuard(PermissionKey.dataExport),
          ],
        ),
        AutoRoute(
          page: DeleteDataRoute.page,
          guards: [
            PermissionGuard(PermissionKey.dataDelete),
          ],
        ),
        AutoRoute(
          page: ImportDataRoute.page,
          guards: [
            PermissionGuard(PermissionKey.dataImport),
          ],
        ),

        //config admin route
        AutoRoute(
          page: UserRoute.page,
          guards: [
            PermissionGuard(PermissionKey.userManage),
          ],
        ),
        AutoRoute(
          page: UserPermissionRoute.page,
          guards: [
            PermissionGuard(PermissionKey.permissionManage),
          ],
        ),

        //report route
        AutoRoute(
          page: ReportRoute.page,
          guards: [
            PermissionGuard(PermissionKey.reportView),
          ],
        ),
      ];

  @override
  Future<T?> push<T extends Object?>(PageRouteInfo route,
      {OnNavigationFailure? onFailure}) {
    navigatorKey.currentContext?.hideKeyboard();
    return super.push(route, onFailure: onFailure);
  }

  //get context
  BuildContext? get context {
    return navigatorKey.currentContext;
  }
}

extension AuthRouterX on AppRouter {
  void goToOnboarding() {
    replaceAll([OnboardingRoute()]);
  }

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

  void goToUserPermission(User user) {
    push(UserPermissionRoute(user: user));
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

  void goToImportData() {
    push(ImportDataRoute());
  }

  void goToExportData() {
    push(ExportDataRoute());
  }

  void goToDeleteData() {
    push(DeleteDataRoute());
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

extension ReportRouterX on AppRouter {
  void goToReport() {
    push(ReportRoute());
  }
}
