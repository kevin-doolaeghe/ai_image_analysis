@JS()
library main;

import 'package:camera/camera.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart' as jsutil;

@JS('classifyImage')
external String _classifyImage(XFile image);

class ImageClassifier {
  Future<String> classifyImage(XFile image) async {
    String category = await jsutil.promiseToFuture<String>(
      _classifyImage(image),
    );
    return category;
  }
}
