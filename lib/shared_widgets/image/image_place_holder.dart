import 'dart:convert';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sample_app/shared_widgets/camera/camera_view.dart';

import '../../domain/entities/get_id.dart';
import '../../domain/entities/image.dart';
import '../../features/product/widget/add_product_widget.dart';
import '../../features/product/widget/image_manager_picker_page.dart';
import '../../provider/theme.dart';
import '../../resources/theme.dart';
import '../file_picker.dart';
import 'image.dart';

class UploadImagePlaceholder extends StatelessWidget {
  const UploadImagePlaceholder({
    super.key,
    required this.title,
    required this.onAdd,
    this.files,
    this.onRemove,
  });
  final String title;
  final List<ImageStorageModel>? files;
  final ValueChanged<List<ImageStorageModel>> onAdd;
  final ValueChanged<ImageStorageModel>? onRemove;

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      child: DottedBorder(
        color: theme.colorBorderField,
        radius: Radius.circular(16),
        dashPattern: const [6, 6],
        strokeCap: StrokeCap.butt,
        child: ClipRRect(
          child: Container(
            // padding: const EdgeInsets.all(20),
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: theme.colorIconSubtle,
                ),
                const Gap(10),
                Text(
                  label,
                  style: theme.textMedium13Subtle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = 120.0;
    final theme = context.appTheme;
    if (files != null && files!.isNotEmpty) {
      return Row(
        children: [
          _AddHolder(
            theme: theme,
            title: title,
            onChanged: onAdd,
          ),
          const Gap(8),
          Expanded(
            child: SizedBox(
              height: height,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: files!.length,
                itemBuilder: (BuildContext context, int index) {
                  final e = files![index];
                  return Stack(
                    children: [
                      Container(
                        height: height,
                        width: height,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorBorderField,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: ClipRRect(
                          child: AppImage.file(
                            url: e.path ?? '',
                            fit: BoxFit.cover,
                            height: height,
                          ),
                        ),
                      ),
                      if (onRemove != null)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: InkWell(
                            onTap: () {
                              onRemove?.call(e);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Color(0x66000000),
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Color(0xFFEBEBEB),
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Gap(8),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildOption(
            context: context,
            icon: HugeIcons.strokeRoundedCamera02,
            label: 'Máy ảnh',
            onTap: () {
              CameraView.show(context).then((files) {
                if (files != null && files.isNotEmpty) {
                  final images = files.map((file) => ImageStorageModel(id: undefinedId, path: file.path)).toList();
                  onAdd.call(images);
                }
              });
            },
            theme: theme,
          ),
        ),
        const Gap(10),
        Expanded(
          child: _buildOption(
            context: context,
            icon: HugeIcons.strokeRoundedImage03,
            label: 'Thư viện',
            onTap: () {
              AppFilePicker.image().pickMultiFiles().then((files) {
                if (files != null && files.isNotEmpty) {}
              });
            },
            theme: theme,
          ),
        ),
        const Gap(10),
        Expanded(
          child: _buildOption(
            context: context,
            icon: HugeIcons.strokeRoundedGooglePhotos,
            label: 'Sản phẩm',
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute<List<ImageStorageModel>>(
                  builder: (context) => ImageManagerPickerPage(
                    onSelected: (List<ImageStorageModel> selectedImages) {},
                  ),
                ),
              ).then(
                (files) {
                  if (files != null) {
                    Navigator.pop(context, files);
                  }
                },
              );
            },
            theme: theme,
          ),
        ),
        const Gap(10),
      ],
    );
  }
}

class _AddHolder extends StatelessWidget {
  const _AddHolder({
    super.key,
    required this.theme,
    required this.title,
    required this.onChanged,
    this.isExpand = false,
    this.height = 120.0,
  });

  final AppThemeData theme;
  final String title;
  final bool isExpand;
  final double height;
  final ValueChanged<List<ImageStorageModel>> onChanged;

  @override
  Widget build(BuildContext context) {
    // Use a minimal version of the CommonImagePicker
    return SizedBox(
      width: height,
      height: height,
      child: InkWell(
        onTap: () async {
          SelectImageOptionWidget().show(context).then((value) {
            if (value != null) {
              onChanged.call(value);
            }
          });
        },
        child: DottedBorder(
          color: theme.colorBorderField,
          radius: Radius.circular(8),
          dashPattern: const [6, 6],
          strokeCap: StrokeCap.butt,
          child: Container(
            constraints: BoxConstraints(
              minHeight: height,
              minWidth: height,
            ),
            alignment: isExpand ? Alignment.center : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(16),
                const Icon(
                  LineIcons.image,
                  color: Color(0xFF8F8F8F),
                  size: 30,
                ),
                const Gap(8),
                Text(
                  title,
                  style: theme.textMedium13Default,
                ),
                const Gap(16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Base64ImagePlaceholder extends StatelessWidget {
  const Base64ImagePlaceholder({super.key, required this.data, this.onRemove});
  final String data;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = base64Decode(data);

    final height = 120.0;
    final theme = context.appTheme;
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorBorderField,
          width: 1,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              height: height,
            ),
          ),
          if (onRemove != null)
            Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                onTap: () {
                  onRemove?.call();
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0x66000000),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4)),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Color(0xFFEBEBEB),
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
