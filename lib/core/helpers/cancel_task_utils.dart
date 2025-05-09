import 'dart:async';

import 'package:async/async.dart';

abstract class CancelTask<T> {
  Future<T> addTask(Future<T> future, {FutureOr Function()? onCancel});

  void cancel();
}

class CancelableOperationCancelTask<T> implements CancelTask<T> {
  CancelableOperation<T>? _operation;
  FutureOr Function()? _onCancel;

  @override
  Future<T> addTask(Future<T> future, {FutureOr Function()? onCancel}) {
    cancel();
    _onCancel = onCancel;
    _operation = CancelableOperation.fromFuture(future, onCancel: _onCancel);
    return _operation!.value;
  }

  @override
  void cancel() {
    if (_operation != null) {
      _operation!.cancel();
      _operation = null;
      _onCancel = null;
    }
  }
}

class CompleterCancelTask<T> implements CancelTask<T> {
  CancelableCompleter<T>? _cancelableCompleter;
  FutureOr Function()? _onCancel;

  @override
  Future<T> addTask(Future<T> future, {FutureOr Function()? onCancel}) {
    cancel();
    _onCancel = onCancel;
    _cancelableCompleter = CancelableCompleter(onCancel: _onCancel);
    _cancelableCompleter!.complete(future);
    return _cancelableCompleter!.operation.value;
  }

  @override
  void cancel() {
    if (_cancelableCompleter != null) {
      _cancelableCompleter!.operation.cancel();
      _cancelableCompleter = null;
      _onCancel = null;
    }
  }
}
