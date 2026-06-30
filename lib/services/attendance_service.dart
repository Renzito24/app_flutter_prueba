import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../models/attendance_model.dart';
import '../models/workplace_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS desactivado. Actívalo para continuar.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permiso de ubicación denegado permanentemente.');
    }

    return await Geolocator.getCurrentPosition();
  }

  double _calculateDistance(
    double lat1, double lon1,
    WorkplaceModel workplace,
  ) {
    return Geolocator.distanceBetween(
      lat1, lon1,
      workplace.latitude, workplace.longitude,
    );
  }

  Future<AttendanceModel> checkIn({
    required String userId,
    required WorkplaceModel workplace,
  }) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final existing = await _firestore
        .collection('attendances')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: startOfDay)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Ya tienes un check-in registrado hoy.');
    }

    final position = await _getCurrentPosition();
    final distance = _calculateDistance(
      position.latitude,
      position.longitude,
      workplace,
    );

    if (distance > workplace.allowedRadius) {
      throw Exception('You are outside the allowed range.');
    }

    final docRef = _firestore.collection('attendances').doc();

    final attendance = AttendanceModel(
      id: docRef.id,
      userId: userId,
      date: startOfDay,
      checkIn: today,
      latitude: position.latitude,
      longitude: position.longitude,
      distanceFromWorkplace: distance,
      status: 'checked_in',
    );

    await docRef.set(attendance.toMap());
    return attendance;
  }

  Future<AttendanceModel> checkOut({
    required String userId,
    required WorkplaceModel workplace,
  }) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final existing = await _firestore
        .collection('attendances')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: startOfDay)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      throw Exception('No tienes un check-in registrado hoy.');
    }

    final doc = existing.docs.first;
    final attendance = AttendanceModel.fromMap(doc.id, doc.data());

    if (attendance.checkOut != null) {
      throw Exception('Ya realizaste el check-out hoy.');
    }

    final position = await _getCurrentPosition();
    final distance = _calculateDistance(
      position.latitude,
      position.longitude,
      workplace,
    );

    if (distance > workplace.allowedRadius) {
      throw Exception('You are outside the allowed range.');
    }

    final checkInTime = attendance.checkIn!;
    final workedHours = today.difference(checkInTime).inMinutes / 60.0;

    await doc.reference.update({
      'checkOut': today,
      'workedHours': workedHours,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'distanceFromWorkplace': distance,
      'status': 'completed',
    });

    return AttendanceModel.fromMap(doc.id, {
      ...doc.data(),
      'checkOut': today,
      'workedHours': workedHours,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'distanceFromWorkplace': distance,
      'status': 'completed',
    });
  }

  Future<AttendanceModel?> getTodayAttendance(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot = await _firestore
        .collection('attendances')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: startOfDay)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return AttendanceModel.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  Stream<List<AttendanceModel>> getAttendanceByUser(String userId) {
    return _firestore
        .collection('attendances')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<AttendanceModel>> getAllAttendances() {
    return _firestore
        .collection('attendances')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<List<AttendanceModel>> getAttendanceByDateRange({
    required DateTime start,
    required DateTime end,
    String? userId,
  }) async {
    Query query = _firestore
        .collection('attendances')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end);

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AttendanceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> getTodayStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot = await _firestore
        .collection('attendances')
        .where('date', isEqualTo: startOfDay)
        .get();

    int checkedIn = 0;
    int completed = 0;

    for (final doc in snapshot.docs) {
      final status = doc.data()['status'] as String? ?? '';
      if (status == 'checked_in' || status == 'completed') {
        checkedIn++;
      }
      if (status == 'completed') {
        completed++;
      }
    }

    return {
      'checkedIn': checkedIn,
      'completed': completed,
    };
  }
}
