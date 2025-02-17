import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../injection/injection.dart';
import '../../logger/logger.dart';
import '../index.dart';

@singleton
class RemoteAppConfigLoader {
  Future load() async {
    const String gistApiKey = 'todo_gist_api_key';

    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    try {
      final Response response = await dio.get(
        'https://api.github.com/gists/$gistApiKey',
      );
      // Kiểm tra nếu phản hồi thành công
      if (response.statusCode == 200) {
        final data = response.data;
        final files = data['files'] as Map<String, dynamic>;

        // Giả sử file đầu tiên trong Gist chứa thông tin cần thiết
        final appConfigsFile = files['app_configs.json'] as Map<String, dynamic>;

        // Parse nội dung JSON của Gist (ví dụ {"force_update": true})
        final jsonData = jsonDecode(appConfigsFile['content'].toString());

        getIt.get<RemoteAppConfigService>().setData(jsonData as Map<String, dynamic>);
        logger.i("Load dữ liệu cập nhật bắt buộc thành công!");

        log("${jsonData}");
      } else {
        logger.e("Lỗi khi kết nối đến Gist: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("Lỗi khi kết nối đến Gist: ${e.toString()}");
    }
  }
}

@singleton
class RemoteAppConfigService {
  Map<String, dynamic> _data = {};

  void setData(Map<String, dynamic> data) {
    _data = data;
  }

  bool get isLockedApp {
    return _data['lockedApp'].toString().parseBool() ?? false;
  }

  bool get isShowConfig {
    return _data['showConfig'].toString().parseBool() ?? false;
  }
}
