import 'package:riverpod/riverpod.dart';

import '../../../domain/entities/unit/unit.dart';
import '../../../provider/multiple_select.dart';

// Multi-select unit provider for filters
final multiSelectUnitProvider = AutoDisposeNotifierProvider<MultipleSelectController<Unit>, MultipleSelectState<Unit>>(() {
  return MultipleSelectController<Unit>();
});
