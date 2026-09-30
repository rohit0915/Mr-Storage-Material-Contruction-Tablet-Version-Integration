import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../widgets/settings_dialog.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final gap = size.height * 0.014;
    final titleSize = (size.width * 0.018).clamp(20.0, 26.0);
    final subSize = (size.width * 0.010).clamp(11.0, 13.0);

    return AppScaffold(
      menuTitle: 'My Profile',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, size.height * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Title Row with Settings Button matching Image 3
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.004),
                      Text(
                        'Update your personal information and security settings',
                        style: TextStyle(
                          fontSize: subSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => SettingsDialog.show(context),
                  icon: const Icon(Icons.settings_outlined, size: 16),
                  label: const Text(
                    'Settings',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap * 1.2),

            // 2-Column Main Cards Layout matching Image 3
            LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > 700;
                final leftCard = _BasicInfoCard(
                  controller: controller,
                  fontSize: subSize,
                );
                final rightCard = _SecuritySettingsCard(
                  controller: controller,
                  fontSize: subSize,
                );

                if (isLandscape) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: leftCard),
                      const SizedBox(width: 20),
                      Expanded(child: rightCard),
                    ],
                  );
                }

                return Column(
                  children: [leftCard, const SizedBox(height: 20), rightCard],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Left Card: Basic Information ─────────────────────────────────────────────

class _BasicInfoCard extends StatelessWidget {
  const _BasicInfoCard({required this.controller, required this.fontSize});
  final ProfileController controller;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Avatar Image with Camera Overlay Icon
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFE2E8F0),
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'JPG, PNG or GIF, Max size 2MB.',
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input 1: Full Name
          _fieldLabel('Full Name'),
          const SizedBox(height: 6),
          _inputField(
            controller.fullNameController,
            'Enter full name',
            fontSize,
          ),
          const SizedBox(height: 16),

          // Input 2: Email Address
          _fieldLabel('Email Address'),
          const SizedBox(height: 6),
          _inputField(
            controller.emailController,
            'Enter email address',
            fontSize,
          ),
          const SizedBox(height: 16),

          // Input 3: Phone Number
          _fieldLabel('Phone Number'),
          const SizedBox(height: 6),
          _inputField(
            controller.phoneController,
            'Enter phone number',
            fontSize,
          ),
          const SizedBox(height: 16),

          // Input 4: Role (Disabled/Tinted background)
          _fieldLabel('Role'),
          const SizedBox(height: 6),
          _inputField(
            controller.roleController,
            'Role',
            fontSize,
            enabled: false,
            fillColor: const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 4),
          Text(
            'Role can not be changed from this interface',
            style: TextStyle(
              fontSize: fontSize - 2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 20),

          // Save Changes Button
          ElevatedButton(
            onPressed: controller.saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );

  Widget _inputField(
    TextEditingController ctrl,
    String hint,
    double size, {
    bool enabled = true,
    Color fillColor = Colors.white,
  }) => SizedBox(
    height: 42,
    child: TextField(
      controller: ctrl,
      enabled: enabled,
      style: TextStyle(fontSize: size, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
    ),
  );
}

// ─── Right Card: Security Settings ───────────────────────────────────────────

class _SecuritySettingsCard extends StatelessWidget {
  const _SecuritySettingsCard({
    required this.controller,
    required this.fontSize,
  });
  final ProfileController controller;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Leave password fields empty if you don't want to change your password.",
            style: TextStyle(
              fontSize: fontSize - 1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Current Password
          _fieldLabel('Current Password'),
          const SizedBox(height: 6),
          _passwordField(controller.currentPasswordController, fontSize),
          const SizedBox(height: 16),

          // New Password
          _fieldLabel('New Password'),
          const SizedBox(height: 6),
          _passwordField(controller.newPasswordController, fontSize),
          const SizedBox(height: 16),

          // Confirm New Password
          _fieldLabel('Confirm New Password'),
          const SizedBox(height: 6),
          _passwordField(controller.confirmPasswordController, fontSize),
          const SizedBox(height: 24),

          // Update Password Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: controller.updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Update Password',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Requirements Box matching Image 3
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // Soft blue tint
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Password Requirements:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _reqItem('At least 8 characters long', fontSize),
                _reqItem('Include uppercase and lowercase letters', fontSize),
                _reqItem('Include at least one number', fontSize),
                _reqItem('Include at least one special character', fontSize),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logout Button matching Image 3 (Light pink container with red text)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(
                Icons.logout_rounded,
                size: 16,
                color: Color(0xFFEF4444),
              ),
              label: const Text(
                'Log out',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFFEF4444),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE2E2), // Light pink tint
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );

  Widget _passwordField(TextEditingController ctrl, double size) => SizedBox(
    height: 42,
    child: TextField(
      controller: ctrl,
      obscureText: true,
      style: TextStyle(fontSize: size, color: AppColors.textPrimary),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
    ),
  );

  Widget _reqItem(String text, double size) => Padding(
    padding: const EdgeInsets.only(left: 24, bottom: 4),
    child: Text(
      text,
      style: TextStyle(fontSize: size - 1, color: AppColors.primaryBlue),
    ),
  );
}
