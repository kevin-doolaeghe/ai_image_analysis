import 'dart:io';
import 'dart:typed_data';

import 'package:ai_image_analysis/pages/camera_page.dart';
import 'package:ai_image_analysis/pages/preview_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FirebaseAnimatedList(
        query: FirebaseDatabase.instance.ref('images'),
        itemBuilder: (
          BuildContext context,
          DataSnapshot snapshot,
          Animation<double> animation,
          int index,
        ) {
          dynamic data = snapshot.value;
          Uint8List pictureData = Uint8List.fromList(
            data['content'].toString().codeUnits,
          );
          DateTime dt = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
          String timestamp = dt.toLocal().toIso8601String();
          String size = (pictureData.lengthInBytes / 1024).ceil().toString();

          return Padding(
            padding: EdgeInsets.all(12),
            child: ListTile(
              tileColor: Theme.of(context).dialogBackgroundColor,
              contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              leading: SizedBox(
                width: MediaQuery.of(context).size.width * 0.08,
                child: Center(
                  child: Image.memory(
                    pictureData,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text('$timestamp - $size kB'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewPage(
                      id: snapshot.key ?? '',
                      picture: XFile.fromData(pictureData),
                      timestamp: dt,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            iconSize: 30,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _uploadPicture,
          ),
          IconButton(
            iconSize: 30,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            icon: const Icon(Icons.photo_camera),
            onPressed: _takePicture,
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPicture() async {
    try {
      final selectedPicture = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (selectedPicture == null) return;

      final timestamp = await selectedPicture.lastModified();

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPage(
            id: '',
            picture: selectedPicture,
            timestamp: timestamp,
          ),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  void _takePicture() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraPage(),
      ),
    );
  }
}
