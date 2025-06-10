import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared_widgets/index.dart';
import '../../authentication/provider/auth_provider.dart';

class CreateSessionBottomSheet extends ConsumerStatefulWidget with ShowBottomSheet<Map<String, String>> {
  const CreateSessionBottomSheet({
    super.key,
  });

  @override
  ConsumerState<CreateSessionBottomSheet> createState() => _CreateSessionBottomSheetState();
}

class _CreateSessionBottomSheetState extends ConsumerState<CreateSessionBottomSheet> {
  late final TextEditingController nameController;
  late final TextEditingController createdByController;
  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sessionName = 'Phiên kiểm kê ${DateTime.now().toString().substring(0, 16)}';

    final user = ref.read(authControllerProvider);

    final createdBy = user.maybeWhen(
      authenticated: (user, _) => user.role.name,
      orElse: () => 'Người dùng',
    );

    nameController = TextEditingController(text: sessionName);
    createdByController = TextEditingController(text: createdBy);
  }

  @override
  void dispose() {
    nameController.dispose();
    createdByController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the height to make sure the bottom sheet isn't too large
    final viewInsets = MediaQuery.of(context).viewInsets;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: viewInsets.bottom + safeAreaBottom + 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tạo phiên kiểm kê mới',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Tên phiên *',
              hintText: 'VD: Kiểm kê tháng 06/2025',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: createdByController,
            decoration: const InputDecoration(
              labelText: 'Người tạo *',
              hintText: 'VD: Nguyễn Văn A',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú',
              hintText: 'Mô tả ngắn về phiên kiểm kê',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          BottomButtonBar(
            padding: EdgeInsets.zero,
            cancelButtonText: 'Huỷ',
            saveButtonText: 'Tạo phiên',
            onCancel: () => Navigator.pop(context),
            onSave: () {
              if (nameController.text.isNotEmpty && createdByController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'createdBy': createdByController.text,
                  'notes': notesController.text,
                });
              } else {
                // Show validation message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tên phiên và người tạo'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
