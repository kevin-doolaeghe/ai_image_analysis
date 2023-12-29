import 'dart:typed_data';

import 'package:ai_image_analysis/pages/home_page.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Center(
        child: Image.network(widget.picture.path, fit: BoxFit.cover),
      ),
      floatingActionButton: (widget.id.isEmpty)
          ? IconButton(
              iconSize: 30,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _addPicture,
            )
          : IconButton(
              iconSize: 30,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deletePicture,
            ),
    );
  }

  Future<void> _addPicture() async {
    Uint8List pictureData = await widget.picture.readAsBytes();
    String pictureContent = String.fromCharCodes(pictureData);

    final ref = FirebaseDatabase.instance.ref('images');
    ref.push().set({
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
}
