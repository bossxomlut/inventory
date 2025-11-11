import 'dart:async';
import 'dart:developer' as developer;

/// Đo thời gian thực thi của một hàm đồng bộ (sync function)
void measureExecutionTimeSync(Function function) {
  final stopwatch = Stopwatch()..start();
  function();
  stopwatch.stop();
  developer.log(
    'Thời gian thực thi (sync): ${stopwatch.elapsedMilliseconds} ms',
    name: 'ExecutionTimer',
  );
}

/// Đo thời gian thực thi của một hàm bất đồng bộ (async function)
Future<void> measureExecutionTime(Future<void> Function() function) async {
  final stopwatch = Stopwatch()..start();
  await function();
  stopwatch.stop();
  developer.log(
    'Thời gian thực thi (async): ${stopwatch.elapsedMilliseconds} ms',
    name: 'ExecutionTimer',
  );
}

/// Ví dụ: Hàm sync cần đo thời gian
void calculateSum() {
  int sum = 0;
  for (int i = 0; i < 1000000; i++) {
    sum += i;
  }
}

/// Ví dụ: Hàm async cần đo thời gian
Future<void> fetchData() async {
  await Future.delayed(Duration(seconds: 2)); // Giả lập API call
  developer.log("Dữ liệu đã tải xong!", name: 'ExecutionTimer');
}

/// Hàm main để test
void main() async {
  developer.log("🔹 Đo thời gian thực thi hàm đồng bộ:", name: 'ExecutionTimer');
  measureExecutionTimeSync(calculateSum);

  developer.log("\n🔹 Đo thời gian thực thi hàm bất đồng bộ:", name: 'ExecutionTimer');
  await measureExecutionTime(fetchData);
}
