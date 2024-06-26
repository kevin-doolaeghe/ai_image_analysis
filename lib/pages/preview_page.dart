import 'dart:isolate';
import 'dart:typed_data';

import 'package:ai_image_analysis/pages/home_page.dart';
import 'package:ai_image_analysis/tflite/tflite.dart';
import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({
    super.key,
    required this.id,
    required this.picture,
    required this.timestamp,
  });

  final String id;
  final XFile picture;
  final DateTime timestamp;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late TFLite _tf;
  late Uint8List _pictureData;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _tf = TFLite();
    _initImageData();
  }

  Future<void> _initImageData() async {
    _pictureData = await widget.picture.readAsBytes();
    setState(() {
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: (_isReady)
                  ? Image.memory(
                      _pictureData,
                      fit: BoxFit.scaleDown,
                    )
                  : CircularProgressIndicator(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: (widget.id.isEmpty)
                  ? [
                      IconButton(
                        iconSize: 30,
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                        icon: const Icon(Icons.send),
                        onPressed: _addPicture,
                      )
                    ]
                  : [
                      IconButton(
                        iconSize: 30,
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                        icon: const Icon(Icons.analytics),
                        onPressed: _detectObjects,
                      ),
                      IconButton(
                        iconSize: 30,
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                        icon: const Icon(Icons.delete),
                        onPressed: _deletePicture,
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPicture() async {
    String pictureContent = String.fromCharCodes(_pictureData);

    final ref = FirebaseDatabase.instance.ref('images');
    await ref.push().set({
      'timestamp': widget.timestamp.millisecondsSinceEpoch,
      'content': pictureContent,
    });

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  Future<void> _deletePicture() async {
    if (widget.id.isEmpty) return;

    final ref = FirebaseDatabase.instance.ref('images');
    await ref.child(widget.id).remove();

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  Future<void> _detectObjects() async {
    setState(() {
      _isReady = false;
    });

    // _pictureData = await TFLite().detectObjects(_pictureData);

    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(
      (List<dynamic> args) async {
        SendPort sendPort = args[0];
        TFLite tf = args[1];
        Uint8List pictureData = args[2];

        await Future.delayed(const Duration(seconds: 2));
        final newPictureData = pictureData;
        await tf.detectObjects(pictureData);

        Isolate.exit(sendPort, newPictureData);
      },
      [receivePort.sendPort, _tf, _pictureData],
    );
    _pictureData = await (receivePort.first) as Uint8List;

    setState(() {
      _isReady = true;
    });
  }
}
