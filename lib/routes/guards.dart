//create auth guard
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/helpers/scaffold_utils.dart';
import '../domain/entities/permission/permission.dart';
import '../domain/entities/user/user.dart';
import '../features/authentication/provider/auth_provider.dart';
import '../provider/index.dart';
import '../shared_widgets/toast.dart';
import 'app_router.dart';

const _permissionDeniedMessage = 'Bạn không có quyền truy cập vào trang này';
const _permissionCheckFailedMessage = 'Không thể kiểm tra quyền truy cập';

enum PermissionGuardDecision { allow, redirectToLogin, deny }

class PermissionGuardEvaluation {
  const PermissionGuardEvaluation._({
    required this.decision,
    this.errorMessage,
  });

  final PermissionGuardDecision decision;
  final String? errorMessage;

  const PermissionGuardEvaluation.allow()
      : this._(decision: PermissionGuardDecision.allow);

  const PermissionGuardEvaluation.redirectToLogin()
      : this._(decision: PermissionGuardDecision.redirectToLogin);

  const PermissionGuardEvaluation.deny(String? message)
      : this._(decision: PermissionGuardDecision.deny, errorMessage: message);
}

@visibleForTesting
Future<PermissionGuardEvaluation> evaluatePermissionGuard({
  required ProviderContainer container,
  required PermissionKey requiredPermission,
}) async {
    final authState = container.read(authControllerProvider);

    return authState.when<Future<PermissionGuardEvaluation>>(
      authenticated: (User user, DateTime? lastLoginTime) async {
        if (user.role == UserRole.admin || user.role == UserRole.guest) {
          return const PermissionGuardEvaluation.allow();
        }

        final permissionsValue = container.read(currentUserPermissionsProvider);

        if (permissionsValue.hasError) {
          return const PermissionGuardEvaluation.deny(
            _permissionCheckFailedMessage,
          );
        }

        if (permissionsValue.hasValue) {
          return permissionsValue.value!.contains(requiredPermission)
              ? const PermissionGuardEvaluation.allow()
              : const PermissionGuardEvaluation.deny(
                  _permissionDeniedMessage,
                );
        }

        try {
          final permissions =
              await container.read(currentUserPermissionsProvider.future);
          if (permissions.contains(requiredPermission)) {
            return const PermissionGuardEvaluation.allow();
          }
          return const PermissionGuardEvaluation.deny(
            _permissionDeniedMessage,
          );
        } catch (_) {
          return const PermissionGuardEvaluation.deny(
            _permissionCheckFailedMessage,
          );
        }
      },
      unauthenticated: () async =>
          const PermissionGuardEvaluation.redirectToLogin(),
      initial: () async => const PermissionGuardEvaluation.redirectToLogin(),
    );
}

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
    evaluatePermissionGuard(
      container: container,
      requiredPermission: requiredPermission,
    ).then((evaluation) {
      switch (evaluation.decision) {
        case PermissionGuardDecision.allow:
          resolver.next();
          break;
        case PermissionGuardDecision.redirectToLogin:
          router.push(LoginRoute());
          resolver.next(false);
          break;
        case PermissionGuardDecision.deny:
          if (evaluation.errorMessage != null) {
            showError(message: evaluation.errorMessage!);
          }
          resolver.next(false);
          break;
      }
    });
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
