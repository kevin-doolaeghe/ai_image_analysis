import 'dart:typed_data';

import 'package:ai_image_analysis/tflite/web/image_classifier.dart';
import 'package:ai_image_analysis/tflite/web/object_detector.dart';
import 'package:camera/camera.dart';

class TFLite {
  Future<String> classifyImage(XFile image) async {
    return await ImageClassifier().classifyImage(image);
  }

  Future<Uint8List> detectObjects(XFile image) async {
    return await image.readAsBytes();
    // return await ObjectDetector().detectObjects(image);
  }
}
