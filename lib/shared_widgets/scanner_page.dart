import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'index.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({
    super.key,
    required this.onBarcodeScanned,
    this.autoStopCamera = false,
    this.singleScan = false, // New flag for single/multiple scans
  });

  final Future<void> Function(Barcode barcode) onBarcodeScanned;
  final bool autoStopCamera;
  final bool singleScan; // Added parameter

  static Future<void> scanBarcodePage(
    BuildContext context, {
    String? title,
    required Future<void> Function(Barcode barcode) onBarcodeScanned,
    bool autoStopCamera = false,
    bool singleScan = false, // New parameter for single scan
  }) {
    final pageTitle = title ?? LKey.scannerTitle.tr(context: context);
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: CustomAppBar(title: pageTitle),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 300,
                child: ScannerView(
                  onBarcodeScanned: (Barcode value) {
                    return onBarcodeScanned(value);
                  },
                  singleScan: singleScan,
                ),
              ),
              const AppDivider(),
              Expanded(
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  State<ScannerView> createState() => ScannerViewState();
}

class ScannerViewState extends State<ScannerView> with WidgetsBindingObserver {
  final stopWatch = Stopwatch();
  final MobileScannerController controller = MobileScannerController(
    detectionTimeoutMs: 500,
    detectionSpeed: DetectionSpeed.normal,
  );

  Timer? _timer;
  StreamSubscription<BarcodeCapture>? _barcodeSubscription;
  bool _hasScanned = false; // Track if a scan has occurred
  bool _permissionChecked = false;
  bool _hasCameraPermission = false;
  bool _permissionPermanentlyDenied = false;
  bool _isRequestingPermission = false;
  bool _hasRequestedPermission = false;

  void _startTimer() {
    if (!widget.autoStopCamera) {
      return;
    }

    _timer = Timer(const Duration(seconds: 10), () {
      controller.stop();
    });
  }

  void resetTimer() {
    _timer?.cancel();
    _startTimer();
  }

  Future<void> _ensureCameraPermission({bool requestIfNeeded = false}) async {
    if (_isRequestingPermission) {
      return;
    }

    setState(() {
      _isRequestingPermission = true;
    });

    PermissionStatus status = await Permission.camera.status;

    if (!status.isGranted && requestIfNeeded && !_hasRequestedPermission) {
      _hasRequestedPermission = true;
      status = await Permission.camera.request();
    }

    if (!mounted) {
      return;
    }

    final bool granted = status.isGranted;

    setState(() {
      _hasCameraPermission = granted;
      _permissionChecked = true;
      _permissionPermanentlyDenied =
          status.isPermanentlyDenied || status.isRestricted;
      _isRequestingPermission = false;
    });

    if (granted) {
      unawaited(_startScanner());
      return;
    }

    await controller.stop();
    if (_barcodeSubscription != null) {
      await _barcodeSubscription!.cancel();
      _barcodeSubscription = null;
    }
  }

  @override
  void initState() {
    super.initState();
    stopWatch.start();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_ensureCameraPermission(requestIfNeeded: true));

