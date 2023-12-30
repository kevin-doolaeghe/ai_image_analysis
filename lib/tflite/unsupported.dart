import 'dart:typed_data';

import 'package:camera/camera.dart';

Never _unsupported() {
  throw UnsupportedError(
    'No suitable TensorFlow Lite implementation was found on this platform.',
  );
}

// Depending on the platform the app is compiled to, the following stubs will
// be replaced with the methods in native.dart or web.dart

class TFLite {
  Future<String> classifyImage(XFile image) async {
    _unsupported();
  }

  Future<Uint8List> detectObjects(XFile image) async {
    _unsupported();
  }
}
