import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/index.dart';
import '../../resources/index.dart';
import '../../shared_widgets/index.dart';
import '../../shared_widgets/toast.dart';
import 'provider/category_provider.dart';

//add category form
class AddCategory extends StatefulWidget with ShowBottomSheet<Category> {
  const AddCategory({super.key, this.category});

  final Category? category;

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  bool get isEditMode => widget.category != null;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return HookBuilder(builder: (context) {
          // Use hooks to manage state if needed
          final nameController = useTextEditingController();
          final descriptionController = useTextEditingController();

          useEffect(() {
            if (isEditMode) {
              nameController.text = widget.category!.name;
              descriptionController.text = widget.category!.description ?? '';
            }
          }, []);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TitleBlockWidget(
                      title: 'Tên',
                      isRequired: true,
                      child: CustomTextField.multiLines(
                        controller: nameController,
                        hint: 'Tên danh mục',
                        maxLines: 3,
                      ),
                    ),
                    separateGapItem,
                    TitleBlockWidget(
                      title: 'Ghi chú',
                      child: CustomTextField.multiLines(
                        controller: descriptionController,
                        hint: 'Ghi chú',
                        maxLines: 3,
                      ),
                    ),
                    // Save button
                  ],
                ),
              ),
              BottomButtonBar(
                onCancel: () {
                  Navigator.pop(context);
                },
                onSave: () async {
                  final name = nameController.text.trim();
                  final description = descriptionController.text.trim();

                  if (name.isEmpty) {
                    showError(message: 'Vui lòng nhập tên danh mục.');
                    return;
                  }

                  // Call the repository to add the category
                  if (isEditMode) {
                    try {
                      final category = widget.category!.copyWith(name: name, description: description);
                      await ref.read(loadCategoryProvider.notifier).updateCategory(category);
                      Navigator.pop(context);
                    } catch (error) {
                      showError(message: 'Không thể cập nhật danh mục: $error');
                    }
                  } else {
                    final category = Category(id: undefinedId, name: name, description: description);

                    final cate = await ref.read(loadCategoryProvider.notifier).addCategory(category);
                    Navigator.pop(context, cate);
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }
}
