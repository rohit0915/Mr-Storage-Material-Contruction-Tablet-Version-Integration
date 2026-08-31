import 'package:flutter/material.dart';
import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';

class PackingListSuccessDialog extends StatelessWidget {
  const PackingListSuccessDialog({super.key, required this.title});
  final String title;

  static Future<void> show(BuildContext context, String title) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PackingListSuccessDialog(title: title),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.82,
          maxWidth: (size.width * 0.34).clamp(340.0, 440.0),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.14,
                  maxWidth: 110,
                ),
                child: Image.asset(AppAssets.successCheck, fit: BoxFit.contain),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
