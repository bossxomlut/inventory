import 'package:barcode/barcode.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:sample_app/shared_widgets/image/common_image_picker.dart';
import 'package:sample_app/shared_widgets/index.dart';

import '../../../domain/entities/image.dart';
import '../../../domain/entities/index.dart';
import '../../../provider/index.dart';
import '../../../resources/index.dart';
import '../../../shared_widgets/toast.dart';
import '../../category/select_category_widget.dart';
import '../../unit/add_unit_placeholder.dart';
import '../provider/product_provider.dart';

// Add product bottom sheet
class AddProductScreen extends HookConsumerWidget with ShowBottomSheet<void> {
  const AddProductScreen({super.key});

  @override
  Future<void> show(BuildContext context, {bool isScafold = true}) {
    return super.show(
      context,
      isScafold: isScafold,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _nameController = useTextEditingController();
    final _noteController = useTextEditingController();
    final _category = useState<Category?>(null);
    final _sku = useState<String?>(null);
    final _unit = useState<Unit?>(null);
    final quantity = useState<int>(0);
    final images = useState<List<ImageStorageModel>>([]);
    final enableExpiryTracking = useState<bool>(false);
    final lotDrafts = useState<List<_LotDraft>>(<_LotDraft>[]);
    final dateFormat = useMemoized(() => DateFormat('dd/MM/yyyy'));
    String t(String key) => key.tr(context: context);

    int totalLotQuantity() =>
        lotDrafts.value.fold<int>(0, (sum, lot) => sum + lot.quantity);

    void _syncTrackedQuantity() {
      quantity.value = totalLotQuantity();
    }

    void addLot() {
      lotDrafts.value = [
        ...lotDrafts.value,
        const _LotDraft(id: undefinedId, quantity: 0),
      ];
      _syncTrackedQuantity();
    }

    void updateLot(int index, _LotDraft updated) {
      if (index < 0 || index >= lotDrafts.value.length) {
        return;
      }
      final updatedLots = [...lotDrafts.value];
      updatedLots[index] = updated;
      lotDrafts.value = updatedLots;
      _syncTrackedQuantity();
    }

    void updateLotQuantity(int index, int value) {
      updateLot(index, lotDrafts.value[index].copyWith(quantity: value));
    }

    void updateLotExpiry(int index, DateTime date) {
      updateLot(
          index,
          lotDrafts.value[index]
              .copyWith(expiryDate: date, clearExpiryDate: false));
    }

    void updateLotManufacture(int index, DateTime? date) {
      updateLot(
          index,
          lotDrafts.value[index].copyWith(
            manufactureDate: date,
            clearManufactureDate: date == null,
          ));
    }

    void removeLot(int index) {
      if (index < 0 || index >= lotDrafts.value.length) {
        return;
      }
      final updatedLots = [...lotDrafts.value]..removeAt(index);
      lotDrafts.value = updatedLots;
      _syncTrackedQuantity();
    }

    final permissionsAsync = ref.watch(currentUserPermissionsProvider);
    final bool canCreateProduct = permissionsAsync.maybeWhen(
      data: (value) => value.contains(PermissionKey.productCreate),
      orElse: () => false,
    );

    bool isKeyboardVisible = ref.watch(isKeyboardVisibleProvider);

    void onSave() {
      if (!canCreateProduct) {
        return;
      }

      context.hideKeyboard();

      // Create a new product
      final name = _nameController.text.trim();
      final note = _noteController.text.trim();
      final sku = _sku.value;

      // Validate inputs
      if (name.isEmpty) {
        showError(
          message: t(LKey.productFormValidationRequired),
        );
        return;
      }

      List<InventoryLot> inventoryLots = const [];
      int finalQuantity = quantity.value;

      if (enableExpiryTracking.value) {
        final validationMessage = _validateLotDrafts(context, lotDrafts.value);
        if (validationMessage != null) {
          showError(message: validationMessage);
          return;
        }

        inventoryLots = lotDrafts.value
            .map(
              (lot) => lot.toInventoryLot(productId: undefinedId),
            )
            .toList();
        finalQuantity =
            inventoryLots.fold<int>(0, (sum, lot) => sum + lot.quantity);
      }

      final newProduct = Product(
        id: undefinedId,
        name: name,
        description: note,
        images: [...images.value],
        quantity: finalQuantity,
        category: _category.value,
        unit: _unit.value,
        barcode: sku,
        enableExpiryTracking: enableExpiryTracking.value,
        lots: inventoryLots,
      );

      ref.read(loadProductProvider.notifier).createProduct(newProduct);
    }

    final Widget form = Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: t(LKey.productFormCreateTitle),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (isKeyboardVisible && canCreateProduct)
            IconButton(
              icon: Text(
                t(LKey.buttonSave),
                style: context.appTheme.textMedium15Default
                    .copyWith(color: Colors.white),
              ),
              onPressed: onSave,
            ),
        ],
        // centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TitleBlockWidget(
                              isRequired: true,
                              title: t(LKey.productFormFieldNameLabel),
                              child: CustomTextField.multiLines(
                                hint: t(LKey.productFormFieldNameHint),
                                controller: _nameController,
                                minLines: 3,
                                autofocus: true,
                              ),
                            ),

