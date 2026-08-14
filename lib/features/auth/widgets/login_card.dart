import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/login_controller.dart';
import 'auth_text_field.dart';
import 'remember_me_row.dart';

class LoginCard extends GetView<LoginController> {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Smaller card so it sits in the clear center (not touching corner curves)
    final cardWidth = (size.width * 0.30).clamp(320.0, 380.0);
    final horizontalPad = (size.width * 0.018).clamp(20.0, 32.0);
    final verticalPad = (size.height * 0.022).clamp(18.0, 28.0);
    final titleSize = (size.width * 0.018).clamp(20.0, 24.0);
    final subtitleSize = (size.width * 0.014).clamp(15.0, 18.0);
    final descSize = (size.width * 0.010).clamp(11.0, 13.0);
    final buttonHeight = (size.height * 0.048).clamp(44.0, 50.0);

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
      child: Form(
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
                hint: '••••••••',
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
                  onPressed:
                      controller.isLoading.value ? null : controller.login,
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
          ],
        ),
      ),
    );
  }
}
