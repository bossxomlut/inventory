import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/check/check.dart';
import '../../../domain/entities/check/check_session.dart';
import '../../../domain/repositories/check/check_repository.dart';
import '../../../provider/index.dart';
import '../../../provider/load_list.dart';
import '../widget/create_session_bottom_sheet.dart';

part 'check_session_provider.g.dart';

@riverpod
class LoadCheckSession extends _$LoadCheckSession
    with LoadListController<CheckSession>, CommonProvider<LoadListState<CheckSession>> {
  @override
  LoadListState<CheckSession> build(ActiveViewType viewType) {
    return LoadListState<CheckSession>.initial();
  }

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
          return LoadResult<CheckSession>(
            data: value,
            totalCount: value.length,
          );
        });
    }
  }

  Future<CheckSession?> createCheckSession(CreateSessionState session) async {
    try {
      showLoading();
      final checkRepo = ref.read(checkRepositoryProvider);
      final createdSession = await checkRepo.createSession(
        session.name,
        session.createdBy,
        note: session.note,
      );

      hideLoading();

      state = state.copyWith(data: [...state.data, createdSession]);

      return createdSession;
    } catch (e) {
      hideLoading();

      state = state.copyWith(error: e.toString());
    }
    return null;
  }

  // Update an existing check session
  Future<void> updateStatus(CheckSession session, CheckSessionStatus status) async {
    try {
      final checkRepo = ref.read(checkRepositoryProvider);
      await checkRepo.updateSession(session.copyWith(status: status));
      refresh();
      showSuccess('Check session updated successfully');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      showError('Update check session failed');
    }
  }

  void deleteCheckSession(CheckSession session) async {
    try {
      final checkRepo = ref.read(checkRepositoryProvider);
      await checkRepo.deleteSession(session);
      final newList = state.data.toList();
      newList.removeWhere((e) => e.id == session.id);
      state = state.copyWith(data: newList);
      showSuccess('Check session deleted successfully');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      showError('Delete check session failed');
    }
  }
}
