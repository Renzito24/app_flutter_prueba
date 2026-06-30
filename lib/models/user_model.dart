class UserModel {
  final String uid;
  final String name;
  final String lastname;
  final String dni;
  final String email;
  final String phone;
  final String address;
  final String category;
  final String? workplaceId;
  final String role;
  final bool active;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.lastname,
    required this.dni,
    required this.email,
    this.phone = '',
    this.address = '',
    this.category = '',
    this.workplaceId,
    required this.role,
    this.active = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get fullName => '$name $lastname';

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] as String? ?? '',
      lastname: data['lastname'] as String? ?? '',
      dni: data['dni'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      category: data['category'] as String? ?? '',
      workplaceId: data['workplaceId'] as String?,
      role: data['role'] as String? ?? 'employee',
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as dynamic) != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastname': lastname,
      'dni': dni,
      'email': email,
      'phone': phone,
      'address': address,
      'category': category,
      'workplaceId': workplaceId,
      'role': role,
      'active': active,
      'createdAt': createdAt,
    };
  }
}
