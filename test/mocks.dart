import 'package:flutter/foundation.dart';
import 'package:app_prueba/models/user_model.dart';
import 'package:app_prueba/providers/auth_provider.dart';
import 'package:app_prueba/services/auth_service.dart';

class FakeAuthService extends AuthService {
  FakeAuthService();

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    return UserModel(
      uid: 'test-uid',
      name: 'Test',
      lastname: 'User',
      dni: '12345678',
      email: email,
      role: 'employee',
    );
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {}
}

class MockAuthProvider extends AuthProvider {
  MockAuthProvider({
    this.mockUser,
    this.mockLoading = false,
    this.mockError,
  }) : super(authService: FakeAuthService());

  final UserModel? mockUser;
  final bool mockLoading;
  final String? mockError;

  bool loginCalled = false;

  @override
  UserModel? get user => mockUser;

  @override
  bool get loading => mockLoading;

  @override
  String? get error => mockError;

  @override
  Future<void> login(String email, String password) async {
    loginCalled = true;
    if (mockError != null) return;
    notifyListeners();
  }
}
