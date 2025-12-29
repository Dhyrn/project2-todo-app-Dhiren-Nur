import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    String photoURL = '',
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getOtherUsers(String currentUserId) {
    return _firestore.collection('users').snapshots().map((snapshot) {
      print('USERS DOCS: ${snapshot.docs.length}');
      for (final d in snapshot.docs) {
        print('DOC ID: ${d.id} DATA: ${d.data()}');
      }

      return snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => {
        ...doc.data(),
        'uid': doc.id,
      })
          .toList();
    });
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

  Future<void> shareTaskWithUser(
      String taskId,
      String ownerId,
      String collaboratorId, {
        bool add = true,
      }) async {
    final ownerTaskRef = _firestore
        .collection('users')
        .doc(ownerId)
        .collection('tasks')
        .doc(taskId);

    final collaboratorTaskRef = _firestore
        .collection('users')
        .doc(collaboratorId)
        .collection('tasks')
        .doc(taskId);

    final taskSnap = await ownerTaskRef.get();
    if (!taskSnap.exists) {
      throw Exception('Task não encontrada');
    }

    if (add) {
      final data = taskSnap.data()!;

      await ownerTaskRef.update({
        'collaborators': FieldValue.arrayUnion([collaboratorId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await collaboratorTaskRef.set({
        ...data,
        'collaborators': FieldValue.arrayUnion([ownerId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {

      await ownerTaskRef.update({
        'collaborators': FieldValue.arrayRemove([collaboratorId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });


      final collaboratorTaskSnap = await collaboratorTaskRef.get();
      if (collaboratorTaskSnap.exists) {
        await collaboratorTaskRef.update({
          'collaborators': FieldValue.arrayRemove([ownerId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }


      await collaboratorTaskRef.delete();
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
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
