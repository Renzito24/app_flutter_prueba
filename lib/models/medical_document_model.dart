class MedicalDocumentModel {
  final String id;
  final String userId;
  final String fileUrl;
  final String fileType;
  final DateTime uploadDate;
  final String status;

  MedicalDocumentModel({
    required this.id,
    required this.userId,
    required this.fileUrl,
    required this.fileType,
    DateTime? uploadDate,
    this.status = 'pending',
  }) : uploadDate = uploadDate ?? DateTime.now();

  factory MedicalDocumentModel.fromMap(String id, Map<String, dynamic> data) {
    return MedicalDocumentModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      fileUrl: data['fileUrl'] as String? ?? '',
      fileType: data['fileType'] as String? ?? '',
      uploadDate: (data['uploadDate'] as dynamic)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'uploadDate': uploadDate,
      'status': status,
    };
  }
}
