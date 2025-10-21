import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/helpers/currency_config.dart';
import '../../../provider/storage_provider.dart';

part 'currency_settings_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrencySettingsController extends _$CurrencySettingsController {
  static const String _storageKey = 'settings.currencyUnit';

  @override
  Future<CurrencyUnit> build() async {
    final storage = ref.read(simpleStorageProvider);
    await storage.init();

    final storedValue = await storage.getString(_storageKey);
    final unit = CurrencyUnitX.fromStorageValue(storedValue);
    CurrencySettingsHolder.current = unit.display;
    return unit;
  }

  Future<void> setCurrencyUnit(CurrencyUnit unit) async {
    final currentUnit = state.valueOrNull;
    if (currentUnit == unit) {
      return;
    }

    final storage = ref.read(simpleStorageProvider);
    await storage.init();
    await storage.saveString(_storageKey, unit.storageValue);

    CurrencySettingsHolder.current = unit.display;
    state = AsyncValue.data(unit);
  }
}

const supportedCurrencyUnits = [
  CurrencyUnit.vnd,
  CurrencyUnit.usd,
];
