// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:dio/dio.dart';
// import 'package:injectable/injectable.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
//
// import '../../injection/injection.dart';
// import 'env.dart';
//
// abstract class IConfig {
//   String get baseUrl;
//
//   Map<String, String> get headers;
// }
//
// @Singleton(as: IConfig)
// class AppConfig extends IConfig {
//   @override
//   String get baseUrl => getIt<EnvLoader>().bareUrl;
//
//   @override
//   Map<String, String> get headers => {};
// }
//
// @module
// abstract class DioModule {
//   Dio get dio {
//     final Dio _dio = Dio();
//
//     _dio
//       ..options.baseUrl = getIt<IConfig>().baseUrl
//       ..interceptors.addAll(
//         <Interceptor>[
//           CustomPrettyDioLogger(),
//         ],
//       );
//
//     return _dio;
//   }
// }
//
// class CustomPrettyDioLogger extends PrettyDioLogger {
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     _renderCurlRepresentation(err.requestOptions);
//     super.onError(err, handler);
//   }
//
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     _renderCurlRepresentation(response.requestOptions);
//     super.onResponse(response, handler);
//   }
//
//   void _renderCurlRepresentation(RequestOptions requestOptions) {
//     // add a breakpoint here so all errors can break
//     try {
//       log(_cURLRepresentation(requestOptions));
//     } catch (err) {
//       log('unable to create a CURL representation of the requestOptions');
//     }
//   }
//
//   String _cURLRepresentation(RequestOptions options) {
//     List<String> components = ['curl -i'];
//     if (options.method.toUpperCase() != 'GET') {
//       components.add('-X ${options.method}');
//     }
//
//     options.headers.forEach((k, v) {
//       if (k != 'Cookie') {
//         components.add('-H "$k: $v"');
//       }
//     });
//
//     if (options.data != null) {
//       // // FormData can't be JSON-serialized, so keep only their fields attributes
//       // if (options.data is FormData && convertFormData == true) {
//       //   options.data = Map.fromEntries(options.data.fields as Iterable<MapEntry<String, dynamic>>);
//       // }
//
//       final data = json.encode(options.data).replaceAll('"', '\\"');
//       components.add('-d "$data"');
//     }
//
//     components.add('"${options.uri.toString()}"');
//
//     return components.join(' \\\n\t');
//   }
// }
