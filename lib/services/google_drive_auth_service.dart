import 'package:google_sign_in/google_sign_in.dart';

import 'google_sign_in_session.dart';

class GoogleDriveAuthService {
  static GoogleSignInAccount? _currentAccount;

  GoogleSignInAccount? get currentAccount => _currentAccount;

  Future<void> _ensureInitialized() {
    return GoogleSignInSession.ensureInitialized();
  }

  Future<GoogleSignInAccount> signIn() async {
    await _ensureInitialized();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError(
        'Google Sign-In authenticate is not supported on this platform.',
      );
    }
    final account = await GoogleSignIn.instance.authenticate();
    _currentAccount = account;
    return account;
  }

  Future<GoogleSignInAccount?> tryRestore() async {
    await _ensureInitialized();
    final attempt =
        GoogleSignIn.instance.attemptLightweightAuthentication();
    if (attempt == null) {
      return null;
    }
    final account = await attempt;
    _currentAccount = account ?? _currentAccount;
    return account;
  }

  Future<GoogleSignInAccount> ensureSignedIn() async {
    final restored = await tryRestore();
    if (restored != null) {
      return restored;
    }
    return signIn();
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await GoogleSignIn.instance.signOut();
    _currentAccount = null;
  }
}
