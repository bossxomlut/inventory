import 'dart:convert';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:line_icons/line_icons.dart';

import '../../domain/entities/index.dart';
import '../../provider/theme.dart';
import '../file_picker.dart';
import 'image.dart';

class UploadImagePlaceholder extends StatelessWidget {
  const UploadImagePlaceholder({super.key, required this.title, this.filePath, this.onChanged, this.onRemove});
  final String title;
  final String? filePath;
  final ValueChanged<List<AppFile>?>? onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final height = 120.0;
    final theme = context.appTheme;
    if (filePath != null) {
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
              child: AppImage.file(
                url: filePath!,
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

    return InkWell(
      onTap: () async {
        AppFilePicker(
          allowMultiple: true,
        ).opeFilePicker().then((appFiles) {
          onChanged?.call(appFiles);
        });
      },
      child: DottedBorder(
        color: theme.colorBorderField,
        radius: Radius.circular(8),
        dashPattern: const [6, 6],
        strokeCap: StrokeCap.butt,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Gap(16),
              const Icon(
                LineIcons.file,
                color: Color(0xFF8F8F8F),
                size: 30,
              ),
              const Gap(8),
              Text(
                title,
                style: theme.textMedium13Default,
              ),
              const Gap(8),
              Text(
                'Chọn các tệp (PDF, JPG, PNG)',
                style: theme.textMedium13Default,
              ),
              const Gap(16),
            ],
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
