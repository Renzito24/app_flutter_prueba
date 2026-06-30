import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/medical_document_model.dart';

class MedicalDocumentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<MedicalDocumentModel> uploadDocument({
    required String userId,
    required String filePath,
    required String fileName,
    required String fileType,
  }) async {
    final storageRef = _storage
        .ref()
        .child('medical_documents/$userId/$fileName');

    await storageRef.putFile(
      Uri.file(filePath).isAbsolute
          ? throw UnimplementedError('Use pickFile for local files')
          : await _getFileFromPath(filePath),
    );

    final fileUrl = await storageRef.getDownloadURL();

    final docRef = _firestore.collection('medical_documents').doc();

    final document = MedicalDocumentModel(
      id: docRef.id,
      userId: userId,
      fileUrl: fileUrl,
      fileType: fileType,
    );

    await docRef.set(document.toMap());
    return document;
  }

  Future<String> uploadAndGetUrl({
    required String userId,
    required String fileName,
    required List<int> bytes,
  }) async {
    final storageRef = _storage
        .ref()
        .child('medical_documents/$userId/$fileName');

    await storageRef.putData(Uint8List.fromList(bytes));
    return await storageRef.getDownloadURL();
  }

  Future<MedicalDocumentModel> saveDocument({
    required String userId,
    required String fileUrl,
    required String fileType,
  }) async {
    final docRef = _firestore.collection('medical_documents').doc();

    final document = MedicalDocumentModel(
      id: docRef.id,
      userId: userId,
      fileUrl: fileUrl,
      fileType: fileType,
    );

    await docRef.set(document.toMap());
    return document;
  }

  Stream<List<MedicalDocumentModel>> getDocumentsByUser(String userId) {
    return _firestore
        .collection('medical_documents')
        .where('userId', isEqualTo: userId)
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalDocumentModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<MedicalDocumentModel>> getAllDocuments() {
    return _firestore
        .collection('medical_documents')
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalDocumentModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> updateStatus(String docId, String status) async {
    await _firestore.collection('medical_documents').doc(docId).update({
      'status': status,
    });
  }

  Future<dynamic> _getFileFromPath(String path) async {
    throw UnimplementedError(
      'Use file_picker or image_picker to get platform-specific file.',
    );
  }
}
