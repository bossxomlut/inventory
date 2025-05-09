import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/helpers/cancel_task_utils.dart';

part 'load_list.freezed.dart';

abstract class LoadListController<T> extends Notifier<LoadListState<T>> {
  final CancelTask<List<T>> _cancelTask = CompleterCancelTask<List<T>>();

  Future<List<T>> fetchData(LoadListQuery query);

  @override
  LoadListState<T> build() {
    return LoadListState<T>.initial();
  }

  Future<void> loadData({required LoadListQuery query}) async {
    try {
      // Set loading state
      state = state.copyWith(
        isLoading: query.page == 1,
        isLoadingMore: query.page > 1,
        error: null,
      );

      final newData = await _cancelTask.addTask(
        fetchData(query),
        onCancel: () {},
      );

      // Update state with new data
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        data: query.page == 1 ? newData : [...state.data, ...newData],
        error: null,
      );
    } catch (e, stackTrace) {
      // Handle error
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
      // Optionally log stackTrace for debugging
      print('Error loading data: $e\n$stackTrace');
    }
  }

  Future<void> refresh({required LoadListQuery query}) async {
    await loadData(
      query: query.copyWith(page: 1),
    );
  }

  Future<void> search({
    required LoadListQuery query,
  }) async {
    await loadData(query: query.copyWith(page: 1));
  }

  void loadMore({required LoadListQuery query}) {
    if (state.isLoading || state.isLoadingMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    // Increment the page number for loading more data
    final newQuery = query.copyWith(page: query.page + 1);

    // Load more data
    loadData(query: newQuery);
  }

  void add(T newProduct) {
    // Add new product to the list
    state = state.copyWith(
      data: [...state.data, newProduct],
    );
  }
}

@freezed
class LoadListState<T> with _$LoadListState<T> {
  const factory LoadListState({
    required bool isLoading,
    required bool isLoadingMore,
    required List<T> data,
    String? error,
  }) = _LoadListState<T>;

  factory LoadListState.initial() => LoadListState<T>(
        isLoading: false,
        isLoadingMore: false,
        data: [],
        error: null,
      );
}

extension LoadListStateX<T> on LoadListState<T> {
  bool get isEmpty => data.isEmpty;

  int get length => data.length;

  bool get hasError => error != null;
}

@freezed
class LoadListQuery with _$LoadListQuery {
  const factory LoadListQuery({
    required int page,
    required int pageSize,
    String? search,
    Map<String, dynamic>? filter,
  }) = _LoadListQuery;
}
