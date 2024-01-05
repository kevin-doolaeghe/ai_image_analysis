@JS()
library main;

import 'dart:typed_data';

import 'package:ai_image_analysis/tflite/web/helpers.dart';
import 'package:image/image.dart' as img;
import 'package:js/js.dart';
import 'package:js/js_util.dart' as jsutil;

@JS('detectObjects')
external List<dynamic> _detectObjects(ImageData image);

class ObjectDetector {
  Future<Uint8List> detectObjects(Uint8List imageBytes) async {
    var image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    var predictions = await jsutil.promiseToFuture<List<dynamic>>(
      _detectObjects(
        ImageData(
          data: image.toUint8List(),
          width: image.width,
          height: image.height,
        ),
      ),
    );

    for (int i = 0; i < predictions.length; i++) {
      var prediction = predictions[i] as ObjectDetectorPrediction;
      if (prediction.probability > 0.50) {
        // Rectangle drawing
        img.drawRect(
          image,
          x1: prediction.coords[0].round(),
          y1: prediction.coords[1].round(),
          x2: (prediction.coords[0] + prediction.coords[2]).round(),
          y2: (prediction.coords[1] + prediction.coords[3]).round(),
          color: img.ColorRgb8(255, 0, 0),
          thickness: 3,
        );
        // Label drawing
        String probStr = (prediction.probability * 100).toStringAsPrecision(3);
        img.drawString(
          image,
          '${prediction.item} $probStr%',
          font: img.arial14,
          x: prediction.coords[0].round() + 4,
          y: prediction.coords[1].round() + 3,
          color: img.ColorRgb8(255, 0, 0),
        );
      }
    }

    return img.encodeJpg(image);
  }
}
