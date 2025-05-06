import 'dart:async';

extension StreamUtils<T> on Stream<T> {
  Future<List<T>> toFuture() {
    Completer<List<T>> completer = Completer();
    List<T>? value;
    listen(
      (event) {
        if (value == null) {
          value = [event];
        } else {
          value!.add(event);
        }
      },
      onDone: () {
        if (value != null) {
          completer.complete(value);
        } else {
          completer.completeError("noData");
        }
      },
    );
    return completer.future;
  }
}
