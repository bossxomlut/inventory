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
  static const List<_FeedbackTypeOption> _feedbackTypes = <_FeedbackTypeOption>[
    _FeedbackTypeOption(LKey.feedbackTypeBug),
    _FeedbackTypeOption(LKey.feedbackTypeFeature),
    _FeedbackTypeOption(LKey.feedbackTypeOther),
  ];
  String _selectedTypeKey = LKey.feedbackTypeBug;
  bool _isSending = false;

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
    final _FeedbackTypeOption selectedOption =
        _feedbackTypes.firstWhere((option) => option.key == _selectedTypeKey);
    final String selectedLabel = selectedOption.label(context);
    if (_typeController.text != selectedLabel) {
      _typeController.text = selectedLabel;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: LKey.feedbackTitle.tr(context: context),
      ),
      body: GestureDetector(
        onTap: () => context.hideKeyboard(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            Text(
              LKey.feedbackDescription.tr(context: context),
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
                    title: LKey.feedbackTypeLabel.tr(context: context),
                    isRequired: true,
                    child: CustomTextField(
                      controller: _typeController,
                      hint: LKey.feedbackTypeHint.tr(context: context),
                      isReadOnly: true,
                      onTap: _showTypePicker,
                      suffixIcon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                  separateGapItem,
                  TitleBlockWidget(
                    title: LKey.feedbackTitleLabel.tr(context: context),
                    child: CustomTextField(
                      controller: _titleController,
                      hint: LKey.feedbackTitleHint.tr(context: context),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  separateGapItem,
                  TitleBlockWidget(
                    title: LKey.feedbackContactLabel.tr(context: context),
                    child: CustomTextField(
                      controller: _contactController,
                      hint: LKey.feedbackContactHint.tr(context: context),
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
                title: LKey.feedbackContentLabel.tr(context: context),
                isRequired: true,
                child: CustomTextField.multiLines(
                  controller: _contentController,
                  hint: LKey.feedbackContentHint.tr(context: context),
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
        saveButtonText: _isSending
            ? LKey.feedbackSubmitting.tr(context: context)
            : LKey.feedbackSubmit.tr(context: context),
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
      showError(
        context: context,
        message: LKey.feedbackErrorEmptyContent.tr(context: context),
      );
      return;
    }

    context.hideKeyboard();

    setState(() {
      _isSending = true;
    });

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final String version = packageInfo.version;
      final String formattedDate =
          DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      if (!mounted) {
        return;
      }
      final String title = _titleController.text.trim();
      final String contact = _contactController.text.trim();
      final String typeLabel = _feedbackTypes
          .firstWhere((o) => o.key == _selectedTypeKey)
          .label(context);

      final String subjectSuffix = title.isNotEmpty ? ' - $title' : '';
      final String subject = LKey.feedbackMailSubject.tr(context: context);

      final StringBuffer bodyBuffer = StringBuffer()
        ..writeln(
            '${LKey.feedbackMailSendDate.tr(context: context)}: $formattedDate')
        ..writeln('${LKey.feedbackMailVersion.tr(context: context)}: $version')
        ..writeln('${LKey.feedbackMailType.tr(context: context)}: $typeLabel')
        ..writeln(
            '${LKey.feedbackMailTitle.tr(context: context)}: ${title.isNotEmpty ? title : '---'}')
        ..writeln(
            '${LKey.feedbackMailContact.tr(context: context)}: ${contact.isNotEmpty ? contact : '---'}')
        ..writeln()
        ..writeln('${LKey.feedbackMailContent.tr(context: context)}:')
        ..writeln(content);

      final String subjectWithTitle = subject + subjectSuffix;
      final String encodedSubject =
          Uri.encodeComponent('$subjectWithTitle - v$version');
      final String encodedBody = Uri.encodeComponent(bodyBuffer.toString());
      final Uri feedbackUri = Uri.parse(
        'mailto:bossxomlut@gmail.com?subject=$encodedSubject&body=$encodedBody',
      );

      final bool launched = await launchUrl(
        feedbackUri,
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) {
        return;
      }

      if (!launched) {
        showError(
          context: context,
          message: LKey.feedbackEmailOpenError.tr(context: context),
        );
      } else {
        showSuccess(
          context: context,
          message: LKey.feedbackEmailOpenSuccess.tr(context: context),
        );
      }
    } catch (_) {
      showError(
        context: context,
        message: LKey.feedbackPrepareError.tr(context: context),
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
    final String? result = await _FeedbackTypeSheet(
      options: _feedbackTypes,
      selectedKey: _selectedTypeKey,
    ).show(context);

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _selectedTypeKey = result;
    });
  }
}

class _FeedbackTypeSheet extends StatelessWidget with ShowBottomSheet<String> {
  const _FeedbackTypeSheet({
    required this.options,
    required this.selectedKey,
  });

  final List<_FeedbackTypeOption> options;
  final String selectedKey;

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
                LKey.feedbackTypePickerTitle.tr(context: context),
                style: theme.headingSemibold20Default,
              ),
            ),
            const Divider(height: 0),
            ...options.map(
              (option) => ListTile(
                title: Text(option.label(context)),
                trailing:
                    option.key == selectedKey ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(option.key),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _FeedbackTypeOption {
  const _FeedbackTypeOption(this.key);

  final String key;

  String label(BuildContext context) => key.tr(context: context);
}
