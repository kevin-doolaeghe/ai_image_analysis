import 'dart:typed_data';

import 'package:camera/camera.dart';

class TFLite {
  Future<String> classifyImage(XFile image) async {
    return 'toto';
  }

  Future<Uint8List> detectObjects(XFile image) async {
    return await image.readAsBytes();
  }
}
