import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginResult {
  const GoogleLoginResult({
    required this.user,
    required this.googleUser,
  });

  final User? user;
  final GoogleSignInAccount googleUser;
}

class GoogleLoginService {
  static bool _initialized = false;
  static Future<void>? _initializeFuture;

  Future<void> _ensureInitialized() {
    if (_initialized) {
      return Future.value();
    }
    _initializeFuture ??= GoogleSignIn.instance.initialize().then((_) {
      _initialized = true;
    });
    return _initializeFuture!;
  }

  Future<GoogleLoginResult> login() async {
    await _ensureInitialized();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError(
        'Google Sign-In authenticate is not supported on this platform.',
      );
    }

    final googleUser = await GoogleSignIn.instance.authenticate();
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw StateError('Missing Google ID token.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    return GoogleLoginResult(
      user: userCredential.user,
      googleUser: googleUser,
    );
  }

  Future<GoogleLoginResult?> tryRestore() async {
    await _ensureInitialized();
    final attempt =
        GoogleSignIn.instance.attemptLightweightAuthentication();
    if (attempt == null) {
      return null;
    }

    final googleUser = await attempt;
    if (googleUser == null) {
      return null;
    }

    var firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        return null;
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      firebaseUser = userCredential.user;
    }

    return GoogleLoginResult(
      user: firebaseUser,
      googleUser: googleUser,
    );
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
