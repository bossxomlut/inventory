import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/keyboard_visible_provider.dart';

class KeyboardVisibilityBuilder extends ConsumerWidget {
  final Widget child;

  final bool isDisable;

  const KeyboardVisibilityBuilder({
    Key? key,
    required this.child,
    this.isDisable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isDisable) {
      return child;
    }

    final isKeyboardVisible = ref.watch(isKeyboardVisibleProvider);

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: isKeyboardVisible ? const Offset(0, 1) : Offset.zero,
      child: isKeyboardVisible ? const SizedBox() : child,
    );
  }
}
