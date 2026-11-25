import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/services/construction_socket_service.dart';
import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../../../app/services/api_client.dart';
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
  final RxBool isForgotLoading = false.obs;
  final RxBool inForgotFlow = false.obs;
  final Rx<ForgotPasswordStep> forgotStep = ForgotPasswordStep.email.obs;

  final TextEditingController forgotEmailController = TextEditingController();
  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController retypePasswordController =
      TextEditingController();

  String? _resetToken;

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    if (Get.isRegistered<ApiClient>()) {
      final apiClient = Get.find<ApiClient>();
      final creds = apiClient.getSavedLoginCredentials();
      if (creds != null) {
        emailController.text = creds['email'] ?? '';
        passwordController.text = creds['password'] ?? '';
        rememberMe.value = true;
      } else {
        rememberMe.value = false;
      }
    }
  }

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
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final errorMsg = await _authService.login(
        email: email,
        password: password,
      );

      if (errorMsg == null) {
        if (Get.isRegistered<ApiClient>()) {
          final apiClient = Get.find<ApiClient>();
          if (rememberMe.value) {
            await apiClient.saveLoginCredentials(email, password);
          } else {
            await apiClient.clearLoginCredentials();
          }
        }

        if (Get.isRegistered<ConstructionSocketService>()) {
          Get.find<ConstructionSocketService>().connect();
        }
        AppToast.showSuccess(
          title: 'Login Successful',
          description: 'Welcome back!',
        );
        Get.offAllNamed(AppRoutes.dashboard, arguments: {'fromLogin': true});
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

  Future<void> continueForgotEmail() async {
    final email = forgotEmailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      AppToast.showError(
        title: 'Invalid Email',
        description: 'Please enter a valid email address.',
      );
      return;
    }

    isForgotLoading.value = true;
    try {
      final err = await _authService.forgotPassword(email);
      if (err == null) {
        AppToast.showSuccess(
          title: 'OTP Sent',
          description: 'A 6-digit verification code has been sent to $email.',
        );
        forgotStep.value = ForgotPasswordStep.otp;
      } else {
        AppToast.showError(
          title: 'Request Failed',
          description: err,
        );
      }
    } finally {
      isForgotLoading.value = false;
    }
  }

  Future<void> resendForgotOtp() async {
    final email = forgotEmailController.text.trim();
    if (email.isEmpty) return;

    isForgotLoading.value = true;
    try {
      final err = await _authService.forgotPassword(email);
      if (err == null) {
        AppToast.showSuccess(
          title: 'OTP Resent',
          description: 'A new 6-digit verification code has been sent.',
        );
      } else {
        AppToast.showError(title: 'Resend Failed', description: err);
      }
    } finally {
      isForgotLoading.value = false;
    }
  }

  Future<void> continueOtp() async {
    final otp = otp1Controller.text.trim() +
        otp2Controller.text.trim() +
        otp3Controller.text.trim() +
        otp4Controller.text.trim() +
        otp5Controller.text.trim() +
        otp6Controller.text.trim();

    if (otp.length != 6) {
      AppToast.showError(
        title: 'Invalid OTP',
        description: 'Please enter the complete 6-digit OTP.',
      );
      return;
    }

    final email = forgotEmailController.text.trim();
    isForgotLoading.value = true;
    try {
      final result = await _authService.verifyOtp(email: email, otp: otp);
      if (result.error == null) {
        _resetToken = result.resetToken;
        AppToast.showSuccess(
          title: 'OTP Verified',
          description: 'Please enter your new password.',
        );
        forgotStep.value = ForgotPasswordStep.newPassword;
      } else {
        AppToast.showError(
          title: 'Verification Failed',
          description: result.error!,
        );
      }
    } finally {
      isForgotLoading.value = false;
    }
  }

  Future<void> continueNewPassword() async {
    final pass = newPasswordController.text;
    final retype = retypePasswordController.text;
    if (pass.length < 6) {
      AppToast.showError(
        title: 'Weak Password',
        description: 'Password must be at least 6 characters.',
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

    if (_resetToken == null || _resetToken!.isEmpty) {
      AppToast.showError(
        title: 'Session Expired',
        description: 'Verification session expired. Please verify OTP again.',
      );
      forgotStep.value = ForgotPasswordStep.otp;
      return;
    }

    isForgotLoading.value = true;
    try {
      final err = await _authService.resetPassword(
        resetToken: _resetToken!,
        newPassword: pass,
      );
      if (err == null) {
        forgotStep.value = ForgotPasswordStep.success;
      } else {
        AppToast.showError(
          title: 'Reset Failed',
          description: err,
        );
      }
    } finally {
      isForgotLoading.value = false;
    }
  }

  void finishForgotFlow() {
    inForgotFlow.value = false;
    forgotStep.value = ForgotPasswordStep.email;
    _resetToken = null;
    passwordController.clear();
    newPasswordController.clear();
    retypePasswordController.clear();
    otp1Controller.clear();
    otp2Controller.clear();
    otp3Controller.clear();
    otp4Controller.clear();
    otp5Controller.clear();
    otp6Controller.clear();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
