import 'dart:developer';

import 'package:ai_image_analysis/tflite/native/helpers.dart';
import 'package:flutter/services.dart';

class ImageClassifier extends Model {
  static const String _modelPath = 'assets/tflite/coco-ssd.model.tflite';
  static const String _labelsPath = 'assets/tflite/coco-ssd.labels.txt';

  ImageClassifier() : super(_modelPath, _labelsPath) {
    log("ImageClassifier class has been initialized.");
  }

  String classifyImage(Uint8List imageBytes) {
    log('Processing image...');
    final input = imageBytes;
    final output = List.filled(1000, 0);

    interpreter?.run(input, output);
    return labels![output.first];
  }
}
