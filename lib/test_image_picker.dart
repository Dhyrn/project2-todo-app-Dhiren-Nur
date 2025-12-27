import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project1/services/storage_service.dart';
import 'package:project1/services/user_service.dart';
import 'services/image_service.dart';

class TestImagePicker extends StatefulWidget {
  @override
  _TestImagePickerState createState() => _TestImagePickerState();
}

class _TestImagePickerState extends State<TestImagePicker> {
  XFile? _selectedImage;
  final ImageService _imageService = ImageService();

  Future<void> _pickImage() async {
    final image = await _imageService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  final StorageService storageService = StorageService();
  bool _isUploading = false;

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    final url = await storageService.uploadProfilePicture(_selectedImage!.path);

    setState(() => _isUploading = false);

    if (url != null) {
      await _saveToFirestore(url);
      print('Image uploaded! URL: $url');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed')),
      );
    }
  }

  final UserService userService = UserService();

  Future<void> _saveToFirestore(String url) async {
    final success = await userService.updateProfilePicture(url);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL saved to Firestore!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test Picker")),
      body: Column(
        children: [
          if (_selectedImage != null)
            Image.file(
              File(_selectedImage!.path),
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 200,
              width: 200,
              color: Colors.grey[300],
              child: Icon(Icons.person, size: 100),
            ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image'),
          ),
          ElevatedButton(
            onPressed: _uploadImage,
            child: Text('Upload to Firebase'),
          ),
        ],
      ),
    );
  }
}
