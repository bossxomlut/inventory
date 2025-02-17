import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection/injection.dart';

mixin BlocProviderMixin<T extends StatefulWidget, C extends Cubit<dynamic>> on State<T> {
  final C _cubit = getIt.get();

  C get cubit => _cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<C>(
      create: (BuildContext context) => _cubit,
      child: super.build(context),
    );
  }
}

mixin BlocListenerMixin<T extends StatefulWidget, S, C extends Cubit<S>> on State<T> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<C, S>(
      listener: (BuildContext context, S state) {
        onStateChange(state);
      },
      child: super.build(context),
    );
  }

  /// Called when the [cubit] state has changed
  void onStateChange(S state) {}
}

mixin SafeEmit<T> on Cubit<T> {
  @override
  void emit(T state) {
    if (!isClosed) {
      super.emit(state);
    }
  }
}
