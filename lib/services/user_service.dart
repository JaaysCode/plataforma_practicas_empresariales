import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  static const String _usersCollection = 'users';

  final FirebaseAuth _auth;
  final CollectionReference<Map<String, dynamic>> _usersRef;

  UserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _usersRef = (firestore ?? FirebaseFirestore.instance)
            .collection(_usersCollection);

  Future<UserModel?> getUserData(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc.data()!);
    }

    final query = await _usersRef.where('cc', isEqualTo: userId).limit(1).get();
    if (query.docs.isEmpty) {
      return null;
    }

    return UserModel.fromFirestore(query.docs.first.data());
  }

  Future<UserModel?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return null;
    }

    final credentials = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credentials.user;
    if (user == null) {
      return null;
    }

    final doc = await _usersRef.doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc.data()!);
    }

    final query = await _usersRef.where('email', isEqualTo: email).limit(1).get();
    if (query.docs.isEmpty) {
      return null;
    }

    return UserModel.fromFirestore(query.docs.first.data());
  }
}