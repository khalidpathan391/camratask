// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }

    final XFile image = await _cameraController.takePicture();

    setState(() {
      _capturedImage = File(image.path);
    });
  }

  Future<void> _selectPicture() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _capturedImage = File(pickedImage.path);
      });
    }
  }

  void _handleSwipeLeft() {
    // Handle swipe left gesture
    print('Swiped left');
  }

  void _handleSwipeRight() {
    // Handle swipe right gesture
    print('Swiped right');
  }

  void _handleSlideUp() {
    // Handle slide up gesture
    print('Slid up');
  }

  void _handleSlideDown() {
    // Handle slide down gesture
    print('Slid down');
  }

  void _handleSearch(String query) {
    // Handle search with the provided query
    print('Search: $query');
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Camera App')),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! < 0) {
            _handleSwipeLeft();
          } else if (details.primaryVelocity! > 0) {
            _handleSwipeRight();
          }
        },
        onVerticalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! < 0) {
            _handleSlideUp();
          } else if (details.primaryVelocity! > 0) {
            _handleSlideDown();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: _cameraController.value.aspectRatio,
                child: CameraPreview(_cameraController),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _takePicture,
                  child: const Icon(Icons.camera),
                ),
                ElevatedButton(
                  onPressed: _selectPicture,
                  child: const Icon(Icons.image),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Search'),
                          content: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Enter search query',
                            ),
                            onSubmitted: _handleSearch,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                const query = 'Get text from TextField';
                                _handleSearch(query);
                                Navigator.pop(context);
                              },
                              child: const Text('Search'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            if (_capturedImage != null)
              Expanded(
                child: Image.file(
                  _capturedImage!,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
