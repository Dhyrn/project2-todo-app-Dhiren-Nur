import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadProfilePicture(String imagePath) async {
    try {
      // 1. Get user ID
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // 2. Cria a reference to Storage
      final storageRef = _storage.ref().child('profile_images/$userId.jpg');

      // 3. Cria file from path
      final file = File(imagePath);

      // 4. Upload file
      final uploadTask = await storageRef.putFile(file);

      // 5. Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete profile picture
  Future<bool> deleteProfilePicture() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final storageRef = _storage.ref().child('profile_images/$userId.jpg');

      await storageRef.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  Future<String?> uploadTaskAttachment(String taskId, String filePath) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      final file = File(filePath);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final storageRef = _storage
          .ref()
          .child('task_attachments/$userId/$taskId/$fileName.jpg');

      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading task attachment: $e');
      return null;
    }
  }

}
