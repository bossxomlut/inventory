import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black38,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}
