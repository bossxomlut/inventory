import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:line_icons/line_icons.dart';

import '../../resource/index.dart';

class OutlineField extends StatelessWidget {
  const OutlineField({
    super.key,
    required this.label,
    this.value,
    required this.onTap,
    this.showTrailingIcon = true,
    this.trailing,
    this.isDisabled = false,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool showTrailingIcon;
  final Widget? trailing;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        // splashColor: const Color(0x0DFFFFFF),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.borderColor),
            borderRadius: BorderRadius.circular(4.0),
            color: isDisabled ? theme.borderColor : theme.canvasColor,
          ),
          child: Builder(
            builder: (BuildContext context) {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // AnimatedSwitcher để label thay đổi với animation
                        Text(
                          label,
                          key: ValueKey<String>(label), // Key để kiểm soát animation khi label thay đổi
                          style: value == null
                              ? theme.textTheme.bodyMedium
                              : theme.textTheme.labelSmall, // Style cho label
                        ),
                        // Hiển thị value nếu không null với hiệu ứng Fade
                        if (value != null)
                          Text(
                            value!,
                            key: ValueKey<String>(value!), // Key để kiểm soát animation khi value thay đổi
                            style: theme.textTheme.bodyLarge, // Style cho value
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const Gap(8),
                  if (showTrailingIcon)
                    trailing ??
                        Icon(
                          LineIcons.angleDown,
                          color: theme.colorScheme.onSurface,
                          size: 18,
                          // color: theme.colorTextSublest,
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class OutlineLayout extends StatelessWidget {
  const OutlineLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // final theme = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        // border: Border.all(color: theme.colorBorderField),
        borderRadius: BorderRadius.circular(4.0),
        // color: theme.colorBackgroundField,
      ),
      child: child,
    );
  }
}
