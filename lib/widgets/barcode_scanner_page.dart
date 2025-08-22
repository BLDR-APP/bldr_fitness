import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _sent = false;

  void _onDetect(BarcodeCapture cap) {
    if (_sent) return;
    final code = cap.barcodes.isNotEmpty ? cap.barcodes.first.rawValue : null;
    if (code != null && RegExp(r'^\d{8,14}$').hasMatch(code)) {
      _sent = true;
      Navigator.pop(context, code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear código de barras')),
      body: MobileScanner(
        onDetect: _onDetect,
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
        ),
      ),
    );
  }
}
