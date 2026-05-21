import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential =
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final document =
        await _firestore
            .collection('users')
            .doc(uid)
            .get();

    final data = document.data();

    if (data == null) {
      throw Exception(
        'Usuario sin datos en Firestore',
      );
    }

    return UserModel.fromMap(uid, data);
  }
}