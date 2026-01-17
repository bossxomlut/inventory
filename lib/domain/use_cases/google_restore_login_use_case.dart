import 'package:sample_app/core/use_case.dart';
import 'package:sample_app/services/google_login_service.dart';

class GoogleRestoreLoginUseCase
    extends FutureUseCase<GoogleLoginResult?, void> {
  GoogleRestoreLoginUseCase(this._service);

  final GoogleLoginService _service;

  @override
  Future<GoogleLoginResult?> execute(void input) {
    return _service.tryRestore();
  }
}
