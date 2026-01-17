import 'package:sample_app/core/use_case.dart';
import 'package:sample_app/services/google_login_service.dart';

class GoogleLoginUseCase
    extends FutureUseCase<GoogleLoginResult, void> {
  GoogleLoginUseCase(this._service);

  final GoogleLoginService _service;

  @override
  Future<GoogleLoginResult> execute(void input) {
    return _service.login();
  }
}
