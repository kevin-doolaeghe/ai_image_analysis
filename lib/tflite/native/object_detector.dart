/*
 * Copyright 2023 The TensorFlow Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ObjectDetector {
  static const String _modelPath = 'assets/tflite/mobilenet_v1.model.tflite';
  static const String _labelPath = 'assets/tflite/mobilenet_v1.labels.txt';

  Interpreter? _interpreter;
  List<String>? _labels;

  ObjectDetector() {
    _loadModel();
    _loadLabels();
    log('Done.');
  }

  Future<void> _loadModel() async {
    log('Loading interpreter options...');
    final interpreterOptions = InterpreterOptions();
    // Use XNNPACK Delegate
    if (Platform.isAndroid) interpreterOptions.addDelegate(XNNPackDelegate());
    // Use Metal Delegate
    if (Platform.isIOS) interpreterOptions.addDelegate(GpuDelegate());

    log('Loading interpreter...');
    _interpreter = await Interpreter.fromAsset(
      _modelPath,
      options: interpreterOptions,
    );
  }

  Future<void> _loadLabels() async {
    log('Loading labels...');
    final labelsRaw = await rootBundle.loadString(_labelPath);
    _labels = labelsRaw.split('\n');
  }

  Future<Uint8List> detectObjects(Uint8List imageBytes) async {
    log('Processing image...');

    // Resizing image for model, [300, 300]
    final imageInput = img.copyResize(
      img.decodeImage(imageBytes)!,
      width: 300,
      height: 300,
    );

    // Creating matrix representation, [300, 300, 3]
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    final output = _runInference(imageMatrix);

    log('Processing outputs...');
    // Location
    final locationsRaw = output.first as List<List<num>>;
    final locations = locationsRaw.map((list) {
      return list.map((value) => (value * 300).toInt()).toList();
    }).toList();
    // log('Locations: $locations');

    // Classes
    final classesRaw = output.elementAt(1).first as List<num>;
    final classes = classesRaw.map((value) => value.toInt()).toList();
    log('Classes: $classes');

    // Scores
    final scores = output.elementAt(2).first as List<num>;
    log('Scores: $scores');

    // Number of detections
    final numberOfDetectionsRaw = output.last.first as double;
    final numberOfDetections = numberOfDetectionsRaw.toInt();
    log('Number of detections: $numberOfDetections');

    log('Classifying detected objects...');
    final List<String> classications = [];
    for (var i = 0; i < numberOfDetections; i++) {
      classications.add(_labels![classes[i]]);
    }
    log('Detected objects: $classications');

    log('Outlining objects...');
    for (var i = 0; i < numberOfDetections; i++) {
      if (scores[i] > 0.6) {
        // Rectangle drawing
        img.drawRect(
          imageInput,
          x1: locations[i][1],
          y1: locations[i][0],
          x2: locations[i][3],
          y2: locations[i][2],
          color: img.ColorRgb8(255, 0, 0),
          thickness: 3,
        );

        // Label drawing
        img.drawString(
          imageInput,
          '${classications[i]} ${scores[i]}',
          font: img.arial14,
          x: locations[i][1] + 1,
          y: locations[i][0] + 1,
          color: img.ColorRgb8(255, 0, 0),
        );
      }
    }

    log('Done.');
    return img.encodeJpg(imageInput);
  }

  List<List<Object>> _runInference(List<List<List<num>>> imageMatrix) {
    log('Running inference...');

    // Set input tensor [1, 300, 300, 3]
    final input = [imageMatrix];

    // Set output tensor
    // Locations: [4, 1001]
    // Classes: [1, 10],
    // Scores: [1, 10],
    // Number of detections: [1]
    final output = {
      0: List<List<num>>.filled(4, List<num>.filled(1001, 0)),
      1: [List<num>.filled(10, 0)],
      2: [List<num>.filled(10, 0)],
      3: [0.0],
    };

    _interpreter!.runForMultipleInputs([input], output);
    return output.values.toList();
  }
}
