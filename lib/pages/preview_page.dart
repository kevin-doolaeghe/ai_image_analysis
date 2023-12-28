import 'dart:typed_data';

import 'package:ai_image_analysis/firebase/firebase_database.dart';
import 'package:ai_image_analysis/pages/home_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({super.key, required this.picture});

  final XFile picture;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late Database _database;

  @override
  void initState() {
    super.initState();
    _database = Database();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Center(
        child: Image.network(widget.picture.path, fit: BoxFit.cover),
      ),
      floatingActionButton: IconButton(
        iconSize: 30,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        icon: const Icon(Icons.send, color: Colors.white),
        onPressed: addPicture,
      ),
    );
  }

  Future<void> addPicture() async {
    Uint8List pictureData = await widget.picture.readAsBytes();
    String pictureContent = String.fromCharCodes(pictureData);
    await _database.create('images/2', {
      'title': 'Image 02',
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
}