                            separateGapItem, // Quantity
                            TitleBlockWidget(
                              title: t(LKey.productFormFieldQuantityLabel),
                              isRequired: true,
                              child: enableExpiryTracking.value
                                  ? _LotQuantitySummary(
                                      context,
                                      totalLotQuantity(),
                                    )
                                  : PlusMinusInputView(
                                      initialValue: 0,
                                      onChanged: (int value) {
                                        quantity.value = value;
                                      },
                                      minValue: 0,
                                    ),
                            ),
                            separateGapItem,
                            TitleBlockWidget(
                              title: t(LKey.productFormFieldExpiryLabel),
                              child: _ExpiryTrackingSwitch(
                                value: enableExpiryTracking.value,
                                onChanged: (value) {
                                  enableExpiryTracking.value = value;
                                  if (value) {
                                    if (lotDrafts.value.isEmpty) {
                                      addLot();
                                    } else {
                                      _syncTrackedQuantity();
                                    }
                                  }
                                },
                              ),
                            ),
                            if (enableExpiryTracking.value) ...[
                              separateGapItem,
                              _InventoryLotSection(
                                lots: lotDrafts.value,
                                dateFormat: dateFormat,
                                onAddLot: addLot,
                                onRemoveLot: removeLot,
                                onQuantityChanged: updateLotQuantity,
                                onExpiryChanged: updateLotExpiry,
                                onManufactureChanged: updateLotManufacture,
                              ),
                            ],
                            separateGapItem,
                            TitleBlockWidget(
                              title: t(LKey.productFormFieldSkuLabel),
                              child: AddSKUPlaceHolder(
                                value: _sku.value,
                                onSelected: (String? value) {
                                  _sku.value = value;
                                },
                              ),
                            ),
                            separateGapItem,
                            TitleBlockWidget(
                              title: t(LKey.productFormFieldCategoryLabel),
                              child: AddCategoryPlaceHolder(
                                value: _category.value,
                                onSelected: (Category? value) {
                                  _category.value = value;
                                },
                              ),
                            ),
                            separateGapItem,
                            TitleBlockWidget(
                              title: t(LKey.productFormFieldUnitLabel),
                              child: AddUnitPlaceHolder(
                                value: _unit.value,
                                onSelected: (Unit? value) {
                                  _unit.value = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      separateGapBlock,
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: TitleBlockWidget(
                          title: t(LKey.productFormFieldImagesLabel),
                          child: CommonImagePicker(
                            title: t(LKey.productFormFieldImagesAdd),
                            images: images.value,
                            onImagesSelected: (List<ImageStorageModel> value) {
                              images.value = [...images.value, ...value];
                            },
                            onImagesChanged: (List<ImageStorageModel> value) {
                              images.value = value;
                            },
                            onImageRemoved: (ImageStorageModel file) {
                              images.value =
                                  images.value.where((e) => e != file).toList();
                            },
                          ),
                        ),
                      ),
                      separateGapBlock,
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: TitleBlockWidget(
                          title: t(LKey.productFormFieldNoteLabel),
                          child: CustomTextField(
                            controller: _noteController,
                            hint: t(LKey.productFormFieldNoteHint),
                          ),
                        ),
                      ),
                      separateGapBlock,
                    ],
                  ),
                ),
              ),
            ),
            BottomButtonBar(
              isListenKeyboardVisibility: true,
              onCancel: () {
                Navigator.pop(context);
              },
              onSave: canCreateProduct ? onSave : null,
              showSaveButton: canCreateProduct,
            ),
          ],
        ),
      ),
    );

    return permissionsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber,
                    size: 40, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  LKey.permissionsLoadFailed.tr(context: context),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(currentUserPermissionsProvider),
                  child: Text(LKey.buttonRetry.tr(context: context)),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (permissions) {
        if (!permissions.contains(PermissionKey.productCreate)) {
          return Scaffold(
            appBar: CustomAppBar(
              title: t(LKey.productFormCreateTitle),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  t(LKey.productFormPermissionDenied),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return form;
      },
    );
  }
}

