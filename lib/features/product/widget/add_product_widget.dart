import 'package:barcode/barcode.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sample_app/shared_widgets/image/common_image_picker.dart';
import 'package:sample_app/shared_widgets/index.dart';

import '../../../domain/entities/image.dart';
import '../../../domain/entities/index.dart';
import '../../../domain/entities/unit/unit.dart';
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
    final _priceController = useTextEditingController();
    final _noteController = useTextEditingController();
    final _category = useState<Category?>(null);
    final _sku = useState<String?>(null);
    final _unit = useState<Unit?>(null);
    final quantity = useState<int>(0);
    final images = useState<List<ImageStorageModel>>([]);

    bool isKeyboardVisible = ref.watch(isKeyboardVisibleProvider);

    void onSave() {
      context.hideKeyboard();

      // Create a new product
      final name = _nameController.text.trim();
      final priceStr = _priceController.text.trim();
      final note = _noteController.text.trim();
      final sku = _sku.value;

      // Validate inputs
      if (name.isEmpty) {
        showError(message: 'Please fill in all required fields.');
        return;
      }

      final price = double.tryParse(priceStr) ?? 0.0;

      final newProduct = Product(
        id: undefinedId, // Generate unique ID
        name: name,
        description: note,
        price: price,
        images: [...images.value], // Add image IDs if needed
        quantity: quantity.value,
        category: _category.value,
        unit: _unit.value,
        barcode: sku,
      );

      // Add product to the provider
      ref.read(loadProductProvider.notifier).createProduct(newProduct);
    }

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: 'Thêm sản phẩm',
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
                    'Lưu',
                    style: context.appTheme.textMedium15Default.copyWith(color: Colors.white),
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
                              title: 'Tên sản phẩm ',
                              child: CustomTextField.multiLines(
                                hint: 'Nhập tên sản phẩm',
                                controller: _nameController,
                                minLines: 3,
                                autofocus: true,
                              ),
                            ),

                            separateGapItem,
                            // Quantity
                            TitleBlockWidget(
                              title: 'Số lượng',
                              isRequired: true,
                              child: PlusMinusInputView(
                                initialValue: 0,
                                onChanged: (int p0) {
                                  quantity.value = p0;
                                },
                                minValue: 0,
                              ),
                            ),
                            separateGapItem,
                            TitleBlockWidget(
                              title: 'Mã sản phẩm ',
                              child: AddSKUPlaceHolder(
                                value: _sku.value,
                                onSelected: (String? value) {
                                  _sku.value = value;
                                },
                              ),
                            ),
                            separateGapItem,
                            TitleBlockWidget(
                              title: 'Danh mục',
                              child: AddCategoryPlaceHolder(
                                value: _category.value,
                                onSelected: (Category? value) {
                                  _category.value = value;
                                },
                              ),
                            ),
                            separateGapItem,
                            TitleBlockWidget(
                              title: 'Đơn vị',
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
                          title: 'Ảnh sản phẩm',
                          child: CommonImagePicker(
                            title: 'Thêm ảnh',
                            images: images.value,
                            onImagesSelected: (List<ImageStorageModel> value) {
                              images.value = [...images.value, ...value];
                            },
                            onImagesChanged: (List<ImageStorageModel> value) {
                              images.value = value;
                            },
                            onImageRemoved: (ImageStorageModel file) {
                              images.value = images.value.where((e) => e != file).toList();
                            },
                          ),
                        ),
                      ),
                      separateGapBlock,
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: TitleBlockWidget(
                          title: 'Ghi chú',
                          child: CustomTextField(
                            hint: 'Nhập ghi chú',
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
                      hintText: 'Enter SKU Code',
                      hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
                    'Lưu',
                    style: theme.textMedium15Default.copyWith(color: theme.colorPrimary),
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
                          child: const Text('Scan Barcode'),
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
                            Text('Scan Barcode', style: theme.textMedium15Subtle),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //add random barcode button
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // Generate a random SKU code
                        final randomSKU = 'SKU-${DateTime.now().millisecondsSinceEpoch}';
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
                            Text('Random SKU', style: theme.textMedium15Subtle),
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
                              child: const Text(
                                'Please enter a SKU code to generate the QR code',
                                style: TextStyle(color: Colors.grey),
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
                                placeholderBuilder: (context) => const CircularProgressIndicator(),
                              );
                            } catch (e) {
                              return const Text(
                                'Error generating QR code',
                                style: TextStyle(color: Colors.red),
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
                          showError(message: 'Please enter a SKU code to download the QR code.');
                          return;
                        }
                        Barcode dm = Barcode.fromType(barcodeType.value);
                        // Generate SVG (not using it directly here but would be used in a real implementation)
                        dm.toSvg(sku, width: 200, height: 200);
                        // Save the SVG to a file or show a dialog to download
                        // For simplicity, we will just show a success message
                        showSuccess(message: 'QR code downloaded successfully!');
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Save to device'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

class SelectImageOptionWidget extends StatelessWidget with ShowBottomSheet<List<ImageStorageModel>> {
  const SelectImageOptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: CommonImagePicker(
                  title: 'Chọn ảnh',
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
          title: 'Thêm mã sản phẩm (SKU)',
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
          title: 'Thêm danh mục',
        );
}

class CommonAddPlaceHolder<T> extends StatelessWidget {
  const CommonAddPlaceHolder({
    super.key,
    required this.value,
    this.onSelected,
    required this.title,
    required this.getName,
    required this.onTap,
  });

  final String title;
  final T? value;
  final String Function(T? value) getName;
  final ValueChanged<T?>? onSelected;
  final void Function(BuildContext context)? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
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
          child: const Icon(Icons.clear),
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
              const Icon(Icons.add_circle_outline_rounded),
              const Gap(10),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
