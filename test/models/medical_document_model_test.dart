import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prueba/models/medical_document_model.dart';

void main() {
  group('MedicalDocumentModel', () {
    test('fromMap creates model correctly', () {
      final map = {
        'userId': 'uid1',
        'fileUrl': 'https://storage.example.com/doc.pdf',
        'fileType': 'pdf',
        'uploadDate': Timestamp.fromDate(DateTime(2025, 6, 1)),
        'status': 'approved',
      };

      final model = MedicalDocumentModel.fromMap('doc1', map);

      expect(model.id, 'doc1');
      expect(model.userId, 'uid1');
      expect(model.fileUrl, 'https://storage.example.com/doc.pdf');
      expect(model.fileType, 'pdf');
      expect(model.status, 'approved');
    });

    test('default status is pending', () {
      final model = MedicalDocumentModel(
        id: 'doc2',
        userId: 'uid2',
        fileUrl: 'https://example.com/file.jpg',
        fileType: 'jpg',
      );

      expect(model.status, 'pending');
    });

    test('toMap produces correct map', () {
      final model = MedicalDocumentModel(
        id: 'doc3',
        userId: 'uid3',
        fileUrl: 'https://example.com/file.png',
        fileType: 'png',
        status: 'rejected',
      );

      final map = model.toMap();

      expect(map['userId'], 'uid3');
      expect(map['fileUrl'], 'https://example.com/file.png');
      expect(map['fileType'], 'png');
      expect(map['status'], 'rejected');
    });
  });
}
