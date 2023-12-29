import 'package:ai_image_analysis/pages/preview_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late List<CameraDescription> _cameras;
  late CameraController _controller;
  bool _isRearCameraSelected = true;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      await _setupCamera(_cameras[0]);
    } on Exception catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    try {
      _controller = CameraController(camera, ResolutionPreset.max);
      await _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isReady = true;
        });
      });
    } on CameraException catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || !_controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Stack(children: [
      Positioned.fill(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: CameraPreview(_controller),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.18,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: IconButton(
                    iconSize: 30,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    icon: Icon(
                      _isRearCameraSelected
                          ? CupertinoIcons.switch_camera
                          : CupertinoIcons.switch_camera_solid,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isRearCameraSelected = !_isRearCameraSelected;
                      });
                      _setupCamera(_cameras[_isRearCameraSelected ? 0 : 1]);
                    },
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: IconButton(
                    iconSize: 50,
                    padding: const EdgeInsets.all(12),
                    icon: const Icon(Icons.circle, color: Colors.white),
                    onPressed: _takePicture,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    ]);
  }

  Future<void> _takePicture() async {
    if (!_isReady || !_controller.value.isInitialized) return;
    if (_controller.value.isTakingPicture) return;
    try {
      try {
        await _controller.setFlashMode(FlashMode.off);
      } on CameraException catch (e) {
        debugPrint('Error occured while disabling camera flash mode: $e');
      }
      XFile picture = await _controller.takePicture();

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPage(
            picture: picture,
            timestamp: DateTime.now(),
            id: '',
          ),
        ),
      );
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return;
    }
  }
}
