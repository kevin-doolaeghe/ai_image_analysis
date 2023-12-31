import 'dart:typed_data';

import 'package:ai_image_analysis/tflite/web/image_classifier.dart';
import 'package:ai_image_analysis/tflite/web/object_detector.dart';

class TFLite {
  Future<String> classifyImage(Uint8List imageBytes) async {
    return await ImageClassifier().classifyImage(imageBytes);
  }

  Future<Uint8List> detectObjects(Uint8List imageBytes) async {
    return await ObjectDetector().detectObjects(imageBytes);
  }
}
