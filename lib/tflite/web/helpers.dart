@JS()
library main;

import 'dart:typed_data';

import 'package:js/js.dart';

@JS()
@anonymous
class ImageData {
  external Uint8List get data;
  external int get width;
  external int get height;
  external factory ImageData({Uint8List data, int width, int height});
}

@JS()
@anonymous
class ImageClassifierPrediction {
  external String get item;
  external double get probability;
  external factory ImageClassifierPrediction({String item, double probability});
}

@JS()
@anonymous
class ObjectDetectorPrediction {
  external String get item;
  external double get probability;
  external List<double> get coords;
  external factory ObjectDetectorPrediction({
    String item,
    double probability,
    List<double> coords,
  });
}
