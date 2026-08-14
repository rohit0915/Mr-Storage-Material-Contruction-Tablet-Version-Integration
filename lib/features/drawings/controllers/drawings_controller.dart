import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/drawing_models.dart';
import '../widgets/drawing_preview_dialog.dart';
import '../widgets/upload_media_dialog.dart';

class DrawingsController extends GetxController {
  final searchQuery = ''.obs;
  final localSearchController = TextEditingController();

  List<DrawingProjectItem> get filteredProjects {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return DrawingProjectsData.projects;
    return DrawingProjectsData.projects
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.code.toLowerCase().contains(q) ||
              p.location.toLowerCase().contains(q),
        )
        .toList();
  }

  void onSearchChanged(String value) => searchQuery.value = value;

  Future<void> openFilePreview(
    BuildContext context,
    DrawingFileItem file,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => DrawingPreviewDialog(file: file),
    );
  }

  Future<void> openUpload(BuildContext context) async {
    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const UploadMediaDialog(),
    );
    if (submitted == true && context.mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const UploadSuccessDialog(),
      );
    }
  }

  @override
  void onClose() {
    localSearchController.dispose();
    super.onClose();
  }
}
