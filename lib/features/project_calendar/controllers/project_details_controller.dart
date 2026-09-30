import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../models/project_calendar_models.dart';
import '../services/project_calendar_service.dart';
import '../services/project_progress_service.dart';
import '../../drawings/services/drawings_service.dart';

class ProjectDetailsController extends GetxController {
  ProjectDetailsController({
    ProjectCalendarService? calendarService,
    ProjectProgressService? progressService,
    DrawingsService? drawingsService,
  }) : _calendarService = calendarService ?? Get.find<ProjectCalendarService>(),
       _progressService = progressService ?? Get.find<ProjectProgressService>(),
       _drawingsService = drawingsService ?? Get.put(DrawingsService());

  final ProjectCalendarService _calendarService;
  final ProjectProgressService _progressService;
  final DrawingsService _drawingsService;

  final isLoading = true.obs;
  final projectId = ''.obs;
  final leadId = ''.obs;
  final title = ''.obs;
  final location = ''.obs;
  final buildingType = ''.obs;
  final lifecycleStatus = ''.obs;
  final customerName = ''.obs;
  final customerEmail = ''.obs;

  final deliveries = <DeliveryItem>[].obs;
  final tasks = <Map<String, dynamic>>[].obs;
  final progress = <String, dynamic>{}.obs;
  final media = <Map<String, String>>[].obs;
  final bomFiles = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    final idArg = (args['id'] as String?) ?? '';
    final titleArg = (args['title'] as String?) ?? '';
    final locArg = (args['location'] as String?) ?? '';
    final bTypeArg = (args['buildingType'] as String?) ?? '';
    final jobIdArg = (args['jobId'] as String?) ?? '';
    final statusArg = (args['status'] as String?) ?? '';

    if (titleArg.isNotEmpty) title.value = titleArg;
    if (locArg.isNotEmpty) location.value = locArg;
    if (bTypeArg.isNotEmpty) buildingType.value = bTypeArg;
    if (jobIdArg.isNotEmpty) projectId.value = jobIdArg;
    if (statusArg.isNotEmpty) lifecycleStatus.value = statusArg;

