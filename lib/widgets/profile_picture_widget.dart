import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

class ProfilePictureWidget extends StatefulWidget {
  final double radius;

  const ProfilePictureWidget({super.key, this.radius = 60});

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  final ImageService _imageService = ImageService();
  final StorageService _storageService = StorageService();
  final UserService _userService = UserService();
  bool _isUploading = false;


  Future<void> _removeProfilePicture() async {
    setState(() => _isUploading = true);

    try {
      await _storageService.deleteProfilePicture();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _userService.updateUserProfile(
        user.uid,
        {'photoURL': ''},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📸 Fotografia removida')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _showImageSourceDialog({required bool hasPhoto}) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Foto de perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _updateProfilePicture(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmara'),
              onTap: () {
                Navigator.pop(context);
                _updateProfilePicture(ImageSource.camera);
              },
            ),
            if (hasPhoto)
              const Divider(),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remover fotografia',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfilePicture(ImageSource source) async {
    setState(() => _isUploading = true);

    try {
      // 1. Pick image
      final image = source == ImageSource.gallery
          ? await _imageService.pickImageFromGallery()
          : await _imageService.pickImageFromCamera();

      if (image == null) return;

      // 2. Upload to Storage
      final url = await _storageService.uploadProfilePicture(image.path);

      if (url != null) {
        // 3. Save URL to Firestore
        final success = await _userService.updateProfilePicture(url);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto de perfil atualizada!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userService.getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: widget.radius,
            child: const CircularProgressIndicator(),
          );
        }

        String? photoURL;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          photoURL = data?['photoURL'] as String?;
        }
        final hasPhoto = photoURL != null && photoURL.isNotEmpty;

        return Stack(
          children: [
            CircleAvatar(
              radius: widget.radius,
              backgroundColor: Colors.grey[300],
              backgroundImage: photoURL != null && photoURL.isNotEmpty
                  ? NetworkImage(photoURL)
                  : null,
              child: photoURL == null || photoURL.isEmpty
                  ? Icon(Icons.person, size: widget.radius * 0.8, color: Colors.grey[600])
                  : null,
            ),
            if (_isUploading)
              Container(
                width: widget.radius * 2,
                height: widget.radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploading
                    ? null
                    : () => _showImageSourceDialog(hasPhoto: hasPhoto),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
