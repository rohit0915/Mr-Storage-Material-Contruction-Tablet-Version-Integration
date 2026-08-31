import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_log_dialog.dart';
import '../../../app/utils/app_toast.dart';
import '../controllers/profile_controller.dart';

class SettingsDialog extends GetView<ProfileController> {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => const SettingsDialog(),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: (size.width * 0.42).clamp(380.0, 520.0),
          maxHeight: size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Centered Header Title
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 6),
              child: Text(
                'Settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Text(
              'Account Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.cardBorder),

            // Toggle Switches List matching Image 4
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _SwitchCard(
                      title: 'Two Factor Authentication',
                      subtitle: 'Add an extra layer to your account',
                      value: controller.twoFactor,
                    ),
                    _SwitchCard(
                      title: 'Email Notification',
                      subtitle: 'Receive notification via email',
                      value: controller.emailNotif,
                    ),
                    _SwitchCard(
                      title: 'SMS Notification',
                      subtitle: 'Receive notification via SMS',
                      value: controller.smsNotif,
                    ),
                    _SwitchCard(
                      title: 'Dashboard Notifications',
                      subtitle: 'Show Notifications On Dashboard',
                      value: controller.dashboardNotif,
                    ),
                    _SwitchCard(
                      title: 'Weekly Email Reports',
                      subtitle: 'Receive Weekly Summary Reports via Email',
                      value: controller.weeklyReports,
                    ),
                    _SwitchCard(
                      title: 'System Alerts',
                      subtitle: 'Receive Critical System alerts',
                      value: controller.systemAlerts,
                    ),
                    _SwitchCard(
                      title: 'Login Alerts via Mail',
                      subtitle: 'Get notified when new Login Register',
                      value: controller.loginAlerts,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => AppLogDialog.show(context),
                      icon: const Icon(Icons.bug_report_outlined, size: 18),
                      label: const Text('View & Copy Debug Logs'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons matching Image 4
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD1D5DB), // Light grey
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        AppToast.showSuccess(
                          title: 'Settings Saved',
                          description: 'Your account settings have been updated.',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  const _SwitchCard({
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final String title;
  final String subtitle;
  final RxBool value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            return Switch(
              value: value.value,
              onChanged: (v) => value.value = v,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primaryBlue,
            );
          }),
        ],
      ),
    );
  }
}
