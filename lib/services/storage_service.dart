import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadProfilePicture(String imagePath) async {
    try {
      // 1. Verificar user autenticado
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Erro: Nenhum user autenticado');
        return null;
      }

      // 2. Verificar se ficheiro existe
      final file = File(imagePath);
      if (!await file.exists()) {
        print('Erro: Ficheiro não existe: $imagePath');
        return null;
      }

      print('Upload para: profile_images/$userId.jpg');

      // 3. Nova API: putFile direto retorna URL se sucesso
      final storageRef = _storage.ref().child('profile_images/$userId.jpg');

      // Upload com tratamento de erro
      final uploadTask = storageRef.putFile(file);

      // Aguarda conclusão
      final snapshot = await uploadTask;

      // Verifica estado
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await storageRef.getDownloadURL();
        print('Upload OK! URL: $downloadUrl');
        return downloadUrl;
      } else {
        print('Upload falhou: ${snapshot.state}');
        return null;
      }
    } catch (e) {
      print('Erro upload: $e');
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

      if (!await file.exists()) {
        print('Erro: Ficheiro não existe: $filePath');
        return null;
      }

      final extension = path
          .extension(file.path)
          .replaceFirst('.', '')
          .toLowerCase();

      final fileName =
          '${DateTime
          .now()
          .millisecondsSinceEpoch}.$extension';

      final storageRef = _storage
          .ref()
          .child('task_attachments/$userId/$taskId/$fileName');

      final snapshot = await storageRef.putFile(
        file,
        SettableMetadata(
          contentType: 'image/$extension',
        ),
      );

      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      }

      return null;
    } catch (e) {
      print('Error uploading task attachment: $e');
      return null;
    }
  }
}
