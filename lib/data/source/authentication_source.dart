import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'authentication_source.g.dart';

@injectable
@RestApi()
abstract class AuthenticationSource {
  @factoryMethod
  factory AuthenticationSource(Dio dio) = _AuthenticationSource;

  @POST("/auth/login")
  Future<String> login(@Body() AuthCredentials credentials);
}

class AuthCredentials {
  final String username;
  final String password;

  AuthCredentials({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
