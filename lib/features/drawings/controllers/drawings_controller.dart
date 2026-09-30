import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/services/construction_socket_service.dart';
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
  String scopedLeadId = '';

  StreamSubscription<ConstructionSocketEvent>? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    scopedLeadId = args is Map ? (args['leadId'] ?? '').toString() : '';

    // Join lead room if scoped to a project
    if (scopedLeadId.isNotEmpty &&
        Get.isRegistered<ConstructionSocketService>()) {
      Get.find<ConstructionSocketService>().joinLeadChat(scopedLeadId);
    }

    // Listen for drawing update events
    if (Get.isRegistered<ConstructionSocketService>()) {
      _socketSubscription = Get.find<ConstructionSocketService>().listenFor(
        ConstructionSocketService.drawingEvents,
        _handleDrawingEvent,
      );
    }

    fetchDrawings(leadId: scopedLeadId);
  }

  void _handleDrawingEvent(ConstructionSocketEvent event) {
    if (event.name == 'drawing_status_updated') {
      final eventLeadId = event.payload['leadId']?.toString() ?? '';
      if (scopedLeadId.isEmpty || scopedLeadId == eventLeadId) {
        AppLogger.i(
          'Drawing status updated event received for lead: $eventLeadId, auto-refetching...',
          tag: 'DRAWINGS',
        );
        fetchDrawings(leadId: scopedLeadId.isNotEmpty ? scopedLeadId : null);
      }
    }
  }

  Future<void> fetchDrawings({String? leadId}) async {
    isLoading.value = true;
    try {
      final res = await _service.getDrawings(leadId: leadId);
      if (res != null) {
        List itemsList = [];
        if (res is Map && res['projects'] is List) {
          itemsList = res['projects'] as List;
        } else if (res is Map &&
            (res.containsKey('documents') || res.containsKey('projectId'))) {
          itemsList = [res];
        } else if (res is List) {
          itemsList = res;
        }

        final parsed = <DrawingProjectItem>[];
        for (final item in itemsList) {
          if (item is Map) {
            parsed.add(
              DrawingProjectItem.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
        projectList.assignAll(parsed);
      } else {
        projectList.clear();
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'fetchDrawings Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'DRAWINGS_CTRL',
      );
      projectList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<DrawingProjectItem> get filteredProjects {
    final q = searchQuery.value.trim().toLowerCase();
    final source = projectList;
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
      await fetchDrawings(leadId: scopedLeadId);
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
    if (scopedLeadId.isNotEmpty &&
        Get.isRegistered<ConstructionSocketService>()) {
      Get.find<ConstructionSocketService>().leaveLeadChat(scopedLeadId);
    }
    _socketSubscription?.cancel();
    localSearchController.dispose();
    super.onClose();
  }
}
