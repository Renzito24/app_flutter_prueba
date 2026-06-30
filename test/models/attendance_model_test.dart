import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prueba/models/attendance_model.dart';

void main() {
  group('AttendanceModel', () {
    test('fromMap creates model correctly', () {
      final now = Timestamp.fromDate(DateTime(2025, 6, 7, 8, 0));
      final map = {
        'userId': 'uid1',
        'date': now,
        'checkIn': now,
        'checkOut': Timestamp.fromDate(DateTime(2025, 6, 7, 17, 0)),
        'workedHours': 9.0,
        'latitude': -34.6037,
        'longitude': -58.3816,
        'distanceFromWorkplace': 50.0,
        'status': 'completed',
        'createdAt': now,
      };

      final model = AttendanceModel.fromMap('att1', map);

      expect(model.id, 'att1');
      expect(model.userId, 'uid1');
      expect(model.workedHours, 9.0);
      expect(model.latitude, -34.6037);
      expect(model.longitude, -58.3816);
      expect(model.distanceFromWorkplace, 50.0);
      expect(model.status, 'completed');
    });

    test('fromMap handles null checkOut', () {
      final now = Timestamp.fromDate(DateTime(2025, 6, 7, 8, 0));
      final map = {
        'userId': 'uid1',
        'date': now,
        'checkIn': now,
        'checkOut': null,
        'status': 'checked_in',
        'createdAt': now,
      };

      final model = AttendanceModel.fromMap('att2', map);

      expect(model.status, 'checked_in');
      expect(model.checkOut, null);
      expect(model.workedHours, null);
    });

    test('toMap produces correct map', () {
      final now = DateTime(2025, 6, 7);
      final model = AttendanceModel(
        id: 'att3',
        userId: 'uid2',
        date: now,
        checkIn: now,
        status: 'checked_in',
      );

      final map = model.toMap();

      expect(map['userId'], 'uid2');
      expect(map['status'], 'checked_in');
      expect(map['checkOut'], null);
    });

    test('default status is pending', () {
      final model = AttendanceModel(
        id: 'att4',
        userId: 'uid3',
        date: DateTime(2025, 6, 7),
      );

      expect(model.status, 'pending');
    });
  });
}
