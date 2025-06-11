import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

String useDebouncedText(TextEditingController controller, {Duration duration = const Duration(milliseconds: 300)}) {
  // Lưu trữ giá trị đã debounce
  final debouncedText = useState(controller.text);

  // Quản lý Timer
  final timer = useRef<Timer?>(null);

  // Lắng nghe thay đổi từ controller
  useEffect(() {
    void onTextChanged() {
      timer.value?.cancel();
      timer.value = Timer(duration, () {
        debouncedText.value = controller.text;
      });
    }

    controller.addListener(onTextChanged);
    return () => controller.removeListener(onTextChanged);
  }, [controller]);

  // Cleanup timer khi dispose
  useEffect(() {
    return () => timer.value?.cancel();
  }, []);

  return debouncedText.value;
}
