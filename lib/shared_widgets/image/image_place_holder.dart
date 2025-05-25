import 'dart:convert';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:line_icons/line_icons.dart';

import '../../core/index.dart';
import '../../domain/entities/index.dart';
import '../../features/product/widget/add_product_widget.dart';
import '../../provider/theme.dart';
import '../../resources/theme.dart';
import 'image.dart';

class UploadImagePlaceholder extends StatelessWidget {
  const UploadImagePlaceholder({super.key, required this.title, this.files, this.onChanged, this.onRemove});
  final String title;
  final List<AppFile>? files;
  final ValueChanged<List<AppFile>?>? onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final height = 120.0;
    final theme = context.appTheme;
    if (files.isNotNullAndEmpty) {
      return Row(
        children: [
          _AddHolder(
            theme: theme,
            title: title,
          ),
          const Gap(8),
          Expanded(
            child: SizedBox(
              height: height,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: files?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final AppFile e = files![index];
                  return Container(
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
                    child: Stack(
                      children: [
                        ClipRRect(
                          child: AppImage.file(
                            url: e.path,
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
                },
                separatorBuilder: (BuildContext context, int index) => const Gap(8),
              ),
            ),
          ),
        ],
      );
    }

    return _AddHolder(theme: theme, title: title);
  }
}

class _AddHolder extends StatelessWidget {
  const _AddHolder({
    super.key,
    required this.theme,
    required this.title,
  });

  final AppThemeData theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        SelectImageOptionWidget().show(context);
      },
      child: DottedBorder(
        color: theme.colorBorderField,
        radius: Radius.circular(8),
        dashPattern: const [6, 6],
        strokeCap: StrokeCap.butt,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 120.0,
            minWidth: 120.0,
          ),
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
