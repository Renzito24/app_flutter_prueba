class WorkplaceModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double allowedRadius;
  final bool active;
  final DateTime createdAt;

  WorkplaceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.allowedRadius,
    this.active = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WorkplaceModel.fromMap(String id, Map<String, dynamic> data) {
    return WorkplaceModel(
      id: id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      allowedRadius: (data['allowedRadius'] as num?)?.toDouble() ?? 100.0,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as dynamic) != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'allowedRadius': allowedRadius,
      'active': active,
      'createdAt': createdAt,
    };
  }
}
