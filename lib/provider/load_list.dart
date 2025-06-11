import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/helpers/cancel_task_utils.dart';

part 'load_list.freezed.dart';

const int firstPage = 1;
const int defaultPageSize = 20;

class LoadResult<T> {
  final List<T> data;
  final int totalCount;

  LoadResult({
    required this.data,
    required this.totalCount,
  });
}

abstract class LoadListController<T> extends AutoDisposeNotifier<LoadListState<T>> {
  final CancelTask<LoadResult<T>> _cancelTask = CompleterCancelTask<LoadResult<T>>();

  Future<LoadResult<T>> fetchData(LoadListQuery query);

  @override
  LoadListState<T> build() {
    return LoadListState<T>.initial();
  }

  LoadListQuery query = LoadListQueryX.defaultQuery;

  void resetQuery() {
    query = LoadListQueryX.defaultQuery;
  }

  Future<void> loadData({required LoadListQuery query}) async {
    try {
      // Set loading state
      state = state.copyWith(
        error: null,
        isLoading: true,
        isEndOfList: false,
        isLoadingMore: query.page > firstPage,
      );

      final newData = await _cancelTask.addTask(
        fetchData(query),
        onCancel: () {},
      );

      // Update state with new data
      final newList = query.page == firstPage ? newData.data : [...state.data, ...newData.data];

      print(
          'total count: ${newData.totalCount}, new data length: ${newData.data.length}, current data length: ${state.data.length}');

      state = state.copyWith(
        error: null,
        isLoading: false,
        isLoadingMore: false,
        data: newList,
        isEndOfList: newList.length >= newData.totalCount,
        totalCount: newData.totalCount,
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

  Future<void> init() async {
    await loadData(query: query);
  }

  Future<void> refresh() async {
    resetQuery();
    await loadData(query: query);
  }

  Future<void> search(String keyword) async {
    resetQuery();
    await loadData(query: query.copyWith(search: keyword));
  }

  Future loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.isEndOfList) {
      return;
    }

    // Increment the page number for loading more data
    query = query.copyWith(page: query.page + 1);

    // Load more data
    await loadData(query: query);
  }
}

@freezed
class LoadListState<T> with _$LoadListState<T> {
  const factory LoadListState({
    required bool isLoading,
    required bool isLoadingMore,
    required bool isEndOfList,
    required List<T> data,
    required int totalCount,
    String? error,
  }) = _LoadListState<T>;

  factory LoadListState.initial() => LoadListState<T>(
        isLoading: false,
        isLoadingMore: false,
        isEndOfList: false,
        data: [],
        error: null,
        totalCount: 0,
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

extension LoadListQueryX on LoadListQuery {
  //default LoadListQuery
  static LoadListQuery get defaultQuery => const LoadListQuery(page: firstPage, pageSize: defaultPageSize);
}
