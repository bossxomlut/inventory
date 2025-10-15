import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/index.dart';
import '../../provider/permissions.dart';
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
        final permissionsAsync = ref.watch(currentUserPermissionsProvider);

        return permissionsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber, size: 32, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  LKey.permissionsLoadFailedWithError.tr(
                    context: context,
                    namedArgs: {'error': '$error'},
                  ),
                ),
              ],
            ),
          ),
          data: (permissions) {
            final canCreate = permissions.contains(PermissionKey.categoryCreate);
            final canUpdate = permissions.contains(PermissionKey.categoryUpdate);
            final canSave = isEditMode ? canUpdate : canCreate;

            return HookBuilder(builder: (context) {
              final nameController = useTextEditingController();
              final descriptionController = useTextEditingController();

              useEffect(() {
                if (isEditMode) {
                  nameController.text = widget.category!.name;
                  descriptionController.text = widget.category!.description ?? '';
                }
                return null;
              }, []);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TitleBlockWidget(
                          title: LKey.categoryFormNameLabel.tr(context: context),
                          isRequired: true,
                          child: CustomTextField.multiLines(
                            controller: nameController,
                            hint: LKey.categoryFormNameHint.tr(context: context),
                            maxLines: 3,
                          ),
                        ),
                        separateGapItem,
                        TitleBlockWidget(
                          title:
                              LKey.categoryFormDescriptionLabel.tr(context: context),
                          child: CustomTextField.multiLines(
                            controller: descriptionController,
                            hint: LKey.categoryFormDescriptionHint.tr(context: context),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BottomButtonBar(
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    onSave: canSave
                        ? () async {
                            final name = nameController.text.trim();
                            final description = descriptionController.text.trim();

                            if (name.isEmpty) {
                              showError(
                                message: LKey.categoryFormNameRequired
                                    .tr(context: context),
                              );
                              return;
                            }

                            if (isEditMode) {
                              try {
                                final category =
                                    widget.category!.copyWith(name: name, description: description);
                                await ref.read(loadCategoryProvider.notifier).updateCategory(category);
                                Navigator.pop(context);
                              } catch (error) {
                                showError(
                                  message: LKey.categoryFormUpdateError.tr(
                                    context: context,
                                    namedArgs: {'error': '$error'},
                                  ),
                                );
                              }
                            } else {
                              final category =
                                  Category(id: undefinedId, name: name, description: description);

                              final cate =
                                  await ref.read(loadCategoryProvider.notifier).addCategory(category);
                              Navigator.pop(context, cate);
                            }
                          }
                        : null,
                    showSaveButton: canSave,
                  ),
                ],
              );
            });
          },
        );
      },
    );
  }
}
