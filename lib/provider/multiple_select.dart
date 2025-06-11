import 'package:riverpod/riverpod.dart';

import '../domain/index.dart';

part 'multiple_select.freezed.dart';

@freezed
class MultipleSelectState<T> with _$MultipleSelectState<T> {
  const factory MultipleSelectState({
    required bool enable,
    required Set<T> data,
  }) = _MultipleSelectState<T>;
}

extension MultipleSelectStateX<T> on MultipleSelectState<T> {
  bool isSelected(T item) {
    return data.contains(item);
  }
}

class MultipleSelectController<T> extends AutoDisposeNotifier<MultipleSelectState<T>> {
  @override
  MultipleSelectState<T> build() {
    return MultipleSelectState<T>(
      enable: false,
      data: <T>{},
    );
  }

  void add(T item) {
    state = state.copyWith(
      data: {...state.data, item},
    );
  }

  void remove(T item) {
    state = state.copyWith(
      data: {...state.data}..remove(item),
    );
  }

  void toggle(T item) {
    if (state.data.contains(item)) {
      remove(item);
    } else {
      add(item);
    }
  }

  void clear() {
    state = state.copyWith(
      data: <T>{},
    );
  }

  void enable() {
    state = state.copyWith(
      enable: true,
    );
  }

  void disable() {
    state = state.copyWith(
      enable: false,
    );
  }

  void disableAndClear() {
    state = state.copyWith(
      enable: false,
      data: <T>{},
    );
  }
}
