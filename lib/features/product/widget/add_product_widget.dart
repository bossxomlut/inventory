import 'package:barcode/barcode.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sample_app/shared_widgets/index.dart';

import '../../../domain/entities/image.dart';
import '../../../domain/entities/index.dart';
import '../../../provider/index.dart';
import '../../../resources/index.dart';
import '../../../shared_widgets/toast.dart';
import '../../category/select_category_widget.dart';
import '../provider/product_provider.dart';
import 'image_manager_picker_page.dart';

// Add product bottom sheet
class AddProductScreen extends HookConsumerWidget with ShowBottomSheet<void> {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _nameController = useTextEditingController();
    final _priceController = useTextEditingController();
    final _noteController = useTextEditingController();
    final _category = useState<Category?>(null);
    final _sku = useState<String?>(null);
    final quantity = useState<int>(0);
    final images = useState<List<ImageStorageModel>>([]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleBlockWidget(
                    title: 'Product Name',
                    isRequired: true,
                    child: CustomTextField.multiLines(
                      controller: _nameController,
                      hint: 'Product Name',
                      maxLines: 3,
                    ),
                  ),
                  separateGap,
                  // Quantity
                  TitleBlockWidget(
                    title: 'Quantity',
                    isRequired: true,
                    child: PlusMinusInputView(
                      initialValue: 0,
                      onChanged: (int p0) {
                        quantity.value = p0;
                      },
                      minValue: 0,
                    ),
                  ),
                  separateGap,
                  TitleBlockWidget(
                    title: 'Category',
                    child: AddCategoryPlaceHolder(
                      value: _category.value,
                      onSelected: (Category? value) {
                        _category.value = value;
                      },
                    ),
                  ),
                  separateGap,
                  TitleBlockWidget(
                    title: 'SKU',
                    child: AddSKUPlaceHolder(
                      value: _sku.value,
                      onSelected: (String? value) {
                        _sku.value = value;
                      },
                    ),
                  ),
                  separateGap,
                  TitleBlockWidget(
                    title: 'Note',
                    child: CustomTextField.multiLines(
                      // label: 'Product Name',
                      hint: 'Note',
                      maxLines: 3,
                    ),
                  ),
                  separateGap,
                  TitleBlockWidget(
                    title: 'Image',
                    child: UploadImagePlaceholder(
                      title: 'Add Image',
                      files: images.value,
                      onAdd: (value) {
                        images.value = [...images.value, ...value];
                      },
                      onRemove: (file) {
                        images.value = images.value.where((e) => e != file).toList();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        BottomButtonBar(
          onCancel: () {
            Navigator.pop(context);
          },
          onSave: () {
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
              barcode: sku,
            );

            // Add product to the provider
            ref.read(loadProductProvider.notifier).createProduct(newProduct);
          },
        ),
      ],
    );
  }
}

class AddSKUWidget extends HookWidget with ShowBottomSheet {
  const AddSKUWidget(this.onSelected, {super.key});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    // Use state hook for reactive SKU updates
    final _skuController = useTextEditingController();
    final theme = context.appTheme;
    final dm = Barcode.qrCode();

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
                    await InnerScannerPage(
                      child: const Text('Scan QR Code'),
                      onBarcodeScanned: (value) {
                        final scannedValue = value.displayValue ?? '';
                        _skuController.text = scannedValue;
                      },
                    ).show(context);
                  },
                  child: const Icon(Icons.camera_alt_outlined),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            Text(
              'Generated Barcode/QR Code:',
              style: theme.headingSemibold20Sublest,
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
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
          ],
        ),
        const SizedBox(height: 20),
        BottomButtonBar(
          onCancel: () {},
          onSave: () {
            final sku = _skuController.text.trim();
            if (sku.isEmpty) {
              return;
            }
            Navigator.of(context).pop();
            onSelected(sku);
          },
        ),
      ],
    );
  }
}

class SelectImageOptionWidget extends StatelessWidget with ShowBottomSheet<List<ImageStorageModel>> {
  const SelectImageOptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Gap(20),
          Row(
            children: [
              const Gap(10),
              Expanded(
                child: _buildOption(
                  context: context,
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    // Handle camera selection
                    AppFilePicker.camera().pickMultiFiles().then((files) {
                      if (files != null && files.isNotEmpty) {
                        Navigator.pop(context,
                            files.map((AppFile e) => ImageStorageModel(id: undefinedId, path: e.path)).toList());
                      } else {
                        showError(message: 'No images selected from camera.');
                      }
                    });
                  },
                  theme: theme,
                ),
              ),
              const Gap(10),
              Expanded(
                child: _buildOption(
                  context: context,
                  icon: Icons.photo,
                  label: 'Photos',
                  onTap: () {
                    AppFilePicker.image().pickMultiFiles().then((files) {
                      if (files != null && files.isNotEmpty) {
                        Navigator.pop(context,
                            files.map((AppFile e) => ImageStorageModel(id: undefinedId, path: e.path)).toList());
                      } else {
                        showError(message: 'No images selected from gallery.');
                      }
                    });
                  },
                  theme: theme,
                ),
              ),
              const Gap(10),
              Expanded(
                child: _buildOption(
                  context: context,
                  icon: Icons.inventory,
                  label: 'Storage',
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute<List<ImageStorageModel>>(
                        builder: (context) => ImageManagerPickerPage(
                          onSelected: (List<ImageStorageModel> selectedImages) {},
                        ),
                      ),
                    ).then(
                      (files) {
                        if (files != null) {
                          Navigator.pop(context, files);
                        }
                      },
                    );
                  },
                  theme: theme,
                ),
              ),
              const Gap(10),
            ],
          ),
          const Gap(10),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorBackgroundField,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: theme.colorIconSubtle,
            ),
            const Gap(10),
            Text(
              label,
              style: theme.textMedium15Subtle,
            ),
          ],
        ),
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
          title: 'Add SKU',
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
          title: 'Add Category',
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
