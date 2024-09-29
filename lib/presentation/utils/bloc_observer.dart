import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../logger/logger.dart';

@Injectable(as: BlocObserver)
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    blocLogger.i('current-state: ${change.currentState}');
    blocLogger.i('next-state: ${change.nextState}');
  }
}
