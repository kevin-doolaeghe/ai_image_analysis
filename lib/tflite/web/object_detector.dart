@JS()
library main;

import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart' as jsutil;

@JS('detectObjects')
external Uint8List _detectObjects(Uint8List image);

class ObjectDetector {
  Future<Uint8List> detectObjects(XFile image) async {
    Uint8List imageData = await jsutil.promiseToFuture<Uint8List>(
      _detectObjects(await image.readAsBytes()),
    );
    return imageData;
  }
}
