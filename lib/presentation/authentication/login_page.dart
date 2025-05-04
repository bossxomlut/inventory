import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider/login_provider.dart';

@RoutePage()
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 100),
            //text field for username
            TextField(
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              onChanged: ref.read(loginControllerProvider.notifier).updateUserName,
            ),
            const SizedBox(height: 20),
            //text field for password
            TextField(
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onChanged: ref.read(loginControllerProvider.notifier).updatePassword,
              onSubmitted: (_) => ref.read(loginControllerProvider.notifier).login(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: ref.read(loginControllerProvider.notifier).login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
