import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/index.dart';
import '../../../provider/index.dart';
import '../../../resources/index.dart';
import '../../../resources/theme.dart';
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

class CreateSessionBottomSheet extends HookConsumerWidget
    with ShowBottomSheet<CreateSessionState> {
  const CreateSessionBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final createdByController = useTextEditingController();
    final noteController = useTextEditingController();

    final locale = context.locale;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final timestamp = DateTime.now().toString().substring(0, 16);
        final sessionName = LKey.checkSessionCreateDefaultName.tr(
          namedArgs: {'timestamp': timestamp},
        );

        final user = ref.read(authControllerProvider);

        final userName = user.maybeWhen(
          authenticated: (user, _) => user.username,
          orElse: () => LKey.checkSessionCreateDefaultCreator.tr(),
        );

        nameController.text = sessionName;
        createdByController.text =
            userName; // Mặc định người tạo là người đăng nhập
      });
      return null;
    }, [locale]);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LKey.checkSessionCreateTitle.tr(context: context),
                style: const TextStyle(
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
          const SizedBox(height: 10),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: LKey.checkSessionCreateNameLabel.tr(context: context),
              hintText: LKey.checkSessionCreateNameHint.tr(context: context),
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: createdByController,
            decoration: InputDecoration(
              labelText:
                  LKey.checkSessionCreateCreatedByLabel.tr(context: context),
              hintText:
                  LKey.checkSessionCreateCreatedByHint.tr(context: context),
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              labelText: LKey.checkSessionCreateNoteLabel.tr(context: context),
              hintText: LKey.checkSessionCreateNoteHint.tr(context: context),
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          BottomButtonBar(
            padding: EdgeInsets.zero,
            cancelButtonText: LKey.buttonCancel.tr(context: context),
            saveButtonText: LKey.checkSessionCreateSubmit.tr(context: context),
            onCancel: () => Navigator.pop(context),
            onSave: () {
              if (nameController.text.isNotEmpty &&
                  createdByController.text.isNotEmpty) {
                Navigator.pop(
                    context,
                    CreateSessionState(
                      name: nameController.text.trim(),
                      createdBy: createdByController.text.trim(),
                      note: noteController.text.isNotEmpty
                          ? noteController.text.trim()
                          : null,
                    ));
              } else {
                // Show validation message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      LKey.checkSessionCreateValidationRequired.tr(
                        context: context,
                      ),
                    ),
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

class SessionDetailBottomSheet extends StatelessWidget with ShowBottomSheet {
  const SessionDetailBottomSheet({super.key, required this.session});

  final CheckSession session;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header similar to CreateSessionBottomSheet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LKey.checkSessionDetailTitle.tr(context: context),
                style: appTheme.headingSemibold20Default,
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: appTheme.colorTextDefault,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Session name
          _buildInfoRow(
            icon: Icons.label_outline,
            label: LKey.checkSessionDetailName.tr(context: context),
            value: session.name,
            appTheme: appTheme,
          ),
          const SizedBox(height: 10),

          // Created by
          _buildInfoRow(
            icon: Icons.person_outline,
            label: LKey.checkSessionDetailCreatedBy.tr(context: context),
            value: session.createdBy,
            appTheme: appTheme,
          ),
          const SizedBox(height: 10),

          // Created date
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: LKey.checkSessionDetailCreatedAt.tr(context: context),
            value: session.startDate.toString().substring(0, 16),
            appTheme: appTheme,
          ),
          const SizedBox(height: 10),

          // Status
          _buildInfoRow(
            icon: Icons.flag_outlined,
            label: LKey.checkSessionDetailStatus.tr(context: context),
            value: session.status == CheckSessionStatus.inProgress
                ? LKey.checkSessionStatusInProgress.tr(context: context)
                : LKey.checkSessionStatusCompleted.tr(context: context),
            appTheme: appTheme,
            isStatus: true,
            statusColor: session.status == CheckSessionStatus.inProgress
                ? appTheme.colorPrimary
                : appTheme.colorTextSupportGreen,
          ),

          // Note if exists
          if (session.note != null && session.note!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.note_outlined,
              label: LKey.checkSessionDetailNote.tr(context: context),
              value: session.note!,
              appTheme: appTheme,
              isMultiline: true,
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              title: LKey.buttonClose.tr(context: context),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required AppThemeData appTheme,
    bool isMultiline = false,
    bool isStatus = false,
    Color? statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appTheme.colorBackgroundSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appTheme.colorBorderSubtle),
      ),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: appTheme.colorTextSubtle,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: appTheme.textRegular12Default.copyWith(
                    color: appTheme.colorTextSubtle,
                  ),
                ),
                const SizedBox(height: 4),
                if (isStatus && statusColor != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      value,
                      style: appTheme.textRegular12Default.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: appTheme.textRegular14Default.copyWith(
                      color: appTheme.colorTextDefault,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
