import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final VoidCallback? onBack;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.titleWidget,
    this.actions,
    this.showBackButton = true,
    this.bottom,
    this.leading,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: titleWidget ?? Text(title),
      leading: leading ?? AppBackButton(onBack: onBack),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) {
      return const SizedBox();
    }

    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
      ),
      onPressed: onBack ??
          () {
            Navigator.of(context).pop();
          },
    );
  }
}
