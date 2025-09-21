import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/entities/get_id.dart';
import '../../../domain/entities/order/price.dart';
import '../../../domain/entities/product/inventory.dart';
import '../../../domain/repositories/order/price_repository.dart';
import '../../../logger.dart';
import '../../product/provider/product_provider.dart';

final configPriceFormControllerProvider =
    StateNotifierProvider.autoDispose.family<
        ConfigPriceFormController,
        ConfigPriceFormState,
        ConfigPriceFormArgs>(
  (ref, args) => ConfigPriceFormController(ref, args),
);

class ConfigPriceFormArgs {
  const ConfigPriceFormArgs({required this.product, this.initialPrice});

  final Product product;
  final ProductPrice? initialPrice;
}

class ConfigPriceFormState {
  const ConfigPriceFormState({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;
}

class ConfigPriceFormResult {
  const ConfigPriceFormResult._({
    this.savedPrice,
    this.errorMessage,
    this.isValidationError = false,
  });

  final ProductPrice? savedPrice;
  final String? errorMessage;
  final bool isValidationError;

  bool get isSuccess => savedPrice != null;

  factory ConfigPriceFormResult.success(ProductPrice price) {
    return ConfigPriceFormResult._(savedPrice: price);
  }

  factory ConfigPriceFormResult.validationError(String message) {
    return ConfigPriceFormResult._(
      errorMessage: message,
      isValidationError: true,
    );
  }

  factory ConfigPriceFormResult.failure(String message) {
    return ConfigPriceFormResult._(errorMessage: message);
  }
}

class ConfigPriceFormController extends StateNotifier<ConfigPriceFormState> {
  ConfigPriceFormController(this._ref, ConfigPriceFormArgs args)
      : _product = args.product,
        _initialPrice = args.initialPrice,
        super(const ConfigPriceFormState());

  final Ref _ref;
  final Product _product;
  ProductPrice? _initialPrice;

  Future<ConfigPriceFormResult> save({
    required String sellingText,
    required String purchaseText,
  }) async {
    final sellingParse = _parsePrice(sellingText);
    if (sellingParse == null && sellingText.trim().isNotEmpty) {
      const message = 'Vui lòng nhập đúng định dạng số';
      state = const ConfigPriceFormState(errorMessage: message);
      return ConfigPriceFormResult.validationError(message);
    }

    final purchaseParse = _parsePrice(purchaseText);
    if (purchaseParse == null && purchaseText.trim().isNotEmpty) {
      const message = 'Vui lòng nhập đúng định dạng số';
      state = const ConfigPriceFormState(errorMessage: message);
      return ConfigPriceFormResult.validationError(message);
    }

    state = const ConfigPriceFormState(isSaving: true);

    try {
      final repository = _ref.read(priceRepositoryProvider);
      final updatedPrice = await _persistPrice(
        repository: repository,
        selling: sellingParse,
        purchase: purchaseParse,
      );

      userConfigLogger.i(
        '[ConfigPrice] Saved price for product ${_product.id} -> '
        'selling: ${updatedPrice.sellingPrice}, '
        'purchase: ${updatedPrice.purchasePrice}',
      );
      _ref.invalidate(productPriceByIdProvider(_product.id));
      state = const ConfigPriceFormState();
      return ConfigPriceFormResult.success(updatedPrice);
    } catch (error, stackTrace) {
      userConfigLogger.e(
        '[ConfigPrice] Failed to save price for product ${_product.id}',
        error: error,
        stackTrace: stackTrace,
      );
      const message = 'Không thể lưu giá, vui lòng thử lại sau';
      state = const ConfigPriceFormState(errorMessage: message);
      return ConfigPriceFormResult.failure(message);
    }
  }

  Future<ProductPrice> _persistPrice({
    required PriceRepository repository,
    required double? selling,
    required double? purchase,
  }) {
    if (_initialPrice != null) {
      final updated = _initialPrice!.copyWith(
        sellingPrice: selling,
        purchasePrice: purchase,
      );
      return repository.update(updated).then((value) {
        _initialPrice = value;
        return value;
      });
    }

    final created = ProductPrice(
      id: undefinedId,
      productId: _product.id,
      productName: _product.name,
      sellingPrice: selling,
      purchasePrice: purchase,
    );

    return repository.create(created).then((value) {
      _initialPrice = value;
      return value;
    });
  }

  double? _parsePrice(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed);
  }
}
