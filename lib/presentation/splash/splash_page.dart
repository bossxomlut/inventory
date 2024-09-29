import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../route/app_router.gr.dart';
import '../utils/scaffold_utils.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with StateTemplate<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      context.router.replace(LoginRoute());
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    return const Center(
      child: Text('Splash Screen\nHello World!'),
    );
  }
}
