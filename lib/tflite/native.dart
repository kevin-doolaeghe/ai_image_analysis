import 'dart:typed_data';

import 'package:ai_image_analysis/tflite/native/image_classifier.dart';
import 'package:ai_image_analysis/tflite/native/object_detector.dart';
import 'package:camera/camera.dart';

class TFLite {
  Future<String> classifyImage(XFile image) async {
    final category = await ImageClassifier().classifyImage(image);
    return category;
  }

  Future<Uint8List> detectObjects(XFile image) async {
    final imageData = await ObjectDetector().detectObjects(image);
    return imageData;
  }
}
