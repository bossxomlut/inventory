import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/product/inventory.dart';
import '../../domain/index.dart';
import '../../provider/permissions.dart';
import '../../resources/index.dart';
import '../../shared_widgets/index.dart';
import '../../shared_widgets/toast.dart';
import 'provider/unit_provider.dart';

class AddUnit extends StatefulWidget with ShowBottomSheet<Unit> {
  const AddUnit({super.key, this.unit});

  final Unit? unit;

  @override
  State<AddUnit> createState() => _AddUnitState();
}

class _AddUnitState extends State<AddUnit> {
  bool get isEditMode => widget.unit != null;

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
                const Icon(Icons.warning_amber,
                    size: 32, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text('Không thể tải quyền thao tác: $error'),
              ],
            ),
          ),
          data: (permissions) {
            final canCreate = permissions.contains(PermissionKey.unitCreate);
            final canUpdate = permissions.contains(PermissionKey.unitUpdate);
            final canSave = isEditMode ? canUpdate : canCreate;

            return HookBuilder(
              builder: (context) {
                final nameController = useTextEditingController();
                final descriptionController = useTextEditingController();

                useEffect(() {
                  if (isEditMode) {
                    nameController.text = widget.unit!.name;
                    descriptionController.text = widget.unit!.description ?? '';
                  }
                  return null;
                }, []);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TitleBlockWidget(
                            title: 'Tên',
                            isRequired: true,
                            child: CustomTextField.multiLines(
                              controller: nameController,
                              hint: 'Tên đơn vị',
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
                              final description =
                                  descriptionController.text.trim();

                              if (name.isEmpty) {
                                showError(message: 'Vui lòng nhập tên đơn vị.');
                                return;
                              }

                              if (isEditMode) {
                                try {
                                  final unit = widget.unit!.copyWith(
                                      name: name, description: description);
                                  await ref
                                      .read(loadUnitProvider.notifier)
                                      .updateUnit(unit);
                                  Navigator.pop(context);
                                } catch (error) {
                                  showError(
                                      message:
                                          'Không thể cập nhật đơn vị: $error');
                                }
                              } else {
                                final unit = Unit(
                                    id: undefinedId,
                                    name: name,
                                    description: description);

                                final createdUnit = await ref
                                    .read(loadUnitProvider.notifier)
                                    .createUnit(unit);
                                Navigator.pop(context, createdUnit);
                              }
                            }
                          : null,
                      showSaveButton: canSave,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
