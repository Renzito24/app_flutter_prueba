import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/workplace_model.dart';

class WorkplaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<WorkplaceModel>> getAllWorkplaces() {
    return _firestore.collection('workplaces').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => WorkplaceModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<WorkplaceModel?> getWorkplace(String id) async {
    final doc = await _firestore.collection('workplaces').doc(id).get();
    if (!doc.exists) return null;
    return WorkplaceModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> createWorkplace({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required double allowedRadius,
  }) async {
    final docRef = _firestore.collection('workplaces').doc();

    final workplace = WorkplaceModel(
      id: docRef.id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      allowedRadius: allowedRadius,
    );

    await docRef.set(workplace.toMap());
  }

  Future<void> updateWorkplace(
    String id, {
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required double allowedRadius,
  }) async {
    await _firestore.collection('workplaces').doc(id).update({
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'allowedRadius': allowedRadius,
    });
  }

  Future<void> toggleActive(String id, bool active) async {
    await _firestore.collection('workplaces').doc(id).update({
      'active': active,
    });
  }

  Future<List<WorkplaceModel>> getActiveWorkplaces() async {
    final snapshot = await _firestore
        .collection('workplaces')
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => WorkplaceModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}
