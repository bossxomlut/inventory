//create auth guard
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/helpers/scaffold_utils.dart';
import '../domain/entities/permission/permission.dart';
import '../domain/entities/user/user.dart';
import '../features/authentication/provider/auth_provider.dart';
import '../features/user/provider/user_permission_controller.dart';
import '../provider/index.dart';
import '../shared_widgets/toast.dart';
import 'app_router.dart';

class AdminGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Access the BuildContext from the resolver
    final context = router.navigatorKey.currentContext;

    if (context != null) {
      // Read the provider using the context
      //get user by ref
      final container = ProviderScope.containerOf(context, listen: false);
      final user = container.read(authControllerProvider);
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

class PermissionGuard extends AutoRouteGuard {
  const PermissionGuard(this.requiredPermission);

  final PermissionKey requiredPermission;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final context = router.navigatorKey.currentContext;

    if (context == null) {
      router.push(LoginRoute());
      resolver.next(false);
      return;
    }

    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authControllerProvider);
    authState.when(
      authenticated: (User user, DateTime? lastLoginTime) {
        if (user.role == UserRole.admin || user.role == UserRole.guest) {
          resolver.next();
          return;
        }

        final permissionsValue =
            container.read(userPermissionControllerProvider(user.id));

        if (permissionsValue.hasError) {
          showError(message: 'Không thể kiểm tra quyền truy cập');
          resolver.next(false);
          return;
        }

        if (permissionsValue.hasValue) {
          if (permissionsValue.value!.contains(requiredPermission)) {
            resolver.next();
          } else {
            showError(message: 'Bạn không có quyền truy cập vào trang này');
            resolver.next(false);
          }
          return;
        }

        container
            .read(userPermissionControllerProvider(user.id).future)
            .then((value) {
          if (value.contains(requiredPermission)) {
            resolver.next();
          } else {
            showError(message: 'Bạn không có quyền truy cập vào trang này');
            resolver.next(false);
          }
        }).catchError((error) {
          showError(message: 'Không thể kiểm tra quyền truy cập');
          resolver.next(false);
        });
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
  }
}

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // Access the BuildContext from the resolver
    final context = router.navigatorKey.currentContext;

    if (context != null) {
      // Read the provider using the context
      //get user by ref
      final container = ProviderScope.containerOf(context, listen: false);
      final user = container.read(authControllerProvider);
      user.when(
        authenticated: (User user, DateTime? lastLoginTime) {
          resolver.next();
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
