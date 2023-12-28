import 'dart:typed_data';

import 'package:ai_image_analysis/firebase/firebase_database.dart';
import 'package:ai_image_analysis/pages/camera_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Database _database;
  late dynamic _images;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _database = Database();
    fetchImages();
  }

  Future<void> fetchImages() async {
    _images = await _database.read('images');
    debugPrint('HomePage.fetchImages: $_images');
    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_isReady)
          ? Padding(
              padding: EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor: Theme.of(context).secondaryHeaderColor,
                    contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    leading: Image.memory(
                      Uint8List.fromList(
                        _images['2']['content'].toString().codeUnits,
                      ),
                    ),
                    title: Text(_images['2']['title']),
                  );
                },
              ),
            )
          : Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
      floatingActionButton: IconButton(
        iconSize: 30,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: takePicture,
      ),
    );
  }

  void takePicture() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraPage(),
      ),
    );
  }
}
