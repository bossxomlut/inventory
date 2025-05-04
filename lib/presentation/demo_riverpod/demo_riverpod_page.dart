import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/index.dart';
import 'provider/counter.dart';

@RoutePage()
class DemoRiverpodPage extends StatefulWidget {
  const DemoRiverpodPage({super.key});

  @override
  State<DemoRiverpodPage> createState() => _DemoRiverpodPageState();
}

class _DemoRiverpodPageState extends State<DemoRiverpodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Riverpod'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const Text('Demo Riverpod'),
          const SizedBox(height: 20),
          // 4. use the provider
          CounterWidget(),
          const SizedBox(height: 20),
          // 5. use the provider
          const Text('Press the button to increment the counter'),
        ],
      ),
    );
  }
}

class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. watch the provider and rebuild when the value changes
    final counter = ref.watch(counterProvider);

    final provider = ref.read(counterProvider.notifier);
    ref.listen(
      counterProvider,
      (previous, next) {
        print('previous: $previous, next: $next');
      },
    );
    return ElevatedButton(
      // 2. use the value
      child: Text('Value: $counter'),
      // 3. change the state inside a button callback
      onPressed: () => provider.increment(),
    );
  }
}
