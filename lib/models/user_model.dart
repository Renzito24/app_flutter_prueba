class UserModel {
  final String uid;
  final String nombre;
  final String rol;
  final String estado;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.rol,
    required this.estado,
  });

  factory UserModel.fromMap(
    String uid,
    Map<String, dynamic> data,
  ) {
    return UserModel(
      uid: uid,
      nombre: data['nombre'] ?? '',
      rol: data['rol'] ?? '',
      estado: data['estado'] ?? '',
    );
  }
}