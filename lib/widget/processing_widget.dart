import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../resource/index.dart';
import 'index.dart';

// enum ProcessingType {
//   processing,
//   error,
//   success,
// }

class ProcessingWidget extends StatefulWidget with ShowDialog {
  const ProcessingWidget({
    super.key,
    required this.execute,
    this.onCompleted,
    required this.messageSuccessDescription,
  });

  final Future<void> Function() execute;
  final VoidCallback? onCompleted;
  final String messageSuccessDescription;

  @override
  State<ProcessingWidget> createState() => _ProcessingWidgetState();
}

class _ProcessingWidgetState extends State<ProcessingWidget> {
  // ProcessingType type = ProcessingType.processing;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return FutureBuilder(
      future: widget.execute(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 2 / 1,
                    child: ColoredBox(
                      color: theme.colorScheme.onPrimaryContainer,
                      child: Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: theme.colorScheme.primary,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 2 / 1,
                    child: ColoredBox(
                      color: theme.colorScheme.onSecondary,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            LText(
                              LKey.processing,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Gap(2),
                            LText(
                              LKey.messageProcessingDescription,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 2 / 1,
                    child: ColoredBox(
                      color: theme.colorScheme.error,
                      child: Center(
                        child: Icon(
                          Icons.warning_amber_outlined,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 2 / 1,
                    child: ColoredBox(
                      color: theme.colorScheme.onSecondary,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            LText(
                              LKey.error,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Gap(2),
                            LText(
                              LKey.messageHaveAnErrorDescription,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                            Gap(4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FilledButton(
                                  style: const ButtonStyle()?.copyWith(
                                    backgroundColor: MaterialStateProperty.all(theme.colorScheme.primary),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    // context.appRouter.goToHome();
                                    setState(() {});
                                  },
                                  child: LText(
                                    LKey.tryAgain,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Gap(8),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: LText(
                                    LKey.cancel,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 2 / 1,
                  child: ColoredBox(
                    color: theme.successColor,
                    child: Center(
                      child: Icon(
                        Icons.check_circle_outlined,
                        // LineIcons.checkCircle,
                        size: 80,
                      ),
                    ),
                  ),
                ),
                AspectRatio(
                  aspectRatio: 2 / 1,
                  child: ColoredBox(
                    color: theme.colorScheme.onSecondary,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LText(
                            LKey.success,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Gap(2),
                          Text(
                            widget.messageSuccessDescription,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                          Gap(4),
                          FilledButton(
                            style: const ButtonStyle()?.copyWith(
                              // backgroundColor: MaterialStateProperty.all(theme.colorScheme.primary),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onCompleted?.call();
                            },
                            child: LText(
                              LKey.ok,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
