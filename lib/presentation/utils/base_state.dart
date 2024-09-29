import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit_utils.dart';
import 'scaffold_utils.dart';

abstract class BaseState<T extends StatefulWidget, S, C extends Cubit<S>> extends State<T>
    with StateTemplate<T>, BlocListenerMixin<T, S, C>, BlocProviderMixin<T, C>, LoadingState<T> {}
