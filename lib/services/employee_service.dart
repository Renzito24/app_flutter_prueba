import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getAllEmployees() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<List<UserModel>> getActiveEmployees() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> updateEmployee(
    String uid, {
    required String name,
    required String lastname,
    required String dni,
    required String email,
    required String phone,
    required String address,
    required String category,
    String? workplaceId,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'lastname': lastname,
      'dni': dni,
      'email': email,
      'phone': phone,
      'address': address,
      'category': category,
      'workplaceId': workplaceId,
    });
  }

  Future<void> toggleActive(String uid, bool active) async {
    await _firestore.collection('users').doc(uid).update({
      'active': active,
    });
  }

  Future<List<UserModel>> searchEmployees(String query) async {
    if (query.isEmpty) return [];

    final nameSnap = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    final lastnameSnap = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .where('lastname', isGreaterThanOrEqualTo: query)
        .where('lastname', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    final results = <UserModel>{};
    for (final doc in nameSnap.docs) {
      results.add(UserModel.fromMap(doc.id, doc.data()));
    }
    for (final doc in lastnameSnap.docs) {
      results.add(UserModel.fromMap(doc.id, doc.data()));
    }

    return results.toList();
  }

  Future<List<UserModel>> filterByWorkplace(String workplaceId) async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .where('workplaceId', isEqualTo: workplaceId)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}
