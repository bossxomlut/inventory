import 'package:flutter/material.dart';

import '../provider/theme.dart';

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
    final theme = context.appTheme;
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: titleWidget ??
          Text(
            title,
            style: theme.textMedium16Default.copyWith(
              color: theme.colorTextWhite,
            ),
          ),
      leading: leading ?? AppBackButton(onBack: onBack),
      actions: actions,
      bottom: bottom,
      backgroundColor: theme.colorPrimary,
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

    final theme = context.appTheme;

    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new,
        color: theme.colorTextWhite,
      ),
      onPressed: onBack ??
          () {
            Navigator.of(context).pop();
          },
    );
  }
}

class SliverMultilineAppBar extends StatelessWidget {
  final String title;

  SliverMultilineAppBar({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    double availableWidth = mediaQuery.size.width - 160;

    final theme = Theme.of(context);

    return SliverAppBar(
      forceElevated: true,
      pinned: true,
      expandedHeight: 64,
      backgroundColor: theme.scaffoldBackgroundColor,
      foregroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: availableWidth,
          ),
          child: Text(
            title,
            textScaleFactor: .68,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.start,
          ),
        ),
      ),
    );
  }
}
