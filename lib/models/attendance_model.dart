class AttendanceModel {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double? workedHours;
  final double? latitude;
  final double? longitude;
  final double? distanceFromWorkplace;
  final String status;
  final DateTime createdAt;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.workedHours,
    this.latitude,
    this.longitude,
    this.distanceFromWorkplace,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AttendanceModel.fromMap(String id, Map<String, dynamic> data) {
    return AttendanceModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      date: (data['date'] as dynamic)?.toDate() ?? DateTime.now(),
      checkIn: (data['checkIn'] as dynamic)?.toDate(),
      checkOut: (data['checkOut'] as dynamic)?.toDate(),
      workedHours: (data['workedHours'] as num?)?.toDouble(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      distanceFromWorkplace: (data['distanceFromWorkplace'] as num?)?.toDouble(),
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'workedHours': workedHours,
      'latitude': latitude,
      'longitude': longitude,
      'distanceFromWorkplace': distanceFromWorkplace,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
