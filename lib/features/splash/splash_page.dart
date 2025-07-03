import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/persistence/isar_storage.dart';
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

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