    if (widget.autoStopCamera) {
      // controller.addListener(_listenAutoStopCamera);
    }
  }

  Future<void> _startScanner() async {
    if (_hasCameraPermission != true) {
      return;
    }

    await controller.start();
    if (_barcodeSubscription != null) {
      await _barcodeSubscription!.cancel();
    }
    _barcodeSubscription = controller.barcodes.listen(
      (BarcodeCapture event) {
        scanListener(event);
      },
    );
    if (widget.autoStopCamera) {
      _startTimer();
    }
  }

  void scanListener(BarcodeCapture event) async {
    if (event.barcodes.isNotEmpty && !_hasScanned) {
      _hasScanned = true; // Prevent further scans

      final barcode = event.barcodes.last;
      if (barcode.displayValue != null) {
        await widget.onBarcodeScanned(barcode);
        await controller.start();
        if (widget.singleScan) {
          _hasScanned = true; // Prevent further scans
          controller.stop(); // Stop the scanner
        } else {
          resetTimer(); // Reset timer for multiple scans
        }
      }
      _hasScanned = false; // Prevent further scans
    }
  }

  void _listenAutoStopCamera() {
    if (controller.value.isRunning) {
      developer.log(
        'Camera is running time: ${stopWatch.elapsedMilliseconds}',
        name: 'ScannerView',
      );
      resetTimer();
    }
  }

  String? _extractErrorDetail(MobileScannerException error) {
    final message = error.errorDetails?.message;
    if (message != null && message.trim().isNotEmpty) {
      return message.trim();
    }

    final details = error.errorDetails?.details;
    if (details is String && details.trim().isNotEmpty) {
      return details.trim();
    }

    return null;
  }

  Future<bool> _isCameraPermissionPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied || status.isRestricted;
  }

  void _openSystemSettings() {
    unawaited(openAppSettings());
  }

  Widget _buildScannerErrorCard(
    BuildContext context, {
    required String message,
    required IconData icon,
    bool showRetry = true,
    bool showOpenSettings = false,
    String? detail,
    bool isProcessing = false,
    VoidCallback? onRetry,
  }) {
    final theme = Theme.of(context);
    final actions = <Widget>[];

    if (showOpenSettings && !isProcessing) {
      actions.add(
        OutlinedButton.icon(
          onPressed: _openSystemSettings,
          icon: const Icon(Icons.settings_rounded),
          label: Text(
            LKey.buttonOpenSettings.tr(context: context),
          ),
        ),
      );
    }

    if (showRetry && !isProcessing) {
      actions.add(
        FilledButton.icon(
          onPressed: onRetry ??
              () {
                unawaited(controller.start());
              },
          icon: const Icon(Icons.refresh_rounded),
          label: Text(
            LKey.buttonRetry.tr(context: context),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (detail != null && detail.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (isProcessing) ...[
                  const SizedBox(height: 18),
                  const CircularProgressIndicator(),
                ] else if (actions.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRequestView() {
    final message = _permissionPermanentlyDenied
        ? LKey.scannerCameraPermissionPermanentlyDenied.tr(context: context)
        : LKey.scannerCameraPermissionDenied.tr(context: context);

    return _buildScannerErrorCard(
      context,
      message: message,
      icon: Icons.lock_outline_rounded,
      showOpenSettings: true,
      showRetry: false,
      isProcessing: _isRequestingPermission,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_hasCameraPermission) {
          if (!_hasScanned || !widget.singleScan) {
            unawaited(controller.start());
          }
        } else {
          unawaited(_ensureCameraPermission());
        }
        break;
      case AppLifecycleState.inactive:
        unawaited(controller.stop());
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  Widget _buildBarcodeOverlay() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized || !value.isRunning || value.error != null) {
          return const SizedBox();
        }

        return StreamBuilder<BarcodeCapture>(
          stream: controller.barcodes,
          builder: (context, snapshot) {
            final BarcodeCapture? barcodeCapture = snapshot.data;

            if (barcodeCapture == null || barcodeCapture.barcodes.isEmpty) {
              return const SizedBox();
            }

            final scannedBarcode = barcodeCapture.barcodes.first;

            if (value.size.isEmpty ||
                scannedBarcode.size.isEmpty ||
                scannedBarcode.corners.isEmpty) {
              return const SizedBox();
            }

            return CustomPaint(
              painter: BarcodeOverlay(
                barcodeCorners: scannedBarcode.corners,
                barcodeSize: scannedBarcode.size,
                boxFit: BoxFit.contain,
                cameraPreviewSize: value.size,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized ||
            !value.isRunning ||
            value.error != null ||
            value.size.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(
          painter: ScannerOverlay(scanWindowRect),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionChecked) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasCameraPermission) {
      return _buildPermissionRequestView();
    }

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final padding = 40.0;

            final w = constraints.maxWidth - padding;
            final h = constraints.maxHeight - padding;

            final scanWindow = Rect.fromCenter(
              center: Size(constraints.maxWidth, constraints.maxHeight)
                  .center(Offset.zero),
              width: w,
              height: h,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (BarcodeCapture barcodes) {
                    // if (barcodes.barcodes.isNotEmpty && (!_hasScanned || !widget.singleScan)) {
                    //   print('detected barcodes: ${barcodes.barcodes.map((e) => e.displayValue).join(', ')}');
                    //   widget.onBarcodeScanned(barcodes.barcodes.last!);
                    //   if (widget.singleScan) {
                    //     _hasScanned = true;
                    //     controller.stop();
                    //   }
                    // }
                  },
                  errorBuilder: (context, error, _) {
                    final detail = _extractErrorDetail(error);

                    switch (error.errorCode) {
                      case MobileScannerErrorCode.permissionDenied:
                        return FutureBuilder<bool>(
                          future: _isCameraPermissionPermanentlyDenied(),
                          builder: (context, snapshot) {
                            final permanentlyDenied = snapshot.data ?? false;
                            final message = permanentlyDenied
                                ? LKey.scannerCameraPermissionPermanentlyDenied
                                    .tr(context: context)
                                : LKey.scannerCameraPermissionDenied
                                    .tr(context: context);

                            return _buildScannerErrorCard(
                              context,
                              message: message,
                              icon: Icons.lock_outline_rounded,
                              detail: detail,
                              showOpenSettings: true,
                              showRetry: false,
                            );
                          },
                        );
                      case MobileScannerErrorCode.unsupported:
                        return _buildScannerErrorCard(
                          context,
                          message: LKey.scannerCameraUnsupported
                              .tr(context: context),
                          icon: Icons.phonelink_off_rounded,
                          detail: detail,
                          showRetry: false,
                        );
                      default:
                        return _buildScannerErrorCard(
                          context,
                          message:
                              LKey.scannerCameraGeneric.tr(context: context),
                          icon: Icons.error_outline_rounded,
                          detail: detail,
                        );
                    }
                  },
                  fit: BoxFit.cover,
                ),
                _buildBarcodeOverlay(),
                _buildScanWindow(scanWindow),
                ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    if (!value.isInitialized ||
                        !value.isRunning ||
                        value.error != null) {
                      return const SizedBox();
                    }

                    return CustomPaint(
                      painter: BorderScannerOverlay(scanWindow: scanWindow),
                    );
                  },
                ),
              ],
            );
          }),
        ),
        Container(
          constraints: const BoxConstraints(maxHeight: 50),
          color: Colors.black.withAlpha(80),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ToggleFlashlightButton(controller: controller),
              StartStopMobileScannerButton(controller: controller),
              PauseMobileScannerButton(controller: controller),
              Expanded(
                child: Center(
                  child: ScannedBarcodeLabel(
                    barcodes: controller.barcodes,
                  ),
                ),
              ),
              SwitchCameraButton(controller: controller),
              AnalyzeImageFromGalleryButton(controller: controller),
              // Debug test button
              if (kDebugMode)
                TestScanButton(onTestScan: widget.onBarcodeScanned),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Future<void> dispose() async {
    stopWatch.stop();
    _barcodeSubscription?.cancel();
    if (widget.autoStopCamera) {
      controller.removeListener(_listenAutoStopCamera);
    }
    WidgetsBinding.instance.removeObserver(this);
    await controller.dispose();
    super.dispose();
  }
}

class InnerScannerPage extends StatelessWidget with ShowBottomSheet<void> {
  const InnerScannerPage({
    super.key,
    required this.onBarcodeScanned,
    required this.child,
  });

  final ValueChanged<Barcode> onBarcodeScanned;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 300,
            child: ScannerView(
              onBarcodeScanned: (Barcode value) async {
                Navigator.of(context).pop();
                onBarcodeScanned(value);
              },
              singleScan: true,
            ),
          ),
          const AppDivider(),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

extension ScannerPageStateX on ScannerViewState {
  //create action to control scanner
  void startScanner() {
    controller.start();
  }

  void stopScanner() {
    controller.stop();
  }

  void pauseScanner() {
    controller.stop();
  }

  void switchCamera() {
    controller.switchCamera();
  }

  void toggleFlashlight() {
    controller.toggleTorch();
  }
}

class AnalyzeImageFromGalleryButton extends StatelessWidget {
  const AnalyzeImageFromGalleryButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.white,
      icon: const Icon(Icons.image),
      iconSize: 32.0,
      onPressed: () async {
        final ImagePicker picker = ImagePicker();

        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );

        if (image == null) {
          return;
        }

        final BarcodeCapture? barcodes = await controller.analyzeImage(
          image.path,
        );

        if (!context.mounted) {
          return;
        }

        final SnackBar snackbar = barcodes != null
            ? SnackBar(
                content: Text(LKey.scannerGallerySuccess.tr(context: context)),
                backgroundColor: Colors.green,
              )
            : SnackBar(
                content: Text(LKey.scannerGalleryFailure.tr(context: context)),
                backgroundColor: Colors.red,
              );

        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
    );
  }
}

class StartStopMobileScannerButton extends StatelessWidget {
  const StartStopMobileScannerButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return IconButton(
            color: Colors.white,
            icon: const Icon(Icons.play_arrow),
            iconSize: 32.0,
            onPressed: () async {
              await controller.start();
            },
          );
        }

        return IconButton(
          color: Colors.white,
          icon: const Icon(Icons.stop),
          iconSize: 32.0,
          onPressed: () async {
            await controller.stop();
          },
        );
      },
    );
  }
}

