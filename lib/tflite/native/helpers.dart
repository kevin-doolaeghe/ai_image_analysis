import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Model {
  Interpreter? interpreter;
  List<String>? labels;

  Model(String modelPath, String labelsPath) {
    _loadModel(modelPath);
    _loadLabels(labelsPath);
  }

  Future<void> _loadModel(String modelPath) async {
    log('Loading interpreter options...');
    final interpreterOptions = InterpreterOptions();
    // Use XNNPACK Delegate
    if (Platform.isAndroid) interpreterOptions.addDelegate(XNNPackDelegate());
    // Use Metal Delegate
    if (Platform.isIOS) interpreterOptions.addDelegate(GpuDelegate());

    log('Loading interpreter...');
    interpreter = await Interpreter.fromAsset(
      modelPath,
      options: interpreterOptions,
    );
  }

  Future<void> _loadLabels(String labelsPath) async {
    log('Loading labels...');
    final labelsRaw = await rootBundle.loadString(labelsPath);
    labels = labelsRaw.split('\n');
  }
}