class EditProductScreen extends HookConsumerWidget with ShowBottomSheet<void> {
  const EditProductScreen({super.key, required this.product});

  final Product product;

  @override
  Future<void> show(BuildContext context, {bool isScafold = true}) {
    return super.show(
      context,
      isScafold: isScafold,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize controllers with existing product data
    final _nameController = useTextEditingController(text: product.name);
    final _noteController =
        useTextEditingController(text: product.description ?? '');
    final _category = useState<Category?>(product.category);
    final _sku = useState<String?>(product.barcode);
    final _unit = useState<Unit?>(product.unit);
    final quantity = useState<int>(product.quantity);
    final images = useState<List<ImageStorageModel>>(product.images ?? []);
    final enableExpiryTracking = useState<bool>(product.enableExpiryTracking);
    const int maxImages = 3;
    final lotDrafts = useState<List<_LotDraft>>(
      product.lots
          .map(
            (lot) => _LotDraft(
              id: lot.id,
              quantity: lot.quantity,
              expiryDate: lot.expiryDate,
              manufactureDate: lot.manufactureDate,
            ),
          )
          .toList(),
    );
    final dateFormat = useMemoized(() => DateFormat('dd/MM/yyyy'));
    String t(String key) => key.tr(context: context);

    int totalLotQuantity() =>
        lotDrafts.value.fold<int>(0, (sum, lot) => sum + lot.quantity);

    void _syncTrackedQuantity() {
      quantity.value = totalLotQuantity();
    }

    void addLot() {
      lotDrafts.value = [
        ...lotDrafts.value,
        const _LotDraft(id: undefinedId, quantity: 0),
      ];
      _syncTrackedQuantity();
    }

    void updateLot(int index, _LotDraft updated) {
      if (index < 0 || index >= lotDrafts.value.length) {
        return;
      }
      final updatedLots = [...lotDrafts.value];
      updatedLots[index] = updated;
      lotDrafts.value = updatedLots;
      _syncTrackedQuantity();
    }

    void updateLotQuantity(int index, int value) {
      updateLot(index, lotDrafts.value[index].copyWith(quantity: value));
    }

    void updateLotExpiry(int index, DateTime date) {
      updateLot(
          index,
          lotDrafts.value[index]
              .copyWith(expiryDate: date, clearExpiryDate: false));
    }

    void updateLotManufacture(int index, DateTime? date) {
      updateLot(
          index,
          lotDrafts.value[index].copyWith(
            manufactureDate: date,
            clearManufactureDate: date == null,
          ));
    }

    void removeLot(int index) {
      if (index < 0 || index >= lotDrafts.value.length) {
        return;
      }
      final updatedLots = [...lotDrafts.value]..removeAt(index);
      lotDrafts.value = updatedLots;
      _syncTrackedQuantity();
    }

    bool isKeyboardVisible = ref.watch(isKeyboardVisibleProvider);

    void onSave() async {
      context.hideKeyboard();

      // Create updated product with same ID
      final name = _nameController.text.trim();
      final note = _noteController.text.trim();
      final sku = _sku.value;

      // Validate inputs
      if (name.isEmpty) {
        showError(
          message: t(LKey.productFormValidationRequired),
        );
        return;
      }

      List<InventoryLot> inventoryLots = const [];
      int finalQuantity = quantity.value;

      if (enableExpiryTracking.value) {
        final validationMessage = _validateLotDrafts(context, lotDrafts.value);
        if (validationMessage != null) {
          showError(message: validationMessage);
          return;
        }

        inventoryLots = lotDrafts.value
            .map(
              (lot) => lot.toInventoryLot(productId: product.id),
            )
            .toList();
        finalQuantity =
            inventoryLots.fold<int>(0, (sum, lot) => sum + lot.quantity);
      }

      final updatedProduct = Product(
        id: product.id,
        name: name,
        description: note,
        images: [...images.value],
        quantity: finalQuantity,
        category: _category.value,
        unit: _unit.value,
        barcode: sku,
        enableExpiryTracking: enableExpiryTracking.value,
        lots: inventoryLots,
      );

      await ref
          .read(loadProductProvider.notifier)
          .updateProduct(updatedProduct, product.quantity);

      // Close the form
      Navigator.pop(context);
    }

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: t(LKey.productFormEditTitle),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          !isKeyboardVisible
              ? const SizedBox()
              : IconButton(
                  icon: Text(
                    t(LKey.buttonSave),
                    style: context.appTheme.textMedium15Default
                        .copyWith(color: Colors.white),
                  ),
                  onPressed: onSave,
                ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TitleBlockWidget(
                              isRequired: true,
                              title: t(LKey.productFormFieldNameLabel),
                              child: CustomTextField.multiLines(
                                hint: t(LKey.productFormFieldNameHint),
                                controller: _nameController,
                                minLines: 3,
                                autofocus: false,
                              ),
                            ),

                            separateGapItem, // Quantity
                            TitleBlockWidget(
                              title: t(LKey.productFormFieldQuantityLabel),
                              isRequired: true,
                              child: enableExpiryTracking.value
                                  ? _LotQuantitySummary(
                                      context,
                                      totalLotQuantity(),
                                    )
                                  : PlusMinusInputView(
                                      initialValue: quantity.value,
                                      onChanged: (int value) {
                                        quantity.value = value;
                                      },
                                      minValue: 0,
                                    ),
                            ),
                            separateGapItem,
                            TitleBlockWidget(
                              title: t(LKey.productFormFieldExpiryLabel),
                              child: _ExpiryTrackingSwitch(
                                value: enableExpiryTracking.value,
                                onChanged: (value) {
                                  enableExpiryTracking.value = value;
                                  if (value) {
                                    if (lotDrafts.value.isEmpty) {
                                      addLot();
                                    } else {
                                      _syncTrackedQuantity();
                                    }
                                  }
                                },
                              ),
                            ),
                            separateGapItem,
                            if (enableExpiryTracking.value) ...[
                              _InventoryLotSection(
                                lots: lotDrafts.value,
                                dateFormat: dateFormat,
                                onAddLot: addLot,
                                onRemoveLot: removeLot,
                                onQuantityChanged: updateLotQuantity,
                                onExpiryChanged: updateLotExpiry,
                                onManufactureChanged: updateLotManufacture,
                              ),
                              separateGapItem,
                            ],
                            TitleBlockWidget(
                              title: t(LKey.productFormFieldSkuLabel),
                              child: AddSKUPlaceHolder(
                                value: _sku.value,
                                onSelected: (String? value) {
                                  _sku.value = value;
                                },
                              ),
                            ),
                            separateGapItem,
                            TitleBlockWidget(
                              title: t(LKey.productFormFieldCategoryLabel),
                              child: AddCategoryPlaceHolder(
                                value: _category.value,
                                onSelected: (Category? value) {
                                  _category.value = value;
                                },
                              ),
                            ),
                            separateGapItem,
                            TitleBlockWidget(
                              title: t(LKey.productFormFieldUnitLabel),
                              child: AddUnitPlaceHolder(
                                value: _unit.value,
                                onSelected: (Unit? value) {
                                  _unit.value = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      separateGapBlock,
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: TitleBlockWidget(
                          title: t(LKey.productFormFieldImagesLabel),
                          child: CommonImagePicker(
                            title: t(LKey.productFormFieldImagesAdd),
                            images: images.value,
                            onImagesSelected: (List<ImageStorageModel> value) {
                              final combined = [...images.value, ...value];
                              if (combined.length > maxImages) {
                                showError(message: 'Tối đa 3 ảnh cho mỗi sản phẩm.');
                                images.value = combined.take(maxImages).toList();
                                return;
                              }
                              images.value = combined;
                            },
                            onImagesChanged: (List<ImageStorageModel> value) {
                              if (value.length > maxImages) {
                                showError(message: 'Tối đa 3 ảnh cho mỗi sản phẩm.');
                                images.value = value.take(maxImages).toList();
                                return;
                              }
                              images.value = value;
                            },
                            onImageRemoved: (ImageStorageModel file) {
                              images.value =
                                  images.value.where((e) => e != file).toList();
                            },
                          ),
                        ),
                      ),
                      separateGapBlock,
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: TitleBlockWidget(
                          title: t(LKey.productFormFieldNoteLabel),
                          child: CustomTextField(
                            hint: t(LKey.productFormFieldNoteHint),
                            controller: _noteController,
                          ),
                        ),
                      ),
                      separateGapBlock,
                    ],
                  ),
                ),
              ),
            ),
            BottomButtonBar(
              isListenKeyboardVisibility: true,
              onCancel: () {
                Navigator.pop(context);
              },
              onSave: onSave,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiryTrackingSwitch extends StatelessWidget {
  const _ExpiryTrackingSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorBackgroundField,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorBorderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LKey.productFormExpiryTrackingLabel.tr(context: context),
                  style: theme.textMedium15Default,
                ),
                const SizedBox(height: 4),
                Text(
                  LKey.productFormExpiryTrackingDescription
                      .tr(context: context),
                  style: theme.textRegular12Subtle,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

Widget _LotQuantitySummary(BuildContext context, int totalQuantity) {
  final appTheme = context.appTheme;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: appTheme.colorBackgroundField,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: appTheme.colorBorderSubtle),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            LKey.productFormInventoryTotalLots.tr(context: context),
            style: appTheme.textRegular14Subtle,
          ),
        ),
        Text(
          '$totalQuantity',
          style: appTheme.headingSemibold24Default,
        ),
      ],
    ),
  );
}

