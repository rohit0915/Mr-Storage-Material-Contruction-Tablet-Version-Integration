import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/services/construction_socket_service.dart';
import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../services/auth_service.dart';

enum ForgotPasswordStep { email, otp, newPassword, success }

class LoginController extends GetxController {
  LoginController({AuthService? authService})
    : _authService = authService ?? Get.find<AuthService>();

  final AuthService _authService;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool rememberMe = true.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool inForgotFlow = false.obs;
  final Rx<ForgotPasswordStep> forgotStep = ForgotPasswordStep.email.obs;

  final TextEditingController forgotEmailController = TextEditingController();
  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController retypePasswordController =
      TextEditingController();

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email address';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    try {
      AppLogger.i('Triggering login action in LoginController', tag: 'AUTH');
      final errorMsg = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (errorMsg == null) {
        if (Get.isRegistered<ConstructionSocketService>()) {
          Get.find<ConstructionSocketService>().connect();
        }
        AppToast.showSuccess(
          title: 'Login Successful',
          description: 'Welcome back!',
        );
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        AppToast.showError(title: 'Login Failed', description: errorMsg);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    inForgotFlow.value = true;
    forgotStep.value = ForgotPasswordStep.email;
    forgotEmailController.text = emailController.text.trim();
  }

  void backToLoginCard() {
    inForgotFlow.value = false;
  }

  void continueForgotEmail() {
    final email = forgotEmailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      AppToast.showError(
        title: 'Invalid Email',
        description: 'Please enter a valid email address.',
      );
      return;
    }
    forgotStep.value = ForgotPasswordStep.otp;
  }

  void continueOtp() {
    final otp =
        otp1Controller.text +
        otp2Controller.text +
        otp3Controller.text +
        otp4Controller.text;
    if (otp.length != 4) {
      AppToast.showError(
        title: 'Invalid OTP',
        description: 'Please enter 4 digit OTP.',
      );
      return;
    }
    forgotStep.value = ForgotPasswordStep.newPassword;
  }

  void continueNewPassword() {
    final pass = newPasswordController.text;
    final retype = retypePasswordController.text;
    if (pass.length < 4) {
      AppToast.showError(
        title: 'Weak Password',
        description: 'Password must be at least 4 characters.',
      );
      return;
    }
    if (pass != retype) {
      AppToast.showError(
        title: 'Password Mismatch',
        description: 'New password and retype password must match.',
      );
      return;
    }
    forgotStep.value = ForgotPasswordStep.success;
  }

  void finishForgotFlow() {
    inForgotFlow.value = false;
    forgotStep.value = ForgotPasswordStep.email;
    passwordController.clear();
    newPasswordController.clear();
    retypePasswordController.clear();
    otp1Controller.clear();
    otp2Controller.clear();
    otp3Controller.clear();
    otp4Controller.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    newPasswordController.dispose();
    retypePasswordController.dispose();
    super.onClose();
  }
}
