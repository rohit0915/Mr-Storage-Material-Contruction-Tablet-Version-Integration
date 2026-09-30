import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/drawings_controller.dart';
import '../services/drawings_service.dart';

class UploadMediaDialog extends StatefulWidget {
  const UploadMediaDialog({super.key});

  @override
  State<UploadMediaDialog> createState() => _UploadMediaDialogState();
}

class _UploadMediaDialogState extends State<UploadMediaDialog> {
  String? _projectId;
  String? _pickedFileName;
  PlatformFile? _pickedFile;
  bool _isSubmitting = false;

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final service = Get.find<DrawingsService>();
      if (_projectId == null ||
          _projectId!.isEmpty ||
          _pickedFileName == null) {
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }
      final file = _pickedFile!;
      final bytes = await file.readAsBytes();
      final extension = (file.extension ?? '').toLowerCase();
      final mimeType = switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'mp4' => 'video/mp4',
        'mov' => 'video/quicktime',
        _ => 'image/jpeg',
      };
      final success = await service.uploadMediaFile(
        leadId: _projectId!,
        fileName: file.name,
        mimeType: mimeType,
        bytes: bytes,
      );
      if (!success && mounted) {
        Get.snackbar(
          'Upload failed',
          'Backend upload permission is unavailable for the construction role.',
        );
      }
      if (success && mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) Navigator.of(context).pop(false);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'mp4', 'mov'],
    );
    if (file == null || !mounted) return;
    setState(() {
      _pickedFile = file;
      _pickedFileName = _pickedFile!.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width * 0.48).clamp(480.0, 600.0);
    final projects = Get.find<DrawingsController>().projectList;
    final scopedLeadId = Get.find<DrawingsController>().scopedLeadId;
    if (_projectId == null && scopedLeadId.isNotEmpty) {
      _projectId = scopedLeadId;
    }
    if (_projectId == null && projects.isNotEmpty) {
      _projectId = projects.first.id;
    }

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1,
        vertical: size.height * 0.06,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Upload Photos/Video's",
                        style: TextStyle(
                          fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),

              // Content Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashed Dropzone Container
                    InkWell(
                      onTap: _pickFile,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.cloud_upload_outlined,
                              size: 32,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Drop your file here',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _pickedFileName == null
                                        ? 'or click to browse'
                                        : _pickedFileName!,
                                    style: TextStyle(
                                      color: _pickedFileName == null
                                          ? AppColors.textSecondary
                                          : AppColors.primaryBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _pickFile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Choose file'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Supported Formats Subtext
                    const Text(
                      'Supported formats: JPG, JPEG, PNG, WEBP, MP4, MOV',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Project Form Field
                    const Text(
                      'Project',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_projectId),
                      initialValue: _projectId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                      ),
                      hint: const Text('Select Project'),
                      items: projects
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(
                                e.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _projectId = v),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),

              // Bottom Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 140,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadSuccessDialog extends StatelessWidget {
  const UploadSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = (size.width * 0.32).clamp(320.0, 420.0);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Uploaded Successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  AppAssets.successCheck,
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
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
      ),
    );
  }
}
