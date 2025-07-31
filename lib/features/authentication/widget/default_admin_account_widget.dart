import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/init_provider.dart';
import '../../../resources/index.dart';
import '../../../shared_widgets/dialog.dart';

class DefaultAdminAccountWidget extends ConsumerWidget with ShowDialog {
  const DefaultAdminAccountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Thông tin đăng nhập'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chào mừng bạn đến với ứng dụng quản lý kho!'),
          SizedBox(height: 16),
          Text('Tài khoản admin mặc định:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tên đăng nhập: admin', style: TextStyle(fontFamily: 'monospace')),
                Text('Mật khẩu: admin', style: TextStyle(fontFamily: 'monospace')),
                Text('Câu hỏi bảo mật: ${LKey.whatIsYourFavoriteColor.tr(context: context)}',
                    style: TextStyle(fontFamily: 'monospace')),
                Text('Câu trả lời bảo mật: red', style: TextStyle(fontFamily: 'monospace')),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text('Vui lòng đổi mật khẩu và cập nhật câu hỏi bảo mật sau khi đăng nhập lần đầu.',
              style: TextStyle(color: Colors.orange[700], fontSize: 13)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            ref.read(hasShownAdminDialogServiceProvider).setDialogShown();
            Navigator.of(context).pop();
          },
          child: Text('Đã hiểu'),
        ),
      ],
    );
  }
}
