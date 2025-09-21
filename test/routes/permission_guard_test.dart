import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'package:sample_app/domain/entities/auth/auth_state.dart';
import 'package:sample_app/domain/entities/permission/permission.dart';
import 'package:sample_app/domain/entities/user/user.dart';
import 'package:sample_app/features/authentication/provider/auth_provider.dart';
import 'package:sample_app/provider/permissions.dart';
import 'package:sample_app/routes/guards.dart';

class _TestAuthController extends AuthController {
  _TestAuthController(this._state);

  final AuthState _state;

  @override
  AuthState build() => _state;
}

ProviderContainer _createContainer({
  required AuthState authState,
  required Future<Set<PermissionKey>> Function() permissionLoader,
}) {
  return ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(() => _TestAuthController(authState)),
      currentUserPermissionsProvider.overrideWith((ref) => permissionLoader()),
    ],
  );
}

void main() {
  test('allows admin user without checking permissions', () async {
    final container = _createContainer(
      authState: AuthState.authenticated(
        user: User(id: 1, username: 'admin', role: UserRole.admin),
        lastLoginTime: DateTime(2024, 1, 1),
      ),
      permissionLoader: () async => <PermissionKey>{},
    );
    addTearDown(container.dispose);

    final evaluation = await evaluatePermissionGuard(
      container: container,
      requiredPermission: PermissionKey.productView,
    );

    expect(evaluation.decision, PermissionGuardDecision.allow);
    expect(evaluation.errorMessage, isNull);
  });

  test('denies access when permission missing for regular user', () async {
    final container = _createContainer(
      authState: AuthState.authenticated(
        user: User(id: 2, username: 'staff', role: UserRole.user),
        lastLoginTime: DateTime(2024, 1, 1),
      ),
      permissionLoader: () async => <PermissionKey>{PermissionKey.dataExport},
    );
    addTearDown(container.dispose);

    final evaluation = await evaluatePermissionGuard(
      container: container,
      requiredPermission: PermissionKey.productView,
    );

    expect(evaluation.decision, PermissionGuardDecision.deny);
    expect(evaluation.errorMessage, 'Bạn không có quyền truy cập vào trang này');
  });

  test('redirects to login when unauthenticated', () async {
    final container = _createContainer(
      authState: const AuthState.unauthenticated(),
      permissionLoader: () async => <PermissionKey>{},
    );
    addTearDown(container.dispose);

    final evaluation = await evaluatePermissionGuard(
      container: container,
      requiredPermission: PermissionKey.productView,
    );

    expect(evaluation.decision, PermissionGuardDecision.redirectToLogin);
  });

  test('returns check failed message when permission loading throws', () async {
    final container = _createContainer(
      authState: AuthState.authenticated(
        user: User(id: 3, username: 'user', role: UserRole.user),
        lastLoginTime: DateTime(2024, 1, 1),
      ),
      permissionLoader: () => Future<Set<PermissionKey>>.error(Exception('boom')),
    );
    addTearDown(container.dispose);

    final evaluation = await evaluatePermissionGuard(
      container: container,
      requiredPermission: PermissionKey.productView,
    );

    expect(evaluation.decision, PermissionGuardDecision.deny);
    expect(evaluation.errorMessage, 'Không thể kiểm tra quyền truy cập');
  });
}
