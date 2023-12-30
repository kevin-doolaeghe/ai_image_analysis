import 'dart:typed_data';

import 'package:ai_image_analysis/tflite/native/object_detection.dart';
import 'package:camera/camera.dart';

class TFLite {
  Future<String> classifyImage(XFile image) async {
    return 'titi';
  }

  Future<Uint8List> detectObjects(XFile image) async {
    final objectDetection = ObjectDetection();
    final imageData = await objectDetection.detectObjects(image);

    return imageData;
  }
}
