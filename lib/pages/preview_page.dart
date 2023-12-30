import 'dart:typed_data';

import 'package:ai_image_analysis/pages/home_page.dart';
// import 'package:ai_image_analysis/tflite/object_detection.dart';
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
  late Uint8List _pictureData;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
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
                        icon: const Icon(Icons.upload_file),
                        onPressed: _analyzePicture,
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

  Future<void> _analyzePicture() async {
    /*
    final objectDetection = ObjectDetection();
    final imageData = await objectDetection.processImage(widget.picture);

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewPage(
          id: '',
          picture: XFile.fromData(imageData),
          timestamp: DateTime.now(),
        ),
      ),
    );
    */
  }
}
