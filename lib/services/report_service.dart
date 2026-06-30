import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDashboardStats() async {
    final usersSnap = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .get();

    final activeEmployees = usersSnap.docs.where((d) => d.data()['active'] == true).length;
    final totalEmployees = usersSnap.docs.length;

    final workplacesSnap = await _firestore
        .collection('workplaces')
        .where('active', isEqualTo: true)
        .get();
    final activeWorkplaces = workplacesSnap.docs.length;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final attendanceSnap = await _firestore
        .collection('attendances')
        .where('date', isEqualTo: startOfDay)
        .get();

    int present = 0;
    int absent = totalEmployees;

    for (final doc in attendanceSnap.docs) {
      final status = doc.data()['status'] as String? ?? '';
      if (status == 'checked_in' || status == 'completed') {
        present++;
        absent--;
      }
    }

    final medicalSnap = await _firestore
        .collection('medical_documents')
        .get();

    final employeesWithDocs = medicalSnap.docs
        .map((d) => d.data()['userId'] as String?)
        .where((u) => u != null)
        .toSet()
        .length;

    return {
      'totalEmployees': totalEmployees,
      'activeEmployees': activeEmployees,
      'present': present,
      'absent': absent,
      'activeWorkplaces': activeWorkplaces,
      'employeesWithMedicalDocs': employeesWithDocs,
    };
  }

  Future<Map<String, dynamic>> getEmployeeReport({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final snapshot = await _firestore
        .collection('attendances')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    int attendanceCount = 0;
    double totalHours = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String? ?? '';
      if (status == 'completed') {
        attendanceCount++;
        totalHours += (data['workedHours'] as num?)?.toDouble() ?? 0;
      }
    }

    final totalDays = end.difference(start).inDays + 1;
    final absences = totalDays - attendanceCount;

    return {
      'attendanceCount': attendanceCount,
      'totalHours': totalHours,
      'absences': absences < 0 ? 0 : absences,
      'totalDays': totalDays,
    };
  }

  Future<List<Map<String, dynamic>>> getGeneralReport({
    required DateTime start,
    required DateTime end,
    String? category,
  }) async {
    Query query = _firestore
        .collection('attendances')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end);

    final snapshot = await query.get();

    final attendanceByUser = <String, List<QueryDocumentSnapshot>>{};

    for (final doc in snapshot.docs) {
      final map = doc.data() as Map<String, dynamic>;
      final userId = map['userId'] as String? ?? '';
      attendanceByUser.putIfAbsent(userId, () => []).add(doc);
    }

    final userIds = attendanceByUser.keys.toList();

    final usersMap = <String, Map<String, dynamic>>{};
    if (userIds.isNotEmpty) {
      for (final uid in userIds) {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final data = userDoc.data();
        if (data == null) continue;
        if (category != null && data['category'] != category) continue;
        usersMap[uid] = data;
      }
    }

    final reports = <Map<String, dynamic>>[];
    for (final entry in usersMap.entries) {
      final attendances = attendanceByUser[entry.key]!;
      int attendanceCount = 0;
      double totalHours = 0;

      for (final doc in attendances) {
        final map = doc.data() as Map<String, dynamic>;
        final status = map['status'] as String? ?? '';
        if (status == 'completed') {
          attendanceCount++;
          totalHours += (map['workedHours'] as num?)?.toDouble() ?? 0;
        }
      }

      final totalDays = end.difference(start).inDays + 1;
      final absences = totalDays - attendanceCount;

      reports.add({
        'userId': entry.key,
        'name': '${entry.value['name'] ?? ''} ${entry.value['lastname'] ?? ''}'.trim(),
        'dni': entry.value['dni'] ?? '',
        'category': entry.value['category'] ?? '',
        'attendanceCount': attendanceCount,
        'totalHours': double.parse(totalHours.toStringAsFixed(2)),
        'absences': absences < 0 ? 0 : absences,
      });
    }

    return reports;
  }
}
