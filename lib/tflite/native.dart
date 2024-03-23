import 'dart:typed_data';

import 'package:ai_image_analysis/tflite/native/image_classifier.dart';
import 'package:ai_image_analysis/tflite/native/object_detector.dart';

class TFLite {
  late ObjectDetector _objectDetector;
  late ImageClassifier _imageClassifier;

  TFLite() {
    _objectDetector = ObjectDetector();
    _imageClassifier = ImageClassifier();
  }

  String classifyImage(Uint8List imageBytes) {
    return _imageClassifier.classifyImage(imageBytes);
  }

  void detectObjects(Uint8List imageBytes) {
    _objectDetector.detectObjects(imageBytes);
  }
}
