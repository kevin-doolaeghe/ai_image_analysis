import 'dart:typed_data';

Never _unsupported() {
  throw UnsupportedError(
    'No suitable TensorFlow Lite implementation was found on this platform.',
  );
}

// Depending on the platform the app is compiled to, the following stubs will
// be replaced with the methods in native.dart or web.dart

class TFLite {
  TFLite();

  Future<String> classifyImage(Uint8List imageBytes) async {
    _unsupported();
  }

  Future<Uint8List> detectObjects(Uint8List imageBytes) async {
    _unsupported();
  }
}
