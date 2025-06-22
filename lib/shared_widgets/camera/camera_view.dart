import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTakingPicture = false;
  bool _isProcessing = false;
  List<XFile> _capturedImages = [];
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();

    // Lock screen orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
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
      _showError('Error initializing camera: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: !_isInitialized
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
