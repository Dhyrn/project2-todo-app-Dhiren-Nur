import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user profile in Firestore
  Future<void> createUserProfile(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  // ✅ NOVO: Lista de utilizadores para dropdown (sem o próprio)
  Stream<List<Map<String, dynamic>>> getOtherUsers(String currentUserId) {
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Get user profile once
  Future<Map<String, dynamic>?> getUserProfileOnce(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Stream de perfil do utilizador autenticado
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // ✅ NOVO: Adicionar/remover colaborador numa task
  Future<void> shareTaskWithUser(String taskId, String ownerId, String collaboratorId, {bool add = true}) async {
    try {
      final taskRef = _firestore.collection('users').doc(ownerId).collection('tasks').doc(taskId);

      if (add) {
        // Adiciona colaborador
        await taskRef.update({
          'collaborators': FieldValue.arrayUnion([collaboratorId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Cria referência na collection do colaborador
        await _firestore.collection('users').doc(collaboratorId).collection('sharedTasks').doc(taskId).set({
          'taskId': taskId,
          'ownerId': ownerId,
          'sharedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Remove colaborador
        await taskRef.update({
          'collaborators': FieldValue.arrayRemove([collaboratorId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Remove referência
        await _firestore.collection('users').doc(collaboratorId).collection('sharedTasks').doc(taskId).delete();
      }
    } catch (e) {
      print('Error sharing task: $e');
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  Future<bool> updateProfilePicture(String downloadUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      await _firestore.collection('users').doc(user.uid).update({'photoURL': downloadUrl});
      return true;
    } catch (e) {
      print('Error updating profile picture: $e');
      return false;
    }
  }
}
