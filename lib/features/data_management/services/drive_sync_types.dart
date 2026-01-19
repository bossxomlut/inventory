typedef DriveSyncProgressCallback = void Function(String message);

class DriveSyncCancellationToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }

  void throwIfCancelled() {
    if (_isCancelled) {
      throw const DriveSyncCancelledException();
    }
  }
}

class DriveSyncCancelledException implements Exception {
  const DriveSyncCancelledException();

  @override
  String toString() => 'Drive sync cancelled';
}