class _InventoryLotSection extends StatelessWidget {
  const _InventoryLotSection({
    required this.lots,
    required this.dateFormat,
    required this.onAddLot,
    required this.onRemoveLot,
    required this.onQuantityChanged,
    required this.onExpiryChanged,
    required this.onManufactureChanged,
  });

  final List<_LotDraft> lots;
  final DateFormat dateFormat;
  final VoidCallback onAddLot;
  final void Function(int index) onRemoveLot;
  final void Function(int index, int quantity) onQuantityChanged;
  final void Function(int index, DateTime date) onExpiryChanged;
  final void Function(int index, DateTime? date) onManufactureChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    Future<void> pickExpiryDate(int index) async {
      final lot = lots[index];
      final initial = lot.expiryDate ?? DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        onExpiryChanged(index, picked);
      }
    }

    Future<void> pickManufactureDate(int index) async {
      final lot = lots[index];
      final initial = lot.manufactureDate ?? DateTime.now();
      final lastDate = lot.expiryDate ?? DateTime(2100);

      final picked = await showDatePicker(
        context: context,
        initialDate: initial.isAfter(lastDate) ? lastDate : initial,
        firstDate: DateTime(2000),
        lastDate: lastDate,
      );

      if (picked != null) {
        onManufactureChanged(index, picked);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lots.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorBackgroundField,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorBorderSubtle),
            ),
            child: Text(
              LKey.productFormInventoryEmpty.tr(context: context),
              style: theme.textRegular14Subtle,
            ),
          ),
        ...lots.asMap().entries.map((entry) {
          final index = entry.key;
          final lot = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index == lots.length - 1 ? 0 : 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorBorderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        LKey.productFormInventoryLotTitle.tr(
                          context: context,
                          namedArgs: {
                            'index': '${index + 1}',
                          },
                        ),
                        style: theme.textMedium15Default,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: LKey.productFormInventoryRemoveLot
                            .tr(context: context),
                        onPressed: () => onRemoveLot(index),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    LKey.productFormInventoryQuantityLabel
                        .tr(context: context),
                    style: theme.textRegular12Subtle,
                  ),
                  const SizedBox(height: 8),
                  PlusMinusInputView(
                    initialValue: lot.quantity,
                    minValue: 0,
                    onChanged: (value) => onQuantityChanged(index, value),
                  ),
                  const SizedBox(height: 16),
                  _DatePickerField(
                    label: LKey.productFormInventoryExpiryLabel
                        .tr(context: context),
                    value: lot.expiryDate,
                    dateFormat: dateFormat,
                    onTap: () => pickExpiryDate(index),
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  _DatePickerField(
                    label: LKey.productFormInventoryManufactureLabel
                        .tr(context: context),
                    value: lot.manufactureDate,
                    dateFormat: dateFormat,
                    onTap: () => pickManufactureDate(index),
                    onClear: lot.manufactureDate != null
                        ? () => onManufactureChanged(index, null)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onAddLot,
          icon: const Icon(Icons.add),
          label: Text(
            LKey.productFormInventoryAddLot.tr(context: context),
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.dateFormat,
    this.onTap,
    this.onClear,
    this.isRequired = false,
    this.readOnly = false,
  });

  final String label;
  final DateTime? value;
  final DateFormat dateFormat;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool isRequired;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final text = value != null
        ? dateFormat.format(value!)
        : LKey.productFormInventoryChooseDate.tr(context: context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: theme.textRegular12Subtle,
              ),
            ),
            if (isRequired)
              Text(
                '*',
                style: theme.textRegular12Subtle
                    .copyWith(color: theme.colorTextSupportRed),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: readOnly ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorBorderSubtle),
              color: theme.colorBackgroundField,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: value != null
                        ? theme.textRegular15Default
                        : theme.textRegular15Subtle,
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: (!readOnly && value != null && onClear != null)
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onClear,
                          splashRadius: 18,
                        )
                      : null,
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color:
                      readOnly ? theme.colorIconDisable : theme.colorIconSubtle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LotDraft {
  const _LotDraft({
    required this.id,
    required this.quantity,
    this.expiryDate,
    this.manufactureDate,
  });

  final int id;
  final int quantity;
  final DateTime? expiryDate;
  final DateTime? manufactureDate;

  _LotDraft copyWith({
    int? id,
    int? quantity,
    DateTime? expiryDate,
    bool clearExpiryDate = false,
    DateTime? manufactureDate,
    bool clearManufactureDate = false,
  }) {
    return _LotDraft(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
      manufactureDate: clearManufactureDate
          ? null
          : (manufactureDate ?? this.manufactureDate),
    );
  }

  InventoryLot toInventoryLot({required int productId}) {
    return InventoryLot(
      id: id,
      productId: productId,
      quantity: quantity,
      expiryDate: expiryDate!,
      manufactureDate: manufactureDate,
      createdAt: null,
      updatedAt: null,
    );
  }
}

