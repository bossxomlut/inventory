import 'package:riverpod/riverpod.dart';

import '../../../domain/entities/product/inventory.dart';
import '../../../provider/multiple_select.dart';

// Multi-select unit provider for filters
final multiSelectUnitProvider =
    AutoDisposeNotifierProvider<MultipleSelectController<Unit>, MultipleSelectState<Unit>>(() {
  return MultipleSelectController<Unit>();
});
