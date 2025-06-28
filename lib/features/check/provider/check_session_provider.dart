import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/check/check.dart';
import '../../../domain/entities/check/check_session.dart';
import '../../../domain/repositories/check/check_repository.dart';
import '../../../provider/load_list.dart';
import '../../../provider/mixin.dart';

final activeCheckSessionProvider =
    AutoDisposeNotifierProvider<LoadCheckSessionController, LoadListState<CheckSession>>(() {
  return LoadCheckSessionController(ActiveViewType.active);
});

final doneCheckSessionProvider =
    AutoDisposeNotifierProvider<LoadCheckSessionController, LoadListState<CheckSession>>(() {
  return LoadCheckSessionController(ActiveViewType.done);
});

class LoadCheckSessionController extends LoadListController<CheckSession>
    with CommonProvider<LoadListState<CheckSession>> {
  LoadCheckSessionController(this.viewType);

  final ActiveViewType viewType;

  @override
  Future<LoadResult<CheckSession>> fetchData(LoadListQuery query) {
    final checkRepo = ref.read(checkRepositoryProvider);
    switch (viewType) {
      case ActiveViewType.active:
        return checkRepo.getActiveSessions().then((value) {
          return LoadResult<CheckSession>(
            data: value,
            totalCount: value.length,
          );
        });
      case ActiveViewType.done:
        return checkRepo.getDoneSessions().then((value) {
          ;
          return LoadResult<CheckSession>(
            data: value,
            totalCount: value.length,
          );
        });
    }
  }

  // Create a new check session
  void createCheckSession(CheckSession session) async {
    try {
      showLoading();
      final checkRepo = ref.read(checkRepositoryProvider);
      final createdSession = await checkRepo.createSession(
        session.name,
        session.createdBy,
        note: session.note,
        checkedBy: session.checkedBy,
      );
      state = state.copyWith(data: [...state.data, createdSession]);
      showSuccess('Add new check session successfully');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      showError('Add new check session failed');
    } finally {
      hideLoading();
    }
  }

  // Update an existing check session
  void updateStatus(CheckSession session, CheckSessionStatus status) async {
    try {
      final checkRepo = ref.read(checkRepositoryProvider);
      final updatedSession = await checkRepo.updateSession(session.copyWith(status: status));
      state = state.copyWith(
        data: state.data.map((s) => s.id == updatedSession.id ? updatedSession : s).toList(),
      );
      showSuccess('Check session updated successfully');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      showError('Update check session failed');
    }
  }
}
