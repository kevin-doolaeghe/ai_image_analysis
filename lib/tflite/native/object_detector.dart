import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:ai_image_analysis/tflite/native/helpers.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

enum _Codes {
  init,
  busy,
  ready,
  detect,
  result,
}

class _Command {
  const _Command(this.code, {this.args});

  final _Codes code;
  final List<Object>? args;
}

class ScreenParams {
  static late Size screenSize;
  static late Size previewSize;

  static double previewRatio = (previewSize.height > previewSize.width
          ? previewSize.height
          : previewSize.width) /
      (previewSize.height < previewSize.width
          ? previewSize.height
          : previewSize.width);

  static Size screenPreviewSize = Size(
    screenSize.width,
    screenSize.width * previewRatio,
  );
}

const int _modelInputSize = 300;

class Recognition {
  final int _id;
  final String _label;
  final double _score;
  final Rect _location;

  Recognition(this._id, this._label, this._score, this._location);

  int get id => _id;
  String get label => _label;
  double get score => _score;
  Rect get location => _location;

  Rect get renderLocation {
    final double scaleX =
        ScreenParams.screenPreviewSize.width / _modelInputSize;
    final double scaleY =
        ScreenParams.screenPreviewSize.height / _modelInputSize;
    return Rect.fromLTWH(
      location.left * scaleX,
      location.top * scaleY,
      location.width * scaleX,
      location.height * scaleY,
    );
  }

  @override
  String toString() {
    return 'Recognition(id: $id, label: $label, score: $score, location: $location)';
  }
}

class ObjectDetector extends Model {
  static const String _modelPath = 'assets/tflite/mobilenet_v1.model.tflite';
  static const String _labelsPath = 'assets/tflite/mobilenet_v1.labels.txt';

  late final Isolate _isolate;
  late final SendPort _sendPort;

  bool _isReady = false;

  final resultList = StreamController<Map<String, dynamic>>();

  ObjectDetector() : super(_modelPath, _labelsPath) {
    log('ObjectDetector class has been initialized.');
  }

  Future<void> start() async {
    final ReceivePort receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      _ObjectDetectorService._run,
      receivePort.sendPort,
    );
    receivePort.listen((msg) => _handleCommand(msg as _Command));
  }

  Future<void> stop() async {
    _isolate.kill();
  }

  void detectObjects(Uint8List imageBytes) {
    if (_isReady) {
      _sendPort.send(_Command(_Codes.detect, args: [imageBytes]));
    }
  }

  void _handleCommand(_Command command) {
    switch (command.code) {
      case _Codes.init:
        _sendPort = command.args?[0] as SendPort;
        RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
        _sendPort.send(_Command(
          _Codes.init,
          args: [
            rootIsolateToken,
            interpreter!.address,
            labels!,
          ],
        ));
      case _Codes.ready:
        _isReady = true;
      case _Codes.busy:
        _isReady = false;
      case _Codes.result:
        _isReady = true;
        resultList.add(command.args?[0] as Map<String, dynamic>);
      default:
        log('ObjectDetector unrecognized command: ${command.code}');
    }
  }
}

class _ObjectDetectorService {
  static const double _minConfidence = 0.5;

  Interpreter? _interpreter;
  List<String>? _labels;

  final SendPort _sendPort;

  _ObjectDetectorService(this._sendPort);

  static void _run(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    final _ObjectDetectorService isolate = _ObjectDetectorService(sendPort);

    receivePort.listen((msg) => isolate._handleCommand(msg as _Command));

    sendPort.send(_Command(_Codes.init, args: [receivePort.sendPort]));
  }

  void _handleCommand(_Command command) {
    switch (command.code) {
      case _Codes.init:
        final rootIsolateToken = command.args?[0] as RootIsolateToken;
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

        _interpreter = Interpreter.fromAddress(command.args?[1] as int);
        _labels = command.args?[2] as List<String>;

        _sendPort.send(const _Command(_Codes.ready));
      case _Codes.detect:
        _sendPort.send(const _Command(_Codes.busy));

        _detectObjects(command.args?[0] as Uint8List);
      default:
        log('_ObjectDetectorService unrecognized command: ${command.code}');
    }
  }

  Map<String, dynamic> _detectObjects(Uint8List imageBytes) {
    log('Converting image...');
    var imageConversionStartTime = DateTime.now().millisecondsSinceEpoch;

    // Decoding image
    final decodedImage = img.decodeImage(imageBytes);

    // Resizing image for model, [300, 300]
    final imageInput = img.copyResize(
      decodedImage!,
      width: _modelInputSize,
      height: _modelInputSize,
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

    var imageConversionElapsedTime =
        DateTime.now().millisecondsSinceEpoch - imageConversionStartTime;

    log('Processing image...');
    var inferenceStartTime = DateTime.now().millisecondsSinceEpoch;

    final output = _runInference(imageMatrix);

    log('Processing outputs...');
    // Location
    final locationsRaw = output.first as List<List<double>>;
    final locations = locationsRaw
        .map((list) => list.map((value) => (value * _modelInputSize)).toList())
        .map((rect) => Rect.fromLTRB(rect[1], rect[0], rect[3], rect[2]))
        .toList();
    log('Locations: $locations');

    // Classes
    final classesRaw = output.elementAt(1).first as List<num>;
    final classes = classesRaw.map((value) => value.toInt()).toList();
    log('Classes: $classes');

    // Scores
    final scores = output.elementAt(2).first as List<double>;
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

    log('Generating recognitions...');
    final List<Recognition> recognitions = [];
    for (var i = 0; i < numberOfDetections; i++) {
      if (scores[i] > _minConfidence) {
        recognitions.add(
          Recognition(i, classications[i], scores[i], locations[i]),
        );
      }
    }

    var inferenceElapsedTime =
        DateTime.now().millisecondsSinceEpoch - inferenceStartTime;

    log('Done.');
    var totalElapsedTime =
        DateTime.now().millisecondsSinceEpoch - imageConversionStartTime;

    return {
      "recognitions": recognitions,
      "stats": <String, String>{
        'Conversion time:': imageConversionElapsedTime.toString(),
        'Inference time:': inferenceElapsedTime.toString(),
        'Total prediction time:': totalElapsedTime.toString(),
        'Frame': '${decodedImage.width} X ${decodedImage.height}',
      },
    };
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
