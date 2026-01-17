import 'dart:async';
import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GgLoginApp());
}

class GgLoginApp extends StatelessWidget {
  const GgLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Login Test',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const GoogleLoginScreen(),
    );
  }
}

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  bool _loading = false;
  bool _initialized = false;
  String? _error;
  String? _status;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_initialized) {
      return;
    }
    await GoogleSignIn.instance.initialize();
    _initialized = true;
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
      _status = null;
    });

    try {
      await _ensureGoogleSignInInitialized();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw   UnsupportedError(
          'Google Sign-In authenticate is not supported on this platform.',
        );
      }

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw StateError('Missing Google ID token.');
      }
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;

      setState(() {
        _loading = false;
        _status = 'Login success';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login success')),
      );

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginSuccessScreen(
            user: userCredential.user,
            googleUser: googleUser,
          ),
        ),
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      if (e.code == GoogleSignInExceptionCode.canceled) {
        setState(() {
          _loading = false;
          _status = 'Login canceled';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login canceled')),
        );
        return;
      }
      setState(() {
        _loading = false;
        _error = e.toString();
        _status = 'Login failed';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _status = 'Login failed';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Login Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Test Google Sign-In via Firebase',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _handleGoogleSignIn,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in with Google'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              if (_status != null) ...[
                const SizedBox(height: 12),
                Text(
                  _status!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({
    super.key,
    required this.user,
    required this.googleUser,
  });

  final User? user;
  final GoogleSignInAccount googleUser;

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  static const String _driveFileName = 'inventory_login_test.txt';
  static const List<String> _driveScopes = <String>[
    drive.DriveApi.driveFileScope,
    drive.DriveApi.driveMetadataReadonlyScope,
  ];

  bool _driveBusy = false;
  String? _driveStatus;
  String? _driveFileId;

  Future<T> _withDriveApi<T>(
    Future<T> Function(drive.DriveApi api) action,
  ) async {
    final auth =
        await widget.googleUser.authorizationClient.authorizeScopes(
      _driveScopes,
    );
    final client = auth.authClient(scopes: _driveScopes);
    final api = drive.DriveApi(client);
    try {
      return await action(api);
    } finally {
      client.close();
    }
  }

  Future<void> _writeDriveFile() async {
    setState(() {
      _driveBusy = true;
      _driveStatus = null;
    });

    try {
      final now = DateTime.now().toIso8601String();
      final content = 'Inventory login test at $now';
      final bytes = utf8.encode(content);
      final media = drive.Media(
        Stream<List<int>>.fromIterable(<List<int>>[bytes]),
        bytes.length,
      );
      final metadata = drive.File()
        ..name = _driveFileName
        ..mimeType = 'text/plain';

      final created = await _withDriveApi(
        (api) => api.files.create(metadata, uploadMedia: media),
      );

      setState(() {
        _driveFileId = created.id;
        _driveStatus = 'Drive write success: ${created.name}';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drive write success')),
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      setState(() {
        _driveStatus = 'Drive write failed: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Drive write failed: ${e.code}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _driveStatus = 'Drive write failed: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drive write failed')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _driveBusy = false;
      });
    }
  }

  Future<void> _readDriveFile() async {
    setState(() {
      _driveBusy = true;
      _driveStatus = null;
    });

    try {
      final fileId = _driveFileId ?? await _findDriveFileId();
      if (fileId == null) {
        setState(() {
          _driveStatus = 'Drive read failed: file not found';
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drive read failed: file not found')),
        );
        return;
      }

      final media = await _withDriveApi(
        (api) => api.files.get(
          fileId,
          downloadOptions: drive.DownloadOptions.fullMedia,
        ),
      ) as drive.Media;
      final content = await media.stream.transform(utf8.decoder).join();

      setState(() {
        _driveFileId = fileId;
        _driveStatus = 'Drive read success:\n$content';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drive read success')),
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      setState(() {
        _driveStatus = 'Drive read failed: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Drive read failed: ${e.code}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _driveStatus = 'Drive read failed: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drive read failed')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _driveBusy = false;
      });
    }
  }

  Future<void> _listDriveRoot() async {
    setState(() {
      _driveBusy = true;
      _driveStatus = null;
    });

    try {
      final result = await _withDriveApi(
        (api) => api.files.list(
          q: "'root' in parents and trashed=false",
          $fields: 'files(id,name,mimeType,modifiedTime,size)',
          orderBy: 'folder,name',
          pageSize: 50,
          spaces: 'drive',
        ),
      );

      final files = result.files ?? <drive.File>[];
      if (files.isEmpty) {
        setState(() {
          _driveStatus = 'Drive list: empty';
        });
      } else {
        final buffer = StringBuffer('Drive list (${files.length}):');
        for (final file in files) {
          final isFolder =
              file.mimeType == 'application/vnd.google-apps.folder';
          buffer.writeln();
          buffer.write(isFolder ? '[Folder] ' : '[File] ');
          buffer.write(file.name ?? 'Unnamed');
        }
        setState(() {
          _driveStatus = buffer.toString();
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drive list loaded')),
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      setState(() {
        _driveStatus = 'Drive list failed: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Drive list failed: ${e.code}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _driveStatus = 'Drive list failed: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drive list failed')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _driveBusy = false;
      });
    }
  }

  Future<String?> _findDriveFileId() async {
    final result = await _withDriveApi(
      (api) => api.files.list(
        q: "name='$_driveFileName' and trashed=false",
        $fields: 'files(id,name)',
        spaces: 'drive',
        pageSize: 1,
      ),
    );
    return result.files?.isNotEmpty == true ? result.files!.first.id : null;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.user?.displayName ?? 'Unknown';
    final email = widget.user?.email ?? 'Unknown';
    final uid = widget.user?.uid ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Success'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, size: 56, color: Colors.green),
              const SizedBox(height: 16),
              Text('Hello, $displayName'),
              const SizedBox(height: 8),
              Text('Email: $email'),
              const SizedBox(height: 8),
              Text('UID: $uid'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _driveBusy ? null : _writeDriveFile,
                child: _driveBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Write test file to Drive'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _driveBusy ? null : _readDriveFile,
                child: const Text('Read test file from Drive'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _driveBusy ? null : _listDriveRoot,
                child: const Text('List Drive root'),
              ),
              if (_driveStatus != null) ...[
                const SizedBox(height: 12),
                Text(
                  _driveStatus!,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  await GoogleSignIn.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
