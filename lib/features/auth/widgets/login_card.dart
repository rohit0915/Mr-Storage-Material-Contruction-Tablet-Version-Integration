import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_log_dialog.dart';
import '../controllers/login_controller.dart';
import 'auth_text_field.dart';
import 'remember_me_row.dart';

class LoginCard extends GetView<LoginController> {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardWidth = (size.width * 0.30).clamp(340.0, 420.0);
    final horizontalPad = (size.width * 0.018).clamp(20.0, 32.0);
    final verticalPad = (size.height * 0.022).clamp(18.0, 28.0);

    return Obx(() {
      return Container(
        width: cardWidth,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPad,
          vertical: verticalPad,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: controller.inForgotFlow.value
            ? _ForgotPasswordFlow(controller: controller)
            : _LoginForm(controller: controller),
      );
    });
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.018).clamp(20.0, 24.0);
    final subtitleSize = (size.width * 0.014).clamp(15.0, 18.0);
    final descSize = (size.width * 0.010).clamp(11.0, 13.0);
    final buttonHeight = (size.height * 0.048).clamp(44.0, 50.0);

    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sign In',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: size.height * 0.004),
          Text(
            'Construction App',
            style: TextStyle(
              fontSize: subtitleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: size.height * 0.008),
          Text(
            'Please enter below details to access the dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: descSize,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          AuthTextField(
            label: 'Email Address',
            hint: 'Enter Email Address',
            controller: controller.emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
          ),
          SizedBox(height: size.height * 0.014),
          Obx(
            () => AuthTextField(
              label: 'Password',
              hint: 'Enter Password',
              controller: controller.passwordController,
              prefixIcon: Icons.lock_outline,
              obscureText: controller.obscurePassword.value,
              validator: controller.validatePassword,
              suffixIcon: IconButton(
                onPressed: controller.togglePasswordVisibility,
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.012),
          const RememberMeRow(),
          SizedBox(height: size.height * 0.02),
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.loginButton,
                  disabledBackgroundColor:
                      AppColors.loginButton.withValues(alpha: 0.6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Login',
                        style: TextStyle(
                          fontSize: (size.width * 0.012).clamp(14.0, 16.0),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.008),
          TextButton.icon(
            onPressed: () => AppLogDialog.show(context),
            icon: const Icon(Icons.bug_report_outlined, size: 16, color: AppColors.textSecondary),
            label: const Text(
              'View & Copy Debug Logs',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordFlow extends StatelessWidget {
  const _ForgotPasswordFlow({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = controller.forgotStep.value;
      return switch (step) {
        ForgotPasswordStep.email => _ForgotEmailStep(controller: controller),
        ForgotPasswordStep.otp => _OtpStep(controller: controller),
        ForgotPasswordStep.newPassword =>
          _NewPasswordStep(controller: controller),
        ForgotPasswordStep.success =>
          _ForgotSuccessStep(controller: controller),
      };
    });
  }
}

class _ForgotEmailStep extends StatelessWidget {
  const _ForgotEmailStep({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.018).clamp(20.0, 24.0);
    final descSize = (size.width * 0.010).clamp(11.0, 13.0);
    final buttonHeight = (size.height * 0.048).clamp(44.0, 50.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _BackLink(onTap: controller.backToLoginCard),
          ],
        ),
        SizedBox(height: size.height * 0.006),
        Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          'Enter your registered email address to receive a verification code.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: descSize,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        AuthTextField(
          label: 'Email Address',
          hint: 'Enter your email address',
          controller: controller.forgotEmailController,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: controller.validateEmail,
        ),
        SizedBox(height: size.height * 0.02),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: controller.continueForgotEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.loginButton,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Send Code',
              style: TextStyle(
                fontSize: (size.width * 0.012).clamp(14.0, 16.0),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpStep extends StatelessWidget {
  const _OtpStep({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.018).clamp(20.0, 24.0);
    final descSize = (size.width * 0.010).clamp(11.0, 13.0);
    final buttonHeight = (size.height * 0.048).clamp(44.0, 50.0);
    const gap = 10.0;

    Widget otpBox(TextEditingController ctrl, {VoidCallback? onFilled}) {
      return SizedBox(
        height: 52,
        child: TextField(
          controller: ctrl,
          maxLength: 1,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: (size.width * 0.014).clamp(16.0, 20.0),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
            ),
          ),
          onChanged: (v) {
            if (v.length == 1) {
              onFilled?.call();
            }
          },
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _BackLink(onTap: controller.backToLoginCard),
          ],
        ),
        SizedBox(height: size.height * 0.006),
        Text(
          'Verify Code',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          'We sent a 4-digit verification code to\n${controller.forgotEmailController.text.trim()}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: descSize,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Row(
          children: [
            Expanded(
              child: otpBox(
                controller.otp1Controller,
                onFilled: () => FocusScope.of(context).nextFocus(),
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              child: otpBox(
                controller.otp2Controller,
                onFilled: () => FocusScope.of(context).nextFocus(),
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              child: otpBox(
                controller.otp3Controller,
                onFilled: () => FocusScope.of(context).nextFocus(),
              ),
            ),
            const SizedBox(width: gap),
            Expanded(child: otpBox(controller.otp4Controller)),
          ],
        ),
        SizedBox(height: size.height * 0.02),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: controller.continueOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.loginButton,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Verify Code',
              style: TextStyle(
                fontSize: (size.width * 0.012).clamp(14.0, 16.0),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewPasswordStep extends StatelessWidget {
  const _NewPasswordStep({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.018).clamp(20.0, 24.0);
    final descSize = (size.width * 0.010).clamp(11.0, 13.0);
    final buttonHeight = (size.height * 0.048).clamp(44.0, 50.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _BackLink(onTap: controller.backToLoginCard),
          ],
        ),
        SizedBox(height: size.height * 0.006),
        Text(
          'New Password',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          'Please enter and confirm your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: descSize,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        AuthTextField(
          label: 'New Password',
          hint: 'Enter new password',
          controller: controller.newPasswordController,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        SizedBox(height: size.height * 0.014),
        AuthTextField(
          label: 'Confirm Password',
          hint: 'Re-enter new password',
          controller: controller.retypePasswordController,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        SizedBox(height: size.height * 0.02),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: controller.continueNewPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.loginButton,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Reset Password',
              style: TextStyle(
                fontSize: (size.width * 0.012).clamp(14.0, 16.0),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ForgotSuccessStep extends StatelessWidget {
  const _ForgotSuccessStep({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.018).clamp(20.0, 24.0);
    final descSize = (size.width * 0.010).clamp(11.0, 13.0);
    final buttonHeight = (size.height * 0.048).clamp(44.0, 50.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.softGreenBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.badgeGreen,
            size: 38,
          ),
        ),
        SizedBox(height: size.height * 0.014),
        Text(
          'Password Reset Done',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          'Your password has been updated successfully. You can now login with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: descSize,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: controller.finishForgotFlow,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.loginButton,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Back to Login',
              style: TextStyle(
                fontSize: (size.width * 0.012).clamp(14.0, 16.0),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackLink extends StatelessWidget {
  const _BackLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 4),
            Text(
              'Back to Sign In',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

