//create SessionMapping

import '../../domain/entities/check/check_session.dart';
import '../shared/mapping_data.dart';
import 'check_collection.dart';

class SessionMapping extends Mapping<CheckSession, CheckSessionCollection> {
  @override
  CheckSession from(CheckSessionCollection input) {
    return CheckSession(
      id: input.id,
      name: input.name,
      createdBy: input.createdBy,
      checkedBy: input.checkedBy,
      status: input.status,
      startDate: input.startDate,
      endDate: input.endDate,
      note: input.note,
      checks: [], // Checks will be loaded separately
    );
  }
}

class SessionCollectionMapping extends Mapping<CheckSessionCollection, CheckSession> {
  @override
  CheckSessionCollection from(CheckSession input) {
    return CheckSessionCollection()
      ..id = input.id
      ..name = input.name
      ..createdBy = input.createdBy
      ..checkedBy = input.checkedBy
      ..status = input.status
      ..startDate = input.startDate
      ..endDate = input.endDate
      ..note = input.note;
  }
}
