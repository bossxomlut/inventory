import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sample_app/shared_widgets/index.dart';

import '../../../domain/entities/index.dart';
import '../../../provider/index.dart';
import '../../../resources/index.dart';
import '../../category/select_category_widget.dart';
import '../provider/product_provider.dart';

// Add product bottom sheet
class AddProductScreen extends HookConsumerWidget with ShowBottomSheet {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _nameController = useTextEditingController();
    final _quantityController = useTextEditingController();
    final _priceController = useTextEditingController();
    final _categoryController = useTextEditingController();
    final _skuController = useTextEditingController();

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
                  Row(
                    children: [
                      // Image placeholder
                      // Container(
                      //   width: 100,
                      //   height: 100,
                      //   color: Colors.grey[300],
                      //   child: const Icon(Icons.image),
                      // ),
                      // const Gap(10),
                      Expanded(
                        child: Column(
                          children: [
                            TitleBlockWidget(
                              title: 'Product Name',
                              isRequired: true,
                              child: CustomTextField.multiLines(
                                // label: 'Product Name',
                                hint: 'Product Name',
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  separateGap,
                  // Quantity
                  TitleBlockWidget(
                    title: 'Quantity',
                    isRequired: true,
                    child: PlusMinusInputView(
                      initialValue: 0,
                      onChanged: (int p0) {
                        // Handle quantity change
                      },
                      minValue: 0,
                    ),
                  ),
                  separateGap,
                  TitleBlockWidget(
                    title: 'Category',
                    child: CustomTextField(
                      hint: 'Add category',
                      onChanged: (String value) {},
                      isReadOnly: true,
                      controller: _categoryController,
                      onTap: () {
                        showCategory(context);
                      },
                      suffixIcon: InkWell(
                        onTap: () {
                          _categoryController.clear();
                        },
                        child: const Icon(Icons.clear),
                      ),
                    ),
                  ),
                  separateGap,
                  TitleBlockWidget(
                    title: 'SKU',
                    child: CustomTextField(
                      hint: 'Product Code',
                      onChanged: (String value) {},
                      isReadOnly: true,
                      controller: _skuController,
                      onTap: () {
                        AddSKUWidget().show(context);
                      },
                      suffixIcon: InkWell(
                        onTap: () {
                          _skuController.clear();
                        },
                        child: const Icon(Icons.clear),
                      ),
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
                      files: [
                        AppFile(name: 'name', path: 'path'),
                      ],
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
            final quantityStr = _quantityController.text.trim();
            final priceStr = _priceController.text.trim();
            final category = _categoryController.text.trim();

            // // Validate inputs
            // if (name.isEmpty || quantityStr.isEmpty || priceStr.isEmpty) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(content: Text('Please fill all required fields')),
            //   );
            //   return;
            // }

            final quantity = int.tryParse(quantityStr) ?? 0;
            final price = double.tryParse(priceStr) ?? 0.0;

            final newProduct = Product(
              id: -1, // Generate unique ID
              name: 'name',
              description: '',
              price: price,
              imageIds: [], // Add image IDs if needed
              quantity: quantity,
              category: Category(id: 1, name: 'name', description: 'does'),
              barcode: '',
            );

            // Add product to the provider
            ref.read(loadProductProvider.notifier).createProduct(newProduct);

            // Close bottom sheet
            Navigator.pop(context);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product added successfully')),
            );
          },
        ),
      ],
    );
  }
}

class AddCategoryPlaceHolder extends StatelessWidget {
  const AddCategoryPlaceHolder({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle category selection
        // showModalBottomSheet(
        //   context: context,
        //   builder: (context) {
        //     return CategorySelectionScreen(categories: categories);
        //   },
        // );
      },
      child: Container(
        // padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(),
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline_rounded)),
            const Gap(10),
            const Text('Add Category'),
          ],
        ),
      ),
    );
  }
}

class AddSKUWidget extends StatelessWidget with ShowBottomSheet {
  const AddSKUWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final _skuController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skuController,
                  decoration: const InputDecoration(
                    labelText: 'Enter SKU Code',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // Handle SKU code input
                  },
                ),
              ),
              const Gap(10),
              IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          // if (_skuController.text.isNotEmpty)
          Column(
            children: [
              Text(
                'Generated Barcode/QR Code:',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              // Replace with actual barcode/QR code widget
              Container(
                height: 100,
                width: 100,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Text('Barcode/QR Code'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SelectImageOptionWidget extends StatelessWidget with ShowBottomSheet<AppFile> {
  const SelectImageOptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                    AppFilePicker.camera().pickMultiFiles();
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
                    AppFilePicker.image().pickMultiFiles();
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
                  onTap: () {
                    // Handle remove selection
                  },
                  theme: theme,
                ),
              ),
              const Gap(10),
            ],
          ),
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
