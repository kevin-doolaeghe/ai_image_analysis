@JS()
library main;

import 'package:ai_image_analysis/tflite/web/helpers.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:js/js.dart';
import 'package:js/js_util.dart' as jsutil;

@JS('classifyImage')
external List<dynamic> _classifyImage(ImageData image);

class ImageClassifier {
  Future<String> classifyImage(Uint8List imageBytes) async {
    var image = img.decodeImage(imageBytes);
    if (image == null) return '';

    const width = 300;
    image = img.copyResize(
      image,
      width: width,
      height: (image.height * width) ~/ image.width,
    );

    var predictions = await jsutil.promiseToFuture<List<dynamic>>(
      _classifyImage(
        ImageData(
          data: image.toUint8List(),
          width: image.width,
          height: image.height,
        ),
      ),
    );

    if (predictions.isNotEmpty) {
      var prediction = predictions[0] as ImageClassifierPrediction;
      String probStr = (prediction.probability * 100).toStringAsPrecision(3);
      return '${prediction.item} ($probStr%)';
    }
    return '';
  }
}
