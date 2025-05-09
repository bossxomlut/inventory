import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/core/helpers/cancel_task_utils.dart';

void main() {
  group('CancelableOperationCancelTask', () {
    testCancelTask(CancelableOperationCancelTask<dynamic>());
  });

  group('CompleterCancelTask', () {
    testCancelTask(CompleterCancelTask<dynamic>());
  });
}

void testCancelTask<T>(CancelTask<T> cancelTask) {
  test('adds and completes task successfully', () async {
    final completer = Completer<T>();
    final future = cancelTask.addTask(completer.future);
    completer.complete(null as T);
    await expectLater(future, completes);
  });

  test('cancels task before completion', () async {
    var cancelCalled = false;
    final completer = Completer<T>();
    cancelTask.addTask(completer.future, onCancel: () {
      cancelCalled = true;
    });

    cancelTask.cancel();
    expect(cancelCalled, isTrue);
    completer.complete(null as T); // Should have no effect
  });

  test('cancels after task completion', () async {
    var cancelCalled = false;
    final completer = Completer<T>();
    final future = cancelTask.addTask(completer.future, onCancel: () {
      cancelCalled = true;
    });

    completer.complete(null as T);
    await future; // Ensure completion
    cancelTask.cancel();
    expect(cancelCalled, isFalse); // onCancel should not be called
  });

  test('handles task with error', () async {
    final completer = Completer<T>();
    final future = cancelTask.addTask(completer.future);
    completer.completeError(Exception('Test error'));
    await expectLater(future, throwsA(isA<Exception>()));
  });

  test('replaces task with new one', () async {
    var firstCancelCalled = false;
    var secondCancelCalled = false;
    final firstCompleter = Completer<T>();
    final secondCompleter = Completer<T>();

    cancelTask.addTask(firstCompleter.future, onCancel: () {
      firstCancelCalled = true;
    });
    final secondFuture = cancelTask.addTask(secondCompleter.future, onCancel: () {
      secondCancelCalled = true;
    });

    expect(firstCancelCalled, isTrue); // First task should be cancelled
    expect(secondCancelCalled, isFalse);

    secondCompleter.complete(null as T);
    await expectLater(secondFuture, completes);
  });

  test('multiple cancellations are safe', () async {
    var cancelCalledCount = 0;
    final completer = Completer<T>();
    cancelTask.addTask(completer.future, onCancel: () {
      cancelCalledCount++;
    });

    cancelTask.cancel();
    cancelTask.cancel(); // Second cancel should be a no-op
    expect(cancelCalledCount, equals(1)); // onCancel should only be called once
  });

  test('task with delayed completion', () async {
    final completer = Completer<T>();
    final future = cancelTask.addTask(Future.delayed(Duration(milliseconds: 50), () => null as T));
    await expectLater(future, completes);
    completer.complete(null as T); // Should not interfere
  });
}
