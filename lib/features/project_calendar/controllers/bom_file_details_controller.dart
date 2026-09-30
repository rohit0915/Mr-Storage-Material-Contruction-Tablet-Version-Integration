import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../../drawings/services/drawings_service.dart';
import '../services/project_calendar_service.dart';

class BomFileDetailsController extends GetxController {
  BomFileDetailsController({
    ProjectCalendarService? calendarService,
    DrawingsService? drawingsService,
  }) : _calendarService = calendarService ?? Get.find<ProjectCalendarService>(),
       _drawingsService = drawingsService ?? (Get.isRegistered<DrawingsService>() ? Get.find<DrawingsService>() : Get.put(DrawingsService()));

  final ProjectCalendarService _calendarService;
  final DrawingsService _drawingsService;

  final isLoading = true.obs;
  final leadId = ''.obs;
  final projectName = ''.obs;
  final jobId = ''.obs;
  final customerName = ''.obs;
  final buildingType = ''.obs;
  final location = ''.obs;
  final status = ''.obs;
  final date = ''.obs;

  final bomFiles = <Map<String, String>>[].obs;
  final selectedFile = Rxn<Map<String, String>>();
  final materialItems = <Map<String, dynamic>>[].obs;
  final isDownloading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    leadId.value = (args['leadId'] as String?) ?? '';
    projectName.value = (args['projectName'] as String?) ?? (args['title'] as String?) ?? '';
    jobId.value = (args['jobId'] as String?) ?? '';
    customerName.value = (args['customerName'] as String?) ?? '';
    buildingType.value = (args['buildingType'] as String?) ?? '';
    location.value = (args['location'] as String?) ?? '';
    status.value = (args['status'] as String?) ?? '';

    final passedFiles = args['files'];
    if (passedFiles is List) {
      for (final f in passedFiles) {
        if (f is Map) {
          bomFiles.add({
            'name': (f['name'] ?? f['fileName'] ?? 'BOM File').toString(),
            'url': (f['url'] ?? f['fileUrl'] ?? '').toString(),
            'type': (f['type'] ?? 'pdf').toString(),
          });
        }
      }
    }

    if (bomFiles.isNotEmpty) {
      selectedFile.value = bomFiles.first;
    }

    if (leadId.value.isNotEmpty) {
      fetchBomDetails(leadId.value);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> fetchBomDetails(String id) async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _calendarService.getProjectDetails(id),
        _calendarService.getProjectBOM(id),
        _drawingsService.getDrawings(leadId: id),
      ]);

      final projData = results[0];
      final bomData = results[1];
      final drawingsData = results[2];

      if (projData != null) {
        final pMap = (projData['project'] is Map)
            ? (projData['project'] as Map)
            : (projData['data'] is Map ? (projData['data'] as Map) : projData);

        if (projectName.value.isEmpty || projectName.value == '—') {
          projectName.value = (pMap['projectName'] ?? pMap['title'] ?? pMap['name'] ?? '').toString();
        }
        if (jobId.value.isEmpty) {
          jobId.value = (pMap['jobId'] ?? pMap['code'] ?? '').toString();
        }
        if (customerName.value.isEmpty) {
          if (pMap['customerId'] is Map) {
            final c = pMap['customerId'] as Map;
            customerName.value = '${c['firstName'] ?? ''} ${c['lastName'] ?? ''}'.trim();
          } else if (pMap['customer'] is Map) {
            final c = pMap['customer'] as Map;
            customerName.value = '${c['firstName'] ?? ''} ${c['lastName'] ?? ''}'.trim();
          }
        }
        if (buildingType.value.isEmpty) {
          buildingType.value = (pMap['buildingType'] ?? pMap['type'] ?? '').toString();
        }
        if (location.value.isEmpty) {
          location.value = (pMap['location'] ?? pMap['siteLocation'] ?? pMap['city'] ?? '').toString();
        }
        if (status.value.isEmpty) {
          status.value = (pMap['lifecycleStatus'] ?? pMap['status'] ?? '').toString();
        }
        final createdAt = pMap['createdAt']?.toString() ?? '';
        if (createdAt.isNotEmpty) {
          date.value = createdAt.split('T')[0];
        }

        // Check if there are material line items inside project
        _extractItems(pMap);
        _collectBomFiles(projData);
      }

      if (bomData != null) {
        _collectBomFiles(bomData);
        _extractItems(bomData);
      }

      if (drawingsData != null) {
        _collectBomFiles(drawingsData);
      }

      if (selectedFile.value == null && bomFiles.isNotEmpty) {
        selectedFile.value = bomFiles.first;
      }
    } catch (e, stackTrace) {
      AppLogger.e('fetchBomDetails error', error: e, stackTrace: stackTrace, tag: 'BOM_DETAILS');
    } finally {
      isLoading.value = false;
    }
  }

  void _collectBomFiles(dynamic value) {
    void visit(dynamic node) {
      if (node is List) {
        for (final item in node) {
          visit(item);
        }
        return;
      }
      if (node is! Map) return;

      final map = Map<String, dynamic>.from(node);
      final url = (map['url'] ?? map['fileUrl'] ?? map['attachmentUrl'])?.toString().trim() ?? '';
      final name = (map['name'] ?? map['fileName'] ?? map['title'] ?? '').toString();
      final type = (map['type'] ?? map['fileType'] ?? '').toString();
      final bNum = map['buildingNumber']?.toString() ?? '';

      if (url.startsWith('http://') || url.startsWith('https://')) {
        final lower = '$name $type $url'.toLowerCase();
        if (lower.contains('bom') || lower.contains('drawing') || lower.endsWith('.pdf')) {
          final displayName = bNum.isNotEmpty
              ? 'Building $bNum - ${name.isNotEmpty ? name : 'BOM File'}'
              : (name.isNotEmpty ? name : 'Project BOM File.pdf');

          if (!bomFiles.any((existing) => existing['url'] == url)) {
            bomFiles.add({
              'name': displayName,
              'url': url,
              'type': type.isNotEmpty ? type : 'pdf',
            });
          }
        }
      }

      for (final child in map.values) {
        visit(child);
      }
    }

    visit(value);
  }

  void _extractItems(dynamic data) {
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);

    final candidates = [
      map['items'],
      map['lineItems'],
      map['materials'],
      map['bomItems'],
      map['requestedItems'],
    ];

    for (final cand in candidates) {
      if (cand is List && cand.isNotEmpty) {
        final parsed = <Map<String, dynamic>>[];
        for (final it in cand) {
          if (it is Map) {
            parsed.add(Map<String, dynamic>.from(it));
          }
        }
        if (parsed.isNotEmpty) {
          materialItems.assignAll(parsed);
          return;
        }
      }
    }
  }

  void selectFile(Map<String, String> file) {
    selectedFile.value = file;
  }

  Future<void> downloadBOM([Map<String, String>? file]) async {
    final target = file ?? selectedFile.value ?? (bomFiles.isNotEmpty ? bomFiles.first : null);
    if (target == null || (target['url'] ?? '').isEmpty) {
      AppToast.showError(
        title: 'BOM File Not Available',
        description: 'No download URL was returned by the API for this project.',
      );
      return;
    }

    final fileUrl = target['url']!;
    final fileName = target['name'] ?? 'Project BOM.pdf';

    isDownloading.value = true;
    AppToast.showSuccess(
      title: 'BOM Download Initiated',
      description: 'Downloading $fileName\n$fileUrl',
    );

    await Future.delayed(const Duration(milliseconds: 800));
    isDownloading.value = false;
  }
}
