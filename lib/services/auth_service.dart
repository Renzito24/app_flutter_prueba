import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    return _getUserFromFirestore(uid);
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String lastname,
    required String dni,
    required String phone,
    required String address,
    required String category,
    String? workplaceId,
    String role = 'employee',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final user = UserModel(
      uid: uid,
      name: name,
      lastname: lastname,
      dni: dni,
      email: email,
      phone: phone,
      address: address,
      category: category,
      workplaceId: workplaceId,
      role: role,
      active: true,
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());

    return user;
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Future<UserModel> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');
    return _getUserFromFirestore(user.uid);
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final document = await _firestore.collection('users').doc(uid).get();

    final data = document.data();
    if (data == null) {
      throw Exception('Usuario sin datos en Firestore');
    }

    return UserModel.fromMap(uid, data);
  }
}