class SwitchCameraButton extends StatelessWidget {
  const SwitchCameraButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        final int? availableCameras = state.availableCameras;

        if (availableCameras != null && availableCameras < 2) {
          return const SizedBox.shrink();
        }

        final Widget icon;

        switch (state.cameraDirection) {
          case CameraFacing.front:
            icon = const Icon(Icons.camera_front);
          case CameraFacing.back:
            icon = const Icon(Icons.camera_rear);
        }

        return IconButton(
          color: Colors.white,
          iconSize: 32.0,
          icon: icon,
          onPressed: () async {
            await controller.switchCamera();
          },
        );
      },
    );
  }
}

class ToggleFlashlightButton extends StatelessWidget {
  const ToggleFlashlightButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        switch (state.torchState) {
          case TorchState.auto:
            return IconButton(
              color: Colors.white,
              iconSize: 32.0,
              icon: const Icon(Icons.flash_auto),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.off:
            return IconButton(
              color: Colors.white,
              iconSize: 32.0,
              icon: const Icon(Icons.flash_off),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.on:
            return IconButton(
              color: Colors.white,
              iconSize: 32.0,
              icon: const Icon(Icons.flash_on),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.unavailable:
            return const SizedBox.square(
              dimension: 48.0,
              child: Icon(
                Icons.no_flash,
                size: 32.0,
                color: Colors.grey,
              ),
            );
        }
      },
    );
  }
}

