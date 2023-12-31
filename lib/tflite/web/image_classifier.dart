@JS()
library main;

import 'package:ai_image_analysis/tflite/web/image_data.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:js/js.dart';
import 'package:js/js_util.dart' as jsutil;

@JS('classifyImage')
external String _classifyImage(ImageData image);

class ImageClassifier {
  Future<String> classifyImage(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return '';

    String category = await jsutil.promiseToFuture<String>(
      _classifyImage(
        ImageData(
          data: image.toUint8List(),
          width: image.width,
          height: image.height,
        ),
      ),
    );

    return category;
  }
}
