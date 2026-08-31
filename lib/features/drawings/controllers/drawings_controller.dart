import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../models/drawing_models.dart';
import '../services/drawings_service.dart';
import '../widgets/drawing_preview_dialog.dart';
import '../widgets/upload_media_dialog.dart';

class DrawingsController extends GetxController {
  DrawingsController({DrawingsService? service})
      : _service = service ?? Get.put(DrawingsService());

  final DrawingsService _service;

  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final localSearchController = TextEditingController();
  final projectList = <DrawingProjectItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDrawings();
  }

  Future<void> fetchDrawings() async {
    isLoading.value = true;
    try {
      final res = await _service.getDrawings();
      if (res != null) {
        List itemsList = [];
        if (res is Map && res['projects'] is List) {
          itemsList = res['projects'] as List;
        } else if (res is List) {
          itemsList = res;
        }

        final parsed = <DrawingProjectItem>[];
        for (final item in itemsList) {
          if (item is Map) {
            parsed.add(DrawingProjectItem.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        if (parsed.isNotEmpty) {
          projectList.assignAll(parsed);
        } else {
          projectList.assignAll(DrawingProjectsData.projects);
        }
      } else {
        projectList.assignAll(DrawingProjectsData.projects);
      }
    } catch (e, stackTrace) {
      AppLogger.e('fetchDrawings Error', error: e, stackTrace: stackTrace, tag: 'DRAWINGS_CTRL');
      projectList.assignAll(DrawingProjectsData.projects);
    } finally {
      isLoading.value = false;
    }
  }

  List<DrawingProjectItem> get filteredProjects {
    final q = searchQuery.value.trim().toLowerCase();
    final source = projectList.isNotEmpty ? projectList : DrawingProjectsData.projects;
    if (q.isEmpty) return source;
    return source
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
      await fetchDrawings();
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const UploadSuccessDialog(),
        );
      }
    }
  }

  @override
  void onClose() {
    localSearchController.dispose();
    super.onClose();
  }
}
