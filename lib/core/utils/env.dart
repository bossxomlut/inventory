// import 'package:dartz/dartz.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:injectable/injectable.dart';
//
// import '../../logger/logger.dart';
// import 'converter_utils.dart';
// import 'dartz_utils.dart';
// import 'load_file_utils.dart';
//
// part 'env.g.dart';
//
// enum Environment {
//   TEST('assets/config/test.env.json'),
//   STAGING('assets/config/staging.env.json'),
//   PROD('assets/config/prod.env.json');
//
//   const Environment(this.fileName);
//
//   final String fileName;
// }
//
// @singleton
// class EnvLoader {
//   EnvConfigModel? _configModel;
//
//   Option<EnvConfigModel> get configModel => OptionOf.value(_configModel);
//
//   String get bareUrl => _configModel?.baseUrl ?? 'not_found_base_url';
//
//   Future<void> load(Environment environment) async {
//     try {
//       final Map<String, dynamic> jsonData = await loadJsonFile(environment.fileName);
//       logger.d('load env config: $jsonData');
//       _configModel = EnvConfigModel.fromJson(jsonData);
//
//       logger.i('[${environment.name}] load env config success: ${_configModel?.toJson()}');
//     } catch (e) {
//       logger.e('load env config error: $e', error: e);
//     }
//   }
// }
//
// @customJsonSerializable
// class EnvConfigModel {
//   EnvConfigModel({required this.baseUrl, required this.apiKey});
//
//   factory EnvConfigModel.fromJson(Map<String, dynamic> json) => _$EnvConfigModelFromJson(json);
//
//   Map<String, dynamic> toJson() => _$EnvConfigModelToJson(this);
//
//   @JsonKey(defaultValue: 'not_found_base_url')
//   final String? baseUrl;
//
//   @JsonKey(defaultValue: 'not_found_api_key')
//   final String? apiKey;
// }
