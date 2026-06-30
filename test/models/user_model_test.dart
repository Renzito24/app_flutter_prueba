import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prueba/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromMap creates model correctly', () {
      final map = {
        'name': 'Juan',
        'lastname': 'Perez',
        'dni': '40111222',
        'email': 'juan@test.com',
        'phone': '123456789',
        'address': 'Calle 123',
        'category': 'Construccion',
        'workplaceId': 'wp1',
        'role': 'employee',
        'active': true,
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      };

      final model = UserModel.fromMap('uid1', map);

      expect(model.uid, 'uid1');
      expect(model.name, 'Juan');
      expect(model.lastname, 'Perez');
      expect(model.dni, '40111222');
      expect(model.email, 'juan@test.com');
      expect(model.phone, '123456789');
      expect(model.address, 'Calle 123');
      expect(model.category, 'Construccion');
      expect(model.workplaceId, 'wp1');
      expect(model.role, 'employee');
      expect(model.active, true);
    });

    test('fromMap handles null values', () {
      final map = <String, dynamic>{
        'name': null,
        'lastname': null,
      };

      final model = UserModel.fromMap('uid2', map);

      expect(model.name, '');
      expect(model.lastname, '');
      expect(model.dni, '');
      expect(model.phone, '');
      expect(model.address, '');
      expect(model.category, '');
      expect(model.workplaceId, null);
      expect(model.role, 'employee');
      expect(model.active, true);
    });

    test('toMap produces correct map', () {
      final model = UserModel(
        uid: 'uid3',
        name: 'Ana',
        lastname: 'Garcia',
        dni: '12345678',
        email: 'ana@test.com',
        phone: '987654321',
        address: 'Av. Siempre Viva',
        category: 'Administrativo',
        workplaceId: 'wp2',
        role: 'admin',
      );

      final map = model.toMap();

      expect(map['name'], 'Ana');
      expect(map['lastname'], 'Garcia');
      expect(map['dni'], '12345678');
      expect(map['email'], 'ana@test.com');
      expect(map['phone'], '987654321');
      expect(map['address'], 'Av. Siempre Viva');
      expect(map['category'], 'Administrativo');
      expect(map['workplaceId'], 'wp2');
      expect(map['role'], 'admin');
      expect(map['active'], true);
    });

    test('fullName getter works', () {
      final model = UserModel(
        uid: 'uid4',
        name: 'Carlos',
        lastname: 'Lopez',
        dni: '87654321',
        email: 'carlos@test.com',
        role: 'employee',
      );

      expect(model.fullName, 'Carlos Lopez');
    });
  });
}
