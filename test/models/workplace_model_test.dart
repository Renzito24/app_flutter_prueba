import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prueba/models/workplace_model.dart';

void main() {
  group('WorkplaceModel', () {
    test('fromMap creates model correctly', () {
      final map = {
        'name': 'Obra Palermo',
        'address': 'Av. Santa Fe 1234',
        'latitude': -34.5843,
        'longitude': -58.4124,
        'allowedRadius': 100.0,
        'active': true,
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      };

      final model = WorkplaceModel.fromMap('wp1', map);

      expect(model.id, 'wp1');
      expect(model.name, 'Obra Palermo');
      expect(model.address, 'Av. Santa Fe 1234');
      expect(model.latitude, -34.5843);
      expect(model.longitude, -58.4124);
      expect(model.allowedRadius, 100.0);
      expect(model.active, true);
    });

    test('default active is true', () {
      final model = WorkplaceModel(
        id: 'wp2',
        name: 'Test',
        address: 'Addr',
        latitude: 0,
        longitude: 0,
        allowedRadius: 100,
      );

      expect(model.active, true);
    });

    test('toMap produces correct map', () {
      final model = WorkplaceModel(
        id: 'wp3',
        name: 'Oficina Centro',
        address: 'Calle Corrientes 500',
        latitude: -34.6037,
        longitude: -58.3816,
        allowedRadius: 50,
        active: false,
      );

      final map = model.toMap();

      expect(map['name'], 'Oficina Centro');
      expect(map['address'], 'Calle Corrientes 500');
      expect(map['latitude'], -34.6037);
      expect(map['longitude'], -58.3816);
      expect(map['allowedRadius'], 50);
      expect(map['active'], false);
    });
  });
}
