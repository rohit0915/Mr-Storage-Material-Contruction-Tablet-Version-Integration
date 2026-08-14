import 'package:get/get.dart';

class AuthService extends GetxService {
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (email.trim().isEmpty || password.isEmpty) {
      return false;
    }

    // Placeholder auth — replace with real API call later.
    return email.contains('@') && password.length >= 4;
  }
}
