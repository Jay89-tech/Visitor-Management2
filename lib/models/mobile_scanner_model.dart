import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerModel with WidgetsBindingObserver {
  late final MobileScannerController controller;

  StreamSubscription<BarcodeCapture>? _subscription;

  bool isInitialized = false;
  bool isTorchOn = false;
  bool isProcessing = false;

  final Function(String qrValue) onDetect;
  final Function(Object error)? onError;

  MobileScannerModel({
    required this.onDetect,
    this.onError,
  }) {
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    WidgetsBinding.instance.addObserver(this);

    // Listen to QR codes
    _subscription = controller.barcodes.listen(_handleBarcode);
  }

  // ✅ Handle detected QR
  void _handleBarcode(BarcodeCapture capture) {
    if (isProcessing) return;

    final codes = capture.barcodes;
    if (codes.isEmpty) return;

    final raw = codes.first.rawValue;
    if (raw == null) return;

    isProcessing = true;
    onDetect(raw);
  }

  // ✅ Start camera
  Future<void> start() async {
    try {
      await controller.start();
      isInitialized = true;
    } catch (e) {
      onError?.call(e);
    }
  }

  // ✅ Stop camera
  Future<void> stop() async {
    try {
      await controller.stop();
    } catch (e) {
      onError?.call(e);
    }
  }

  // ✅ Toggle torch
  Future<void> toggleTorch() async {
    try {
      await controller.toggleTorch();
      isTorchOn = !isTorchOn;
    } catch (_) {}
  }

  // ✅ Reset after coming back from results page
  Future<void> reset() async {
    isProcessing = false;
    await start();
  }

  // ✅ Lifecycle handler
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        start();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        stop();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  // ✅ Cleanup
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    controller.dispose();
  }
}
