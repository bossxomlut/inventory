import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:isar/isar.dart';
import 'package:restart_app/restart_app.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/index.dart';
import '../../../core/persistence/simple_key_value_storage.dart';
import '../../../domain/entities/order/price.dart';
import '../../../domain/index.dart';
import '../../../domain/repositories/auth/pin_code_repository.dart';
import '../../../domain/repositories/order/price_repository.dart';
import '../../../domain/repositories/product/inventory_repository.dart';
import '../../../domain/repositories/product/update_product_repository.dart';
import '../../../routes/app_router.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  static const String _authStateKey = 'auth_state';
  static const String _isCreatedGuestData = 'is_created_guest_data';

  @override
  AuthState build() => const AuthState.initial();

  // Initialize AuthState

  // Load AuthState from SharedPreferences
  Future<void> checkLogin() async {
    final AuthState authState = await _loadAuthData();
    state = authState;

    try {
      authState.maybeWhen(
        orElse: () {
          appRouter.goToLogin();
        },
        authenticated: (user, DateTime? lastLoginTime) async {
          final pinCodeRepository = ref.read(pinCodeRepositoryProvider);

          if (user.role == UserRole.guest) {
            //check load database for guest mode use _isCreatedGuestData
            final prefs = SimpleStorage();
            await prefs.init();
            final isCreatedGuestData = await prefs.getBool(_isCreatedGuestData);
            if (isCreatedGuestData != true) {
              //load assets
              try {
                final stringData = await rootBundle.loadString('assets/data/mock.jsonl');

                final categoryRepository = ref.read(categoryRepositoryProvider);
                final unitRepository = ref.read(unitRepositoryProvider);
                final updateProductRepo = ref.read(updateProductRepositoryProvider);
                final priceRepository = ref.read(priceRepositoryProvider);
                final lines = stringData.split('\n');
                for (final line in lines) {
                  try {
                    final jsonData = jsonDecode(line) as Map<String, dynamic>;
                    String? categoryName = jsonData['categoryName'] as String?;
                    String? unitName = jsonData['unitName'] as String?;
                    //find or create category
                    Category? category;
                    if (categoryName != null) {
                      category = await categoryRepository.searchByName(categoryName);
                      if (category == null) {
                        category = await categoryRepository.create(Category(id: undefinedId, name: categoryName));
                      }
                    }

                    Unit? unit;
                    //find or create unit
                    if (unitName != null) {
                      unit = await unitRepository.searchByName(unitName);
                      if (unit == null) {
                        unit = await unitRepository.create(Unit(id: undefinedId, name: unitName));
                      }
                    }

                    //create product
                    final product = Product.fromJson(jsonData);

                    await updateProductRepo.createProduct(product.copyWith(
                      category: category,
                      unit: unit,
                    ));

                    final double? price = jsonData.parseDouble('price');
                    if (price != null) {
                      //create price
                      await priceRepository.create(
                        ProductPrice(
                          id: undefinedId,
                          productId: product.id,
                          productName: product.name,
                          sellingPrice: price,
                        ),
                      );
                    }
                  } catch (e) {
                    // Handle parsing error or invalid JSON line
                    print('Error parsing line: $line, Error: $e');
                  }
                }

                //set is created guest data
              } catch (e) {}

              await prefs.saveBool(_isCreatedGuestData, true);
            }
          }

          pinCodeRepository.isSetPinCode.then(
            (bool value) {
              if (value) {
                appRouter.goToLoginByPinCode();
              } else {
                appRouter.goHome();
              }
            },
          );
        },
      );
    } catch (e) {
      appRouter.goToLogin();
    }
  }

  Future<AuthState> _loadAuthData() async {
    try {
      final prefs = ref.read(securityStorageProvider);
      final authState = await prefs.getObject(_authStateKey, AuthState.fromJson);

      if (authState != null) {
        return authState;
      }
    } catch (e) {}
    return const AuthState.unauthenticated();
  }

  // Save AuthState to SharedPreferences
  Future<void> _saveAuthState(AuthState state) async {
    final prefs = ref.read(securityStorageProvider);
    await prefs.saveObject<AuthState>(
      _authStateKey,
      state,
      (value) => state.toJson(),
    );
  }

  // Login method
  Future<void> login({
    required int id,
    required String username,
    required UserRole role,
  }) async {
    final newState = AuthState.authenticated(
      user: User(
        id: id,
        username: username,
        role: role,
      ),
      lastLoginTime: DateTime.now(),
    );
    state = newState;
    await _saveAuthState(newState);
  }

  //guest login method
  Future<void> guestLogin() async {
    final newState = AuthState.authenticated(
      user: User(
        id: -1,
        username: 'Guest',
        role: UserRole.guest,
      ),
      lastLoginTime: DateTime.now(),
    );
    state = newState;
    await _saveAuthState(newState);

    await Isar.getInstance()!.close();

    //kill and restart the app to apply guest mode
    Restart.restartApp(
      /// In Web Platform, Fill webOrigin only when your new origin is different than the app's origin
      // webOrigin: 'http://example.com',

      // Customizing the notification message only on iOS
      notificationTitle: 'Restarting App',
      notificationBody: 'Please tap here to open the app again.',
    );
  }

  // Logout method
  Future<void> logout() async {
    //check if use is guest
    final isGuest = state.maybeWhen(
      authenticated: (user, lastLoginTime) => user.role == UserRole.guest,
      orElse: () => false,
    );
    if (isGuest) {
      state = const AuthState.unauthenticated();
      final prefs = ref.read(securityStorageProvider);
      prefs.removeObject(_authStateKey);

      await Isar.getInstance()!.close();

      //kill and restart the app to apply guest mode
      Restart.restartApp(
        /// In Web Platform, Fill webOrigin only when your new origin is different than the app's origin
        // webOrigin: 'http://example.com',

        // Customizing the notification message only on iOS
        notificationTitle: 'Restarting App',
        notificationBody: 'Please tap here to open the app again.',
      );
    } else {
      state = const AuthState.unauthenticated();
      final prefs = ref.read(securityStorageProvider);
      await prefs.removeObject(_authStateKey);
      appRouter.goToLogin();
    }
  }
}
