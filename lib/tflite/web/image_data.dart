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
