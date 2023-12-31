import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassifier {
  static const String _modelPath = 'assets/tflite/coco-ssd.model.tflite';
  static const String _labelPath = 'assets/tflite/coco-ssd.labels.txt';

  Interpreter? _interpreter;
  List<String>? _labels;

  ImageClassifier() {
    _loadModel();
    _loadLabels();
  }

  Future<void> _loadModel() async {
    final interpreterOptions = InterpreterOptions();
    // Use XNNPACK Delegate
    if (Platform.isAndroid) interpreterOptions.addDelegate(XNNPackDelegate());
    // Use Metal Delegate
    if (Platform.isIOS) interpreterOptions.addDelegate(GpuDelegate());

    _interpreter = await Interpreter.fromAsset(
      _modelPath,
      options: interpreterOptions,
    );
  }

  Future<void> _loadLabels() async {
    final labelsRaw = await rootBundle.loadString(_labelPath);
    _labels = labelsRaw.split('\n');
  }

  Future<String> classifyImage(Uint8List imageBytes) async {
    final input = imageBytes;
    final output = List.filled(1000, 0);

    _interpreter?.run(input, output);
    return _labels![output.first];
  }
}
