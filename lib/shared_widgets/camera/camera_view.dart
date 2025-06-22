import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraView extends StatefulWidget {
  final int? maxImageCount;
  final String title;
  final bool allowGalleryPick;
  final bool allowSwitchCamera;
  final bool useBackCamera;

  const CameraView({
    Key? key,
    this.maxImageCount,
    this.title = 'Chụp ảnh',
    this.allowGalleryPick = true,
    this.allowSwitchCamera = false,
    this.useBackCamera = true,
  }) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();

  static Future<List<XFile>?> show(
    BuildContext context, {
    int? maxImageCount,
    String title = 'Chụp ảnh',
    bool allowGalleryPick = true,
    bool allowSwitchCamera = false,
    bool useBackCamera = true,
  }) async {
    // Hide keyboard before navigating to camera view
    FocusScope.of(context).unfocus();

    // Mở màn hình camera và để việc kiểm tra quyền ở initState
    if (context.mounted) {
      return await Navigator.of(context).push<List<XFile>>(
        MaterialPageRoute(
          builder: (context) => CameraView(
            maxImageCount: maxImageCount,
            title: title,
            allowGalleryPick: allowGalleryPick,
            allowSwitchCamera: allowSwitchCamera,
            useBackCamera: useBackCamera,
          ),
        ),
      );
    }

    return null;
  }
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTakingPicture = false;
  bool _isProcessing = false;
  List<XFile> _capturedImages = [];
  int _selectedCameraIndex = 0;
  bool _hasCameraPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Kiểm tra và yêu cầu quyền camera khi màn hình được khởi tạo
    _checkAndRequestPermission();

    // Lock screen orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  // Kiểm tra quyền và yêu cầu quyền nếu cần
  Future<void> _checkAndRequestPermission() async {
    // Kiểm tra quyền camera
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      // Yêu cầu quyền camera
      status = await Permission.camera.request();

      if (!status.isGranted && mounted) {
        // Hiển thị dialog thông báo nếu người dùng từ chối
        await _showPermissionDeniedDialog();
        return;
      }
    }

    // Cập nhật trạng thái quyền và khởi tạo camera
    if (mounted) {
      _hasCameraPermission = status.isGranted;
      if (_hasCameraPermission) {
        _initCamera();
      } else {
        setState(() {});
      }
    }
  }

  // Hiển thị dialog thông báo khi không có quyền camera
  Future<void> _showPermissionDeniedDialog() async {
    if (!mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cần quyền truy cập Camera'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn chưa cho phép ứng dụng sử dụng Camera.'),
                Text('Vui lòng cấp quyền trong phần Cài đặt để sử dụng tính năng này.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Mở Cài đặt'),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);

    // Reset screen orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Kiểm tra lại quyền truy cập khi ứng dụng được resume (người dùng có thể đã thay đổi quyền từ cài đặt)
      _checkAndRequestPermission();
    }
  }

  Future<void> _initCamera() async {
    try {
      // Chỉ khởi tạo camera khi đã có quyền
      if (!_hasCameraPermission) {
        setState(() {
          _isInitialized = false;
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        _showError('Không tìm thấy camera');
        return;
      }

      // Select camera based on preference
      _selectedCameraIndex = _findPreferredCamera();

      // Initialize camera controller
      await _setupCameraController(_selectedCameraIndex);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      _showError('Không thể khởi tạo camera: $e');
    }
  }

  int _findPreferredCamera() {
    if (_cameras == null || _cameras!.isEmpty) return 0;

    // Find back camera if preferred
    if (widget.useBackCamera) {
      for (int i = 0; i < _cameras!.length; i++) {
        if (_cameras![i].lensDirection == CameraLensDirection.back) {
          return i;
        }
      }
    } else {
      // Find front camera if back is not preferred
      for (int i = 0; i < _cameras!.length; i++) {
        if (_cameras![i].lensDirection == CameraLensDirection.front) {
          return i;
        }
      }
    }

    // Default to first camera if preferred direction not found
    return 0;
  }

  Future<void> _setupCameraController(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    if (_controller != null) {
      await _controller!.dispose();
    }

    // Create a new controller
    _controller = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    // Initialize the controller
    try {
      await _controller!.initialize();
    } catch (e) {
      _showError('Lỗi khởi tạo camera: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _takePicture() async {
    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (_isTakingPicture) return;

    try {
      setState(() {
        _isTakingPicture = true;
        _isProcessing = true;
      });

      // Check if maximum number of images reached
      if (widget.maxImageCount != null && _capturedImages.length >= widget.maxImageCount!) {
        _showError('Đã đạt số lượng ảnh tối đa (${widget.maxImageCount})');
        setState(() {
          _isTakingPicture = false;
          _isProcessing = false;
        });
        return;
      }

      // Take the picture
      final XFile file = await _controller!.takePicture();

      // Add to list
      setState(() {
        _capturedImages.insert(0, file);
        _isTakingPicture = false;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isTakingPicture = false;
        _isProcessing = false;
      });
      _showError('Lỗi khi chụp ảnh: $e');
    }
  }

  void _switchCamera() {
    if (_cameras == null || _cameras!.length <= 1) return;

    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      _isInitialized = false;
    });

    _setupCameraController(_selectedCameraIndex);

    setState(() {
      _isInitialized = true;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });
  }

  void _completeCapture() {
    Navigator.of(context).pop(_capturedImages);
  }

  Future<bool> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    return status.isGranted;
  }

  // Mở cài đặt ứng dụng để người dùng cấp quyền camera
  Future<void> _openAppSettings() async {
    // Mở cài đặt ứng dụng
    final opened = await openAppSettings();

    if (!opened) {
      // Nếu không thể mở cài đặt, hiển thị thông báo lỗi
      _showError('Không thể mở cài đặt ứng dụng. Vui lòng mở cài đặt thủ công để cấp quyền camera.');
    }

    // Lưu ý: Không cần thiết phải xử lý quyền ở đây vì didChangeAppLifecycleState sẽ được gọi khi ứng dụng resume
  }

  // Hiển thị màn hình khi không có quyền truy cập camera
  Widget _buildPermissionDeniedView() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.no_photography,
            color: Colors.white,
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            'Bạn chưa cho phép sử dụng Camera',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Để chụp ảnh, vui lòng cấp quyền truy cập camera cho ứng dụng. Sau khi cấp quyền, camera sẽ tự động hiển thị.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Cấp quyền Camera'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final hasPermission = await _requestCameraPermission();
              if (mounted) {
                setState(() {
                  _hasCameraPermission = hasPermission;
                  if (hasPermission) {
                    _initCamera();
                  }
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            icon: const Icon(Icons.settings),
            label: const Text('Mở Cài đặt'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            onPressed: _openAppSettings,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: !_hasCameraPermission
          ? _buildPermissionDeniedView()
          : !_isInitialized
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Camera Preview
                          _controller!.value.isInitialized
                              ? CameraPreview(_controller!)
                              : Container(
                                  color: Colors.black,
                                  child: Center(
                                    child: Text(
                                      'Đang tải camera...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),

                          // Taking picture overlay
                          if (_isTakingPicture)
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),

                          // Image count indicator
                          if (_capturedImages.isNotEmpty)
                            Positioned(
                              bottom: 16,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${_capturedImages.length}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Thumbnails of captured images
                    if (_capturedImages.isNotEmpty)
                      Container(
                        height: 80,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        color: Colors.black,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _capturedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Preview the image in full screen
                                      Navigator.of(context).push<void>(
                                        MaterialPageRoute<void>(
                                          builder: (context) => ImagePreviewScreen(
                                            imageFile: _capturedImages[index],
                                            onDelete: () {
                                              Navigator.of(context).pop();
                                              _removeImage(index);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: Image.file(
                                          File(_capturedImages[index].path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: InkWell(
                                      onTap: () => _removeImage(index),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(7),
                                          bottomLeft: Radius.circular(7),
                                        ),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: const BoxDecoration(
                                            color: Color(0x66000000),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Color(0xFFEBEBEB),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    // Camera controls
                    Container(
                      height: 100,
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      color: Colors.black,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Switch camera button (only shown if allowed)
                          widget.allowSwitchCamera
                              ? IconButton(
                                  icon: Icon(Icons.flip_camera_android, color: Colors.white),
                                  onPressed: _switchCamera,
                                )
                              : SizedBox(width: 48),

                          // Capture button
                          GestureDetector(
                            onTap: _isProcessing ? null : _takePicture,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _isProcessing ? Colors.grey : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Done button (visible when images captured)
                          _capturedImages.isEmpty
                              ? SizedBox(width: 48)
                              : TextButton(
                                  onPressed: _completeCapture,
                                  child: Text(
                                    'Xong',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final XFile imageFile;
  final VoidCallback onDelete;

  const ImagePreviewScreen({
    Key? key,
    required this.imageFile,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            label: const Text('Xóa', style: TextStyle(color: Colors.white)),
            onPressed: onDelete,
          ),
        ],
      ),
      body: Center(
        child: Image.file(File(imageFile.path)),
      ),
    );
  }
}