    leadId.value = idArg;
    if (leadId.value.isNotEmpty) {
      fetchDetails(leadId.value);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> fetchDetails(String id) async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _calendarService.getProjectDetails(id),
        _progressService.getProjectProgress(id),
        _drawingsService.getDrawings(leadId: id),
        _calendarService.getProjectBOM(id),
      ]);
      final res = results[0];
      final progressData = results[1];
      final drawingsData = results[2];
      final bomData = results[3];
      if (progressData != null) progress.assignAll(progressData);
      if (res != null) {
        final pMap = (res['project'] is Map)
            ? (res['project'] as Map)
            : (res['data'] is Map ? (res['data'] as Map) : res);

        if (pMap['customerId'] is Map) {
          final cMap = pMap['customerId'] as Map;
          final fn =
              cMap['firstName']?.toString() ?? cMap['name']?.toString() ?? '';
          final ln = cMap['lastName']?.toString() ?? '';
          customerName.value = '$fn $ln'.trim();
          customerEmail.value = cMap['email']?.toString() ?? '';
        } else if (pMap['customer'] is Map) {
          final cMap = pMap['customer'] as Map;
          final fn =
              cMap['firstName']?.toString() ?? cMap['name']?.toString() ?? '';
          final ln = cMap['lastName']?.toString() ?? '';
          customerName.value = '$fn $ln'.trim();
          customerEmail.value = cMap['email']?.toString() ?? '';
        }

        projectId.value =
            pMap['jobId']?.toString() ??
            pMap['code']?.toString() ??
            projectId.value;

        final rawTitle =
            pMap['projectName'] ??
            pMap['title'] ??
            pMap['name'] ??
            pMap['jobName'] ??
            pMap['enquiryName'];
        if (rawTitle != null &&
            rawTitle.toString().isNotEmpty &&
            rawTitle.toString() != 'null') {
          title.value = rawTitle.toString();
        } else if (title.value.isEmpty || title.value == '—') {
          title.value = customerName.value.isNotEmpty
              ? '${customerName.value}\'s Project'
              : 'Project ${projectId.value}';
        }

        final rawLoc =
            pMap['location'] ??
            pMap['siteLocation'] ??
            pMap['address'] ??
            pMap['city'];
        if (rawLoc != null &&
            rawLoc.toString().isNotEmpty &&
            rawLoc.toString() != 'null') {
          location.value = rawLoc.toString();
        } else if (location.value.isEmpty || location.value == '—') {
          location.value = 'Site Location Pending';
        }

        final rawType =
            pMap['buildingType'] ??
            pMap['type'] ??
            pMap['structureType'] ??
            pMap['category'];
        if (rawType != null &&
            rawType.toString().isNotEmpty &&
            rawType.toString() != 'null') {
          buildingType.value = rawType.toString();
        } else if (buildingType.value.isEmpty || buildingType.value == '—') {
          buildingType.value = 'Commercial Steel';
        }

        lifecycleStatus.value =
            pMap['lifecycleStatus']?.toString() ??
            pMap['status']?.toString() ??
            (lifecycleStatus.value.isNotEmpty
                ? lifecycleStatus.value
                : 'initial_contact');

        if (pMap['bomUrl'] != null ||
            pMap['bom'] != null ||
            pMap['bomFile'] != null) {
          final bomVal = pMap['bomUrl'] ?? pMap['bomFile'] ?? pMap['bom'];
          final urlStr =
              (bomVal is Map ? bomVal['url'] : bomVal)?.toString() ?? '';
          if (urlStr.isNotEmpty) {
            bomFiles.add({
              'name': 'Project BOM.pdf',
              'url': urlStr,
              'type': 'pdf',
            });
          }
        }

        if (res['deliveries'] is List) {
          final list = res['deliveries'] as List;
          final parsed = <DeliveryItem>[];
          for (final item in list) {
            if (item is Map) {
              parsed.add(
                DeliveryItem.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
          deliveries.assignAll(parsed);
        }

        if (res['tasks'] is List) {
          final list = res['tasks'] as List;
          final parsed = <Map<String, dynamic>>[];
          for (final item in list) {
            if (item is Map) {
              parsed.add(Map<String, dynamic>.from(item));
            }
          }
          tasks.assignAll(parsed);
        }

        _collectFiles(res);
      }
      if (drawingsData != null) _collectFiles(drawingsData);
      if (bomData != null) {
        _collectFiles(bomData);
        List rawBoms = [];
        if (bomData is List) {
          rawBoms = bomData;
        } else if (bomData is Map && bomData['bomFiles'] is List) {
          rawBoms = bomData['bomFiles'] as List;
        } else if (bomData is Map &&
            bomData['data'] is Map &&
            bomData['data']['bomFiles'] is List) {
          rawBoms = bomData['data']['bomFiles'] as List;
        } else if (bomData is Map && bomData['jobs'] is List) {
          rawBoms = bomData['jobs'] as List;
        } else if (bomData is Map) {
          rawBoms = [bomData];
        }
        for (final item in rawBoms) {
          if (item is Map) {
            final fileUrl =
                item['fileUrl'] ?? item['url'] ?? item['bomUrl'] ?? '';
            final fileName = item['fileName'] ?? item['name'] ?? 'Project BOM';
            final bNum = item['buildingNumber']?.toString() ?? '';
            final title = bNum.isNotEmpty
                ? 'Building $bNum - $fileName'
                : fileName.toString();
            final urlStr = fileUrl.toString().trim();
            if (urlStr.isNotEmpty &&
                !bomFiles.any((existing) => existing['url'] == urlStr)) {
              bomFiles.add({'name': title, 'url': urlStr, 'type': 'pdf'});
            }
          }
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'fetchDetails Error for $id',
        error: e,
        stackTrace: stackTrace,
        tag: 'PROJ_DETAILS_CTRL',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _collectFiles(dynamic value) {
    final foundMedia = <Map<String, String>>[];
    final foundBom = <Map<String, String>>[];

    void visit(dynamic node) {
      if (node is List) {
        for (final item in node) {
          visit(item);
        }
        return;
      }
      if (node is! Map) return;

      final map = Map<String, dynamic>.from(node);
      final url =
          (map['url'] ??
                  map['fileUrl'] ??
                  map['attachmentUrl'] ??
                  map['mediaUrl'])
              ?.toString()
              .trim();
      final name = (map['name'] ?? map['fileName'] ?? map['title'] ?? '')
          .toString();
      final type = (map['type'] ?? map['fileType'] ?? map['mimeType'] ?? '')
          .toString();
      if (url != null &&
          (url.startsWith('http://') || url.startsWith('https://'))) {
        final lower = '$name $type $url'.toLowerCase();
        final entry = {'url': url, 'name': name, 'type': type};
        if (lower.contains('bom')) {
          foundBom.add(entry);
        }
        if (lower.contains('photo') ||
            lower.contains('image') ||
            lower.contains('video') ||
            RegExp(r'\.(png|jpe?g|webp|gif|mp4|mov)(\?|$)').hasMatch(lower)) {
          foundMedia.add(entry);
        }
      }
      for (final child in map.values) {
        visit(child);
      }
    }

    visit(value);
    for (final item in foundMedia) {
      if (!media.any((existing) => existing['url'] == item['url'])) {
        media.add(item);
      }
    }
    for (final item in foundBom) {
      if (!bomFiles.any((existing) => existing['url'] == item['url'])) {
        bomFiles.add(item);
      }
    }
  }
}
