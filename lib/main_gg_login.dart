import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sample_app/domain/use_cases/index.dart';
import 'package:sample_app/services/google_drive_service.dart';
import 'package:sample_app/services/google_login_service.dart';

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
  String? _error;
  String? _status;

  final GoogleLoginService _loginService = GoogleLoginService();
  late final GoogleLoginUseCase _loginUseCase =
      GoogleLoginUseCase(_loginService);
  late final GoogleRestoreLoginUseCase _restoreUseCase =
      GoogleRestoreLoginUseCase(_loginService);

  @override
  void initState() {
    super.initState();
    _restoreLogin();
  }

  Future<void> _restoreLogin() async {
    setState(() {
      _loading = true;
      _error = null;
      _status = 'Checking login...';
    });

    try {
      final result = await _restoreUseCase.execute(null);
      if (!mounted) return;
      if (result == null) {
        setState(() {
          _loading = false;
          _status = 'Not signed in';
        });
        return;
      }

      setState(() {
        _loading = false;
        _status = 'Login restored';
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openSuccessScreen(result);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _status = 'Restore failed';
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
      _status = null;
    });

    try {
      final result = await _loginUseCase.execute(null);
      if (!mounted) return;

      setState(() {
        _loading = false;
        _status = 'Login success';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login success')),
      );

      await _openSuccessScreen(result);
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

  Future<void> _openSuccessScreen(GoogleLoginResult result) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginSuccessScreen(
          user: result.user,
          googleUser: result.googleUser,
          loginService: _loginService,
        ),
      ),
    );
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
    required this.loginService,
  });

  final User? user;
  final GoogleSignInAccount googleUser;
  final GoogleLoginService loginService;

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  static const String _driveFolderName = 'InventoryAppFiles';
  static const String _driveFilePrefix = 'inventory';

  bool _driveBusy = false;
  String? _driveStatus;
  String? _driveFileId;
  final GoogleDriveService _driveService = GoogleDriveService();
  late final DriveWriteFileUseCase _driveWriteUseCase =
      DriveWriteFileUseCase(_driveService);
  late final DriveReadFileUseCase _driveReadUseCase =
      DriveReadFileUseCase(_driveService);
  late final DriveListFolderUseCase _driveListUseCase =
      DriveListFolderUseCase(_driveService);

  Future<void> _writeDriveFile() async {
    setState(() {
      _driveBusy = true;
      _driveStatus = null;
    });

    try {
      final now = DateTime.now().toIso8601String();
      final result = await _driveWriteUseCase.execute(
        DriveWriteParams(
          googleUser: widget.googleUser,
          folderName: _driveFolderName,
          filePrefix: _driveFilePrefix,
          content: 'Inventory login test at $now',
          userId: widget.user?.uid,
        ),
      );

      setState(() {
        _driveFileId = result.fileId;
        _driveStatus =
            'Drive write success: ${result.fileName} (folder: $_driveFolderName)';
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
      final result = await _driveReadUseCase.execute(
        DriveReadParams(
          googleUser: widget.googleUser,
          folderName: _driveFolderName,
          filePrefix: _driveFilePrefix,
          fileId: _driveFileId,
        ),
      );

      setState(() {
        _driveFileId = result.fileId;
        _driveStatus = 'Drive read success:\n${result.content}';
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

  Future<void> _listDriveFolder() async {
    setState(() {
      _driveBusy = true;
      _driveStatus = null;
    });

    try {
      final result = await _driveListUseCase.execute(
        DriveListFolderParams(
          googleUser: widget.googleUser,
          folderName: _driveFolderName,
        ),
      );

      if (result.items.isEmpty) {
        setState(() {
          _driveStatus = 'Drive folder list: empty';
        });
      } else {
        final buffer = StringBuffer(
          'Drive folder list (${result.items.length}): $_driveFolderName',
        );
        for (final item in result.items) {
          buffer.writeln();
          buffer.write(item.isFolder ? '[Folder] ' : '[File] ');
          buffer.write(item.name);
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
                onPressed: _driveBusy ? null : _listDriveFolder,
                child: const Text('List Drive folder'),
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
                  await widget.loginService.signOut();
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
