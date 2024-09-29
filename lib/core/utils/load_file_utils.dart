import 'dart:convert';

import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadJsonFile(String filePath) async {
  if (!filePath.endsWith('.json')) {
    throw LoadFileException('not a json file: $filePath');
  }
  try {
    final String string = await rootBundle.loadString(filePath);
    return jsonDecode(string) as Map<String, dynamic>;
  } catch (error) {
    throw LoadFileException('load json file error: $error');
  }
}

class LoadFileException implements Exception {
  LoadFileException(this.message);

  final String message;
}
