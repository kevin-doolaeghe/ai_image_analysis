import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassifier {
  static const String _modelPath = 'assets/tflite/mobilenet_v1.model.tflite';
  static const String _labelPath = 'assets/tflite/mobilenet_v1.labels.txt';

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

  Future<String> classifyImage(XFile image) async {
    final input = await image.readAsBytes();
    final output = List.filled(1000, 0);

    _interpreter?.run(input, output);
    return _labels![output.first];
  }
}
