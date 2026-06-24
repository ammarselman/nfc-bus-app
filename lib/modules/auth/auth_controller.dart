import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/session_service.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository repo;
  final SessionService session;
  AuthController(this.repo, this.session);

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final loading = false.obs;
  final showPass = false.obs;

  String? emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    if (!ok) return 'Invalid email format';
    return null;
  }

  String? passValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 4) return 'Password is too short';
    return null;
  }

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    loading.value = true;
    try {
      final res = await repo.login(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );

      if (res['ok'] == true) {
        print(res);
        final user = (res['user'] ?? {}) as Map<String, dynamic>;
        final token = (res['token'])?.toString() ?? '';
        if (user.isEmpty) {
          throw Exception('Empty user object from server');
        }
        print(user);
        print(token);
        await session.saveSession(user, tokenValue: token);

        final role = (user['role'] ?? '').toString().toLowerCase();
        if (role == 'driver') {
          Get.offAllNamed(Routes.driverHome);
        } else {
          Get.offAllNamed(Routes.parentHome);
        }
      } else {
        final msg = res['message']?.toString() ?? 'Invalid credentials';
        Get.snackbar('Login', msg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }
}
