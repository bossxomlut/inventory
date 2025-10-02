import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider/index.dart';
import '../../resources/index.dart';
import '../../shared_widgets/index.dart';
import '../../shared_widgets/toast.dart';

@RoutePage()
class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _contactController = TextEditingController();
  final _typeController = TextEditingController();
  final _feedbackTypes = const [
    'Báo lỗi',
    'Đề xuất tính năng',
    'Khác',
  ];
  String _selectedType = 'Báo lỗi';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _typeController.text = _selectedType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contactController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gửi phản hồi',
      ),
      body: GestureDetector(
        onTap: () => context.hideKeyboard(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            Text(
              'Chúng tôi luôn lắng nghe ý kiến của bạn. Vui lòng điền thông tin dưới đây để phản hồi lỗi hoặc đề xuất tính năng mới.',
              style: theme.textRegular14Subtle,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleBlockWidget(
                    title: 'Loại phản hồi',
                    isRequired: true,
                    child: CustomTextField(
                      controller: _typeController,
                      hint: 'Chọn loại phản hồi',
                      isReadOnly: true,
                      onTap: _showTypePicker,
                      suffixIcon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                  separateGapItem,
                  TitleBlockWidget(
                    title: 'Tiêu đề',
                    child: CustomTextField(
                      controller: _titleController,
                      hint: 'Ví dụ: Lỗi không thể đăng nhập',
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  separateGapItem,
                  TitleBlockWidget(
                    title: 'Thông tin liên hệ (tuỳ chọn)',
                    child: CustomTextField(
                      controller: _contactController,
                      hint: 'Email hoặc số điện thoại',
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
            ),
            separateGapBlock,
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TitleBlockWidget(
                title: 'Nội dung chi tiết',
                isRequired: true,
                child: CustomTextField.multiLines(
                  controller: _contentController,
                  hint: 'Mô tả chi tiết về lỗi hoặc đề xuất của bạn',
                  minLines: 5,
                  maxLines: 10,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomButtonBar(
        onCancel: () => Navigator.pop(context),
        onSave: _isSending ? null : _onSubmit,
        saveButtonText: _isSending ? 'Đang gửi...' : 'Gửi phản hồi',
        showCancelButton: true,
        isListenKeyboardVisibility: true,
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_isSending) {
      return;
    }
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      showError(context: context, message: 'Vui lòng nhập nội dung phản hồi.');
      return;
    }

    context.hideKeyboard();

    setState(() {
      _isSending = true;
    });

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      final formattedDate =
          DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      final title = _titleController.text.trim();
      final contact = _contactController.text.trim();

      final subjectSuffix = title.isNotEmpty ? ' - $title' : '';
      final subject = '[Đơn và kho hàng] Phản hồi ứng dụng';

      final bodyBuffer = StringBuffer()
        ..writeln('Ngày gửi: $formattedDate')
        ..writeln('Phiên bản: $version')
        ..writeln('Loại phản hồi: $_selectedType')
        ..writeln('Tiêu đề: ${title.isNotEmpty ? title : '---'}')
        ..writeln('Thông tin liên hệ: ${contact.isNotEmpty ? contact : '---'}')
        ..writeln()
        ..writeln('Nội dung:')
        ..writeln(content);

      final encodedSubject = Uri.encodeComponent('$subject - v$version');
      final encodedBody = Uri.encodeComponent(bodyBuffer.toString());
      final feedbackUri = Uri.parse(
        'mailto:bossxomlut@gmail.com?subject=$encodedSubject&body=$encodedBody',
      );

      final launched = await launchUrl(
        feedbackUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        showError(
          context: context,
          message: 'Không thể mở ứng dụng email trên thiết bị này.',
        );
      } else {
        showSuccess(
          context: context,
          message: 'Đang mở ứng dụng email để gửi phản hồi.',
        );
      }
    } catch (_) {
      showError(
        context: context,
        message: 'Có lỗi xảy ra khi chuẩn bị email phản hồi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _showTypePicker() async {
    final result = await _FeedbackTypeSheet(
      options: _feedbackTypes,
      selected: _selectedType,
    ).show(context);

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _selectedType = result;
      _typeController.text = result;
    });
  }
}

class _FeedbackTypeSheet extends StatelessWidget with ShowBottomSheet<String> {
  const _FeedbackTypeSheet({
    required this.options,
    required this.selected,
  });

  final List<String> options;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Chọn loại phản hồi',
                style: theme.headingSemibold20Default,
              ),
            ),
            const Divider(height: 0),
            ...options.map(
              (type) => ListTile(
                title: Text(type),
                trailing: type == selected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(type),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
