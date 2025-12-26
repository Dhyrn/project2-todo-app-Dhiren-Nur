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
      // stream vazia
      return const Stream.empty();
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // Update user profile generic
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // Helper específico para foto de perfil
  Future<bool> updateProfilePicture(String downloadUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'photoURL': downloadUrl});
      return true;
    } catch (e) {
      print('Error updating profile picture: $e');
      return false;
    }
  }
}