String? _validateLotDrafts(BuildContext context, List<_LotDraft> lots) {
  if (lots.isEmpty) {
    return LKey.productFormValidationNoLot.tr(context: context);
  }

  final keys = <String>{};

  for (final lot in lots) {
    if (lot.expiryDate == null) {
      return LKey.productFormValidationMissingExpiry.tr(context: context);
    }

    if (lot.quantity <= 0) {
      return LKey.productFormValidationLotQuantity.tr(context: context);
    }

    if (lot.manufactureDate != null &&
        lot.expiryDate != null &&
        lot.manufactureDate!.isAfter(lot.expiryDate!)) {
      return LKey.productFormValidationManufactureAfterExpiry
          .tr(context: context);
    }

    final key =
        '${lot.expiryDate!.toIso8601String()}|${lot.manufactureDate?.toIso8601String() ?? 'null'}';
    if (!keys.add(key)) {
      return LKey.productFormValidationDuplicateLot
          .tr(context: context);
    }
  }

  return null;
}

class AddSKUWidget extends HookWidget with ShowBottomSheet<void> {
  const AddSKUWidget(this.onSelected, {super.key});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    // Use state hook for reactive SKU updates
    final _skuController = useTextEditingController();
    final theme = context.appTheme;
    //barcode type state
    final barcodeType = useState<BarcodeType>(BarcodeType.QrCode);
    String t(String key) => key.tr(context: context);
    // Get the barcode based on the selected type
    // Function to get the barcode based on the selected type

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColoredBox(
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 18),
                ),
                Expanded(
                  child: TextField(
                    controller: _skuController,
                    textInputAction: TextInputAction.search,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: t(LKey.productFormSkuInputHint),
                      hintStyle:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final sku = _skuController.text.trim();
                    if (sku.isEmpty) {
                      return;
                    }
                    Navigator.of(context).pop();
                    onSelected(sku);
                  },
                  child: Text(
                    t(LKey.buttonSave),
                    style: theme.textMedium15Default
                        .copyWith(color: theme.colorPrimary),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  //add scan barcode button
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await InnerScannerPage(
                          child: Text(
                            t(LKey.productFormSkuScanBarcode),
                          ),
                          onBarcodeScanned: (value) {
                            final scannedValue = value.displayValue ?? '';
                            _skuController.text = scannedValue;
                          },
                        ).show(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorBackgroundField,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              t(LKey.productFormSkuScanAction),
                              style: theme.textMedium15Subtle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ), //add random barcode button
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // Generate a random SKU code
                        final randomSKU =
                            'SKU-${DateTime.now().millisecondsSinceEpoch}';
                        _skuController.text = randomSKU;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorBackgroundField,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shuffle, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              t(LKey.productFormSkuRandom),
                              style: theme.textMedium15Subtle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            AppDivider(),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AnimatedBuilder(
                        animation: _skuController,
                        builder: (context, _) {
                          // Rebuild the QR code when SKU changes
                          if (_skuController.text.isEmpty) {
                            return Container(
                              width: 200,
                              height: 200,
                              alignment: Alignment.center,
                              color: Colors.grey.shade200,
                              child: Text(
                                t(LKey.productFormSkuQrPlaceholder),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return Builder(builder: (context) {
                            try {
                              Barcode dm = Barcode.fromType(barcodeType.value);
                              final svg = dm.toSvg(
                                _skuController.text,
                                width: 200,
                                height: 200,
                              );
                              return SvgPicture.string(
                                svg,
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                                placeholderBuilder: (context) =>
                                    const CircularProgressIndicator(),
                              );
                            } catch (e) {
                              return Text(
                                t(LKey.productFormSkuQrError),
                                style: const TextStyle(color: Colors.red),
                              );
                            }
                          });
                        }),
                  ),
                ),
                Column(
                  children: [
                    DropdownButton<BarcodeType>(
                      value: barcodeType.value,
                      items: BarcodeType.values.map((BarcodeType type) {
                        return DropdownMenuItem<BarcodeType>(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (BarcodeType? type) {
                        if (type != null) {
                          barcodeType.value = type;
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    //download qr code image button
                    ElevatedButton.icon(
                      onPressed: () {
                        final sku = _skuController.text.trim();
                        if (sku.isEmpty) {
                          showError(
                            message:
                                t(LKey.productFormSkuDownloadError),
                          );
                          return;
                        }
                        Barcode dm = Barcode.fromType(barcodeType.value);
                        // Generate SVG (not using it directly here but would be used in a real implementation)
                        dm.toSvg(sku, width: 200, height: 200);
                        // Save the SVG to a file or show a dialog to download
                        // For simplicity, we will just show a success message
                        showSuccess(
                          message: t(LKey.productFormSkuDownloadSuccess),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: Text(t(LKey.productFormSkuDownloadButton)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class SelectImageOptionWidget extends StatelessWidget
    with ShowBottomSheet<List<ImageStorageModel>> {
  const SelectImageOptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    String t(String key) => key.tr(context: context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: CommonImagePicker(
                  title: t(LKey.productFormMediaSelectImageTitle),
                  onImagesSelected: (List<ImageStorageModel> images) {
                    Navigator.pop(context, images);
                  },
                  showOptions: true,
                  layout: ImagePickerLayout.horizontal,
                ),
              ),
            ],
          ),
          const Gap(10),
        ],
      ),
    );
  }
}

class AddSKUPlaceHolder extends CommonAddPlaceHolder<String> {
  AddSKUPlaceHolder({
    super.key,
    String? value,
    ValueChanged<String?>? onSelected,
  }) : super(
          onSelected: onSelected,
          onTap: (context) {
            AddSKUWidget(
              (String value) {
                onSelected?.call(value);
              },
            ).show(context);
          },
          value: value,
          getName: (String? value) => value ?? '',
          titleKey: LKey.productFormSkuPlaceholderTitle,
        );
}

class AddCategoryPlaceHolder extends CommonAddPlaceHolder<Category> {
  AddCategoryPlaceHolder({
    super.key,
    Category? value,
    ValueChanged<Category?>? onSelected,
  }) : super(
          onSelected: onSelected,
          onTap: (context) {
            showCategory(
              context,
              onSelected: (Category value) {
                Navigator.pop(context);
                onSelected?.call(value);
              },
            );
          },
          value: value,
          getName: (Category? value) => value?.name ?? '',
          titleKey: LKey.productFormAddCategory,
        );
}

class CommonAddPlaceHolder<T> extends StatelessWidget {
  const CommonAddPlaceHolder({
    super.key,
    required this.value,
    this.onSelected,
    required this.titleKey,
    required this.getName,
    required this.onTap,
  });

  final String titleKey;
  final T? value;
  final String Function(T? value) getName;
  final ValueChanged<T?>? onSelected;
  final void Function(BuildContext context)? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final displayTitle = titleKey.tr(context: context);
    if (value != null) {
      return CustomTextField(
        key: ObjectKey(value),
        onChanged: (String value) {},
        isReadOnly: true,
        initialValue: getName(value),
        onTap: () => onTap?.call(context),
        suffixIcon: InkWell(
          onTap: () {
            // Clear the selected category
            onSelected?.call(null);
          },
          child: const Icon(
            HugeIcons.strokeRoundedDelete03,
            size: 20,
          ),
        ),
      );
    }
    return InkWell(
      onTap: () => onTap?.call(context),
      child: DottedBorder(
        color: theme.colorBorderField,
        radius: Radius.circular(8),
        dashPattern: const [6, 6],
        strokeCap: StrokeCap.butt,
        child: Container(
          // padding: const EdgeInsets.all(10),
          height: 50,
          decoration: BoxDecoration(),
          child: Row(
            children: [
              const Gap(10),
              Icon(
                HugeIcons.strokeRoundedAddCircle,
                size: 24,
                color: theme.colorIcon,
              ),
              const Gap(10),
              Text(
                displayTitle,
                style: theme.textMedium13Subtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
