import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInSession {
  static bool _initialized = false;
  static Future<void>? _initializeFuture;

  static Future<void> ensureInitialized() {
    if (_initialized) {
      return Future.value();
    }
    _initializeFuture ??= GoogleSignIn.instance.initialize().then((_) {
      _initialized = true;
    });
    return _initializeFuture!;
  }
}
