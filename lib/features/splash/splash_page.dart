import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/persistence/isar_storage.dart';
import '../../resources/index.dart';
import '../../shared_widgets/index.dart';
import '../authentication/provider/auth_provider.dart';

@RoutePage()
class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      // Simulate a delay for splash screen
      IsarDatabase().initialize().then((_) {
        // After initialization, check authentication state
        ref.read(authControllerProvider.notifier).checkLogin();
      });

      return null; // No cleanup needed
    }, []);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage.asset(url: ImagePath.logo, width: 100, height: 100),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('Đang tải...'),
          ],
        ),
      ),
    );
  }
}
