@JS()
library main;

import 'dart:typed_data';

import 'package:ai_image_analysis/tflite/web/image_data.dart';
import 'package:image/image.dart' as img;
import 'package:js/js.dart';
import 'package:js/js_util.dart' as jsutil;

@JS('detectObjects')
external Uint8List _detectObjects(ImageData image);

class ObjectDetector {
  Future<Uint8List> detectObjects(Uint8List imageBytes) async {
    var image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    // image = img.copyResize(image, width: 300, height: 300);

    Uint8List imageData = await jsutil.promiseToFuture<Uint8List>(
      _detectObjects(
        ImageData(
          data: img.encodeJpg(image),
          width: image.width,
          height: image.height,
        ),
      ),
    );

    return imageData;
  }
}
