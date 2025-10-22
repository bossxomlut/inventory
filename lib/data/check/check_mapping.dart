//create SessionMapping

import 'package:isar_community/isar.dart';

import '../../domain/entities/check/check_session.dart';
import '../../domain/entities/check/checked_product.dart';
import '../../domain/entities/get_id.dart';
import '../shared/mapping_data.dart';
import 'check_collection.dart';

class SessionMapping extends Mapping<CheckSession, CheckSessionCollection> {
  @override
  CheckSession from(CheckSessionCollection input) {
    return CheckSession(
      id: input.id,
      name: input.name,
      createdBy: input.createdBy,
      status: input.status,
      startDate: input.startDate,
      endDate: input.endDate,
      note: input.note,
      checks: [], // Checks will be loaded separately
    );
  }
}

class CheckedInventoryLotCollectionMapping
    extends Mapping<CheckedInventoryLot, CheckedInventoryLotCollection> {
  @override
  CheckedInventoryLot from(CheckedInventoryLotCollection input) {
    return CheckedInventoryLot(
      id: input.id,
      inventoryLotId: input.inventoryLotId,
      expiryDate: input.expiryDate,
      manufactureDate: input.manufactureDate,
      expectedQuantity: input.expectedQuantity,
      actualQuantity: input.actualQuantity,
    );
  }
}

class CheckedInventoryLotMapping
    extends Mapping<CheckedInventoryLotCollection, CheckedInventoryLot> {
  @override
  CheckedInventoryLotCollection from(CheckedInventoryLot input) {
    return CheckedInventoryLotCollection()
      ..id = input.id == undefinedId ? Isar.autoIncrement : input.id
      ..inventoryLotId = input.inventoryLotId
      ..expiryDate = input.expiryDate
      ..manufactureDate = input.manufactureDate
      ..expectedQuantity = input.expectedQuantity
      ..actualQuantity = input.actualQuantity;
  }
}

class SessionCollectionMapping
    extends Mapping<CheckSessionCollection, CheckSession> {
  @override
  CheckSessionCollection from(CheckSession input) {
    return CheckSessionCollection()
      ..id = input.id
      ..name = input.name
      ..createdBy = input.createdBy
      ..status = input.status
      ..startDate = input.startDate
      ..endDate = input.endDate
      ..note = input.note;
  }
}
