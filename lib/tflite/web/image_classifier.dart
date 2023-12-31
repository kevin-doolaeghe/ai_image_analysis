@JS()
library main;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:js/js.dart';
import 'package:js/js_util.dart' as jsutil;

@JS('classifyImage')
external String _classifyImage(Uint8List data, int width, int height);

class ImageClassifier {
  Future<String> classifyImage(XFile image) async {
    final imageData = await image.readAsBytes();
    final decodedImage = img.decodeImage(imageData);
    String category = await jsutil.promiseToFuture<String>(
      _classifyImage(
        decodedImage!.toUint8List(),
        decodedImage.width,
        decodedImage.height,
      ),
    );
    return category;
  }
}
