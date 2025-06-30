import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared_widgets/index.dart';
import '../../authentication/provider/auth_provider.dart';

class CreateSessionState {
  final String name;
  final String createdBy;
  final String? note;

  CreateSessionState({
    required this.name,
    required this.createdBy,
    required this.note,
  });
}

class CreateSessionBottomSheet extends HookConsumerWidget with ShowBottomSheet<CreateSessionState> {
  const CreateSessionBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final createdByController = useTextEditingController();
    final noteController = useTextEditingController();

    useEffect(() {
      final sessionName = 'Phiên kiểm kê ${DateTime.now().toString().substring(0, 16)}';

      final user = ref.read(authControllerProvider);

      final userName = user.maybeWhen(
        authenticated: (user, _) => user.role.name,
        orElse: () => 'Người dùng',
      );

      nameController.text = sessionName;

      createdByController.text = userName; // Mặc định người tạo là người đăng nhập
    }, []);

    return Padding(
      padding: const EdgeInsets.all(16.0),
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
            controller: noteController,
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
                Navigator.pop(
                    context,
                    CreateSessionState(
                      name: nameController.text.trim(),
                      createdBy: createdByController.text.trim(),
                      note: noteController.text.isNotEmpty ? noteController.text.trim() : null,
                    ));
              } else {
                // Show validation message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập đầy đủ thông tin bắt buộc'),
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