class PauseMobileScannerButton extends StatelessWidget {
  const PauseMobileScannerButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        return IconButton(
          color: Colors.white,
          iconSize: 32.0,
          icon: const Icon(Icons.pause),
          onPressed: () async {
            await controller.stop();
          },
        );
      },
    );
  }
}

class ScannedBarcodeLabel extends StatelessWidget {
  const ScannedBarcodeLabel({
    super.key,
    required this.barcodes,
  });

  final Stream<BarcodeCapture> barcodes;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: barcodes,
      builder: (context, snapshot) {
        final scannedBarcodes = snapshot.data?.barcodes ?? [];

        final values = scannedBarcodes.map((e) => e.displayValue).join(', ');

        if (scannedBarcodes.isEmpty) {
          return Text(
            LKey.scannerScanningHint.tr(context: context),
            overflow: TextOverflow.fade,
            style: const TextStyle(color: Colors.white),
          );
        }

        return Text(
          values.isEmpty
              ? LKey.scannerNoDisplayValue.tr(context: context)
              : values,
          overflow: TextOverflow.fade,
          style: const TextStyle(color: Colors.white),
        );
      },
    );
  }
}

// class ScannerOverlay extends CustomPainter {
//   const ScannerOverlay({
//     required this.scanWindow,
//     this.borderRadius = 12.0,
//   });
//
//   final Rect scanWindow;
//   final double borderRadius;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // we need to pass the size to the custom paint widget
//     final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
//
//     final cutoutPath = Path()
//       ..addRRect(
//         RRect.fromRectAndCorners(
//           scanWindow,
//           topLeft: Radius.circular(borderRadius),
//           topRight: Radius.circular(borderRadius),
//           bottomLeft: Radius.circular(borderRadius),
//           bottomRight: Radius.circular(borderRadius),
//         ),
//       );
//
//     final backgroundPaint = Paint()
//       ..color = const Color.fromRGBO(0, 0, 0, 0.5)
//       ..style = PaintingStyle.fill
//       ..blendMode = BlendMode.dstOver;
//
//     final backgroundWithCutout = Path.combine(
//       PathOperation.difference,
//       backgroundPath,
//       cutoutPath,
//     );
//
//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4.0;
//
//     final borderRect = RRect.fromRectAndCorners(
//       scanWindow,
//       topLeft: Radius.circular(borderRadius),
//       topRight: Radius.circular(borderRadius),
//       bottomLeft: Radius.circular(borderRadius),
//       bottomRight: Radius.circular(borderRadius),
//     );
//
//     // First, draw the background,
//     // with a cutout area that is a bit larger than the scan window.
//     // Finally, draw the scan window itself.
//     canvas.drawPath(backgroundWithCutout, backgroundPaint);
//     canvas.drawRRect(borderRect, borderPaint);
//   }
//
//   @override
//   bool shouldRepaint(ScannerOverlay oldDelegate) {
//     return scanWindow != oldDelegate.scanWindow || borderRadius != oldDelegate.borderRadius;
//   }
// }

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    // we need to pass the size to the custom paint widget
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOver;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BarcodeOverlay extends CustomPainter {
  BarcodeOverlay({
    required this.barcodeCorners,
    required this.barcodeSize,
    required this.boxFit,
    required this.cameraPreviewSize,
  });

  final List<Offset> barcodeCorners;
  final Size barcodeSize;
  final BoxFit boxFit;
  final Size cameraPreviewSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (barcodeCorners.isEmpty ||
        barcodeSize.isEmpty ||
        cameraPreviewSize.isEmpty) {
      return;
    }

    final adjustedSize = applyBoxFit(boxFit, cameraPreviewSize, size);

    double verticalPadding = size.height - adjustedSize.destination.height;
    double horizontalPadding = size.width - adjustedSize.destination.width;
    if (verticalPadding > 0) {
      verticalPadding = verticalPadding / 2;
    } else {
      verticalPadding = 0;
    }

    if (horizontalPadding > 0) {
      horizontalPadding = horizontalPadding / 2;
    } else {
      horizontalPadding = 0;
    }

    final double ratioWidth;
    final double ratioHeight;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      ratioWidth = barcodeSize.width / adjustedSize.destination.width;
      ratioHeight = barcodeSize.height / adjustedSize.destination.height;
    } else {
      ratioWidth = cameraPreviewSize.width / adjustedSize.destination.width;
      ratioHeight = cameraPreviewSize.height / adjustedSize.destination.height;
    }

    final List<Offset> adjustedOffset = [
      for (final offset in barcodeCorners)
        Offset(
          offset.dx / ratioWidth + horizontalPadding,
          offset.dy / ratioHeight + verticalPadding,
        ),
    ];

    final cutoutPath = Path()..addPolygon(adjustedOffset, true);

    final backgroundPaint = Paint()
      ..color = const Color(0x4DF44336)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    canvas.drawPath(cutoutPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BorderScannerOverlay extends CustomPainter {
  const BorderScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 0.0,
    this.cornerLength = 20.0,
    this.strokeWidth = 4.0,
    this.borderColor = Colors.white,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.5),
  });

  final Rect scanWindow;
  final double borderRadius;
  final double cornerLength;
  final double strokeWidth;
  final Color borderColor;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ nền đen mờ với phần cắt ra ở scanWindow
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanWindow, Radius.circular(borderRadius)),
      );

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);

    // Vẽ 4 góc của border
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    _drawCorners(canvas, paint);
  }

  void _drawCorners(Canvas canvas, Paint paint) {
    final double left = scanWindow.left;
    final double right = scanWindow.right;
    final double top = scanWindow.top;
    final double bottom = scanWindow.bottom;

    final path = Path();

    // Top-left corner
    path.moveTo(left, top + cornerLength);
    path.lineTo(left, top);
    path.lineTo(left + cornerLength, top);

    // Top-right corner
    path.moveTo(right - cornerLength, top);
    path.lineTo(right, top);
    path.lineTo(right, top + cornerLength);

    // Bottom-left corner
    path.moveTo(left, bottom - cornerLength);
    path.lineTo(left, bottom);
    path.lineTo(left + cornerLength, bottom);

    // Bottom-right corner
    path.moveTo(right - cornerLength, bottom);
    path.lineTo(right, bottom);
    path.lineTo(right, bottom - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BorderScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}

extension BarcodeX on Barcode {
  String showInformation() {
    return '';
  }
}

// Test button for debug mode
class TestScanButton extends StatelessWidget {
  const TestScanButton({
    super.key,
    required this.onTestScan,
  });

  final Future<void> Function(Barcode barcode) onTestScan;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showTestDialog(context),
      icon: const Icon(Icons.bug_report, color: Colors.orange),
      tooltip: LKey.scannerTestTooltip.tr(context: context),
    );
  }

  void _showTestDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LKey.scannerTestTitle.tr(context: context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(LKey.scannerTestInstruction.tr(context: context)),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: LKey.scannerTestInputLabel.tr(context: context),
                hintText: LKey.scannerTestInputHint.tr(context: context),
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.pop(context);
                  _simulateScan(value.trim());
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LKey.buttonCancel.tr(context: context)),
          ),
          TextButton(
            onPressed: () {
              final value = textController.text.trim();
              if (value.isNotEmpty) {
                Navigator.pop(context);
                _simulateScan(value);
              }
            },
            child: Text(LKey.scannerTestAction.tr(context: context)),
          ),
        ],
      ),
    );
  }

  void _simulateScan(String barcodeValue) {
    // Create a mock Barcode object
    final mockBarcode = Barcode(
      type: BarcodeType.unknown,
      format: BarcodeFormat.unknown,
      rawValue: barcodeValue,
      displayValue: barcodeValue,
      rawBytes: null,
      corners: [],
      size: Size.zero,
    );

    onTestScan(mockBarcode);
  }
}
