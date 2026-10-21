import 'package:get/get.dart';
import 'package:steelbuildingtablet/app/constants/api_constants.dart';

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

  // Construction timeline tasks (GET /api/construction/projects/:leadId/timeline-tasks)
  final timelineTasks = <ProjectTimelineTask>[].obs;
  final isTimelineLoading = false.obs;

  final workflowCompletionDate = '30 May 2026'.obs;
  final workflowStatus = '2 Days Delayed'.obs;
  final workflowSteps = <ProjectWorkflowStep>[
    const ProjectWorkflowStep(
      stepNumber: 1,
      title: 'Site Preparation & Foundation',
      startDate: '12 April 2026',
      endDate: '14 April 2026',
      estEndDate: '13 April 2026',
      completedDate: '14 April 2026',
      timelineBadge: 'Under timeline',
      status: 'Completed',
      description: 'Excavation, grading, and concrete footings poured and inspected.',
      photos: [
        'assets/images/projects/project_1.png',
        'assets/images/projects/project_2.png',
        'assets/images/projects/project_3.png',
        'assets/images/projects/project_4.png',
      ],
    ),
    const ProjectWorkflowStep(
      stepNumber: 2,
      title: 'Steel Structure Erection',
      startDate: '15 April 2026',
      endDate: '18 April 2026',
      estEndDate: '16 April 2026',
      completedDate: '18 April 2026',
      timelineBadge: '2 Days Late',
      status: 'Completed',
      description: 'Primary rigid frame columns and rafters assembled and bolted.',
      photos: [
        'assets/images/projects/project_2.png',
        'assets/images/projects/project_3.png',
      ],
    ),
    const ProjectWorkflowStep(
      stepNumber: 3,
      title: 'Secondary Framing Installation',
      startDate: '18 April 2026',
      endDate: '20 April 2026',
      estEndDate: '20 April 2026',
      completedDate: '-',
      timelineBadge: 'In Progress',
      status: 'In Progress',
      description: 'Purlins, girts, and eave struts installed across all bays.',
      photos: [
        'assets/images/projects/project_3.png',
        'assets/images/projects/project_4.png',
      ],
    ),
    const ProjectWorkflowStep(
      stepNumber: 4,
      title: 'Roofing Installation',
      startDate: '15 April 2026',
      endDate: '18 April 2026',
      estEndDate: '18 April 2026',
      completedDate: '-',
      timelineBadge: 'Delayed',
      status: 'Delayed',
      description: 'Insulated roof panels being fixed and sealed against weather.',
      photos: [
        'assets/images/projects/project_4.png',
      ],
    ),
  ].obs;

  /// Fetch construction timeline tasks: GET /api/construction/projects/:leadId/timeline-tasks
  Future<void> fetchTimelineTasks(String id) async {
    if (id.isEmpty) return;
    isTimelineLoading.value = true;
    try {
      final rawList = await _calendarService.getTimelineTasks(id);
      final parsed = <ProjectTimelineTask>[];
      for (final item in rawList) {
        parsed.add(ProjectTimelineTask.fromJson(item));
      }
      // Sort client-side by startDate asc
      parsed.sort((a, b) {
        if (a.rawStartDate == null && b.rawStartDate == null) return 0;
        if (a.rawStartDate == null) return 1;
        if (b.rawStartDate == null) return -1;
        return a.rawStartDate!.compareTo(b.rawStartDate!);
      });
      timelineTasks.assignAll(parsed);
    } catch (e, st) {
      AppLogger.e('fetchTimelineTasks Error for $id', error: e, stackTrace: st, tag: 'PROJ_DETAILS_CTRL');
    } finally {
      isTimelineLoading.value = false;
    }
  }

  /// Create timeline task: POST /api/construction/tasks
  Future<bool> createTimelineTask({
    required String title,
    DateTime? startDate,
    DateTime? estimatedEndDate,
    String? description,
    List<String>? attachments,
    String status = 'in_progress',
  }) async {
    final effectiveLeadId = leadId.value;
    if (effectiveLeadId.isEmpty) return false;

    final body = <String, dynamic>{
      'title': title,
      'leadId': effectiveLeadId,
      'startDate': (startDate ?? DateTime.now()).toUtc().toIso8601String(),
      if (estimatedEndDate != null)
        'estimatedEndDate': estimatedEndDate.toUtc().toIso8601String(),
      if (estimatedEndDate != null)
        'dueDate': estimatedEndDate.toUtc().toIso8601String(),
      if (description != null && description.isNotEmpty)
        'description': description,
      if (description != null && description.isNotEmpty)
        'workDescription': description,
      if (attachments != null && attachments.isNotEmpty) ...{
        'attachments': attachments,
        'photos': attachments,
      },
      'status': status,
    };

    try {
      final res = await _calendarService.createTimelineTask(body);
      await fetchTimelineTasks(effectiveLeadId);
      return res != null;
    } catch (e, st) {
      AppLogger.e('createTimelineTask Error', error: e, stackTrace: st, tag: 'PROJ_DETAILS_CTRL');
      return false;
    }
  }

  /// Mark task complete: PUT /api/construction/tasks/:taskId/complete
  Future<bool> markTimelineTaskComplete(
    String taskId, {
    DateTime? completedAt,
    String? workDescription,
    List<String>? attachments,
  }) async {
    if (taskId.isEmpty) return false;
    final success = await _calendarService.completeTask(
      taskId,
      completedAt: completedAt,
      workDescription: workDescription,
      attachments: attachments,
    );
    if (leadId.value.isNotEmpty) {
      await fetchTimelineTasks(leadId.value);
    }
    return success;
  }

  /// Remove task: DELETE /api/construction/tasks/:taskId
  Future<bool> deleteTimelineTask(String taskId) async {
    if (taskId.isEmpty) return false;
    final success = await _calendarService.deleteTimelineTask(taskId);
    if (leadId.value.isNotEmpty) {
      await fetchTimelineTasks(leadId.value);
    }
    return success;
  }

  /// Get single task detail: GET /api/construction/tasks/:taskId
  Future<ProjectTimelineTask?> getTimelineTaskDetail(String taskId) async {
    if (taskId.isEmpty) return null;
    final raw = await _calendarService.getTaskDetail(taskId);
    if (raw != null) {
      return ProjectTimelineTask.fromJson(raw);
    }
    return null;
  }

  Future<bool> markStepComplete(ProjectWorkflowStep step) async {
    final matchedTask = timelineTasks.firstWhereOrNull(
      (t) =>
          (step.stepKey.isNotEmpty && t.id == step.stepKey) ||
          t.title.toLowerCase().trim() == step.title.toLowerCase().trim(),
    );
    if (matchedTask != null && matchedTask.id.isNotEmpty) {
      await markTimelineTaskComplete(matchedTask.id);
    }

    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    return updateWorkflowStep(
      stepTitle: step.title,
      status: 'Completed',
      startDate: step.startDate,
      endDate: dateStr,
      description: step.description,
      photos: step.photos,
      stepKey: step.stepKey,
      percentComplete: 100,
    );
  }

  Future<bool> removeTask(ProjectWorkflowStep step) async {
    final matchedTask = timelineTasks.firstWhereOrNull(
      (t) =>
          (step.stepKey.isNotEmpty && t.id == step.stepKey) ||
          t.title.toLowerCase().trim() == step.title.toLowerCase().trim(),
    );
    if (matchedTask != null && matchedTask.id.isNotEmpty) {
      await deleteTimelineTask(matchedTask.id);
    }

    workflowSteps.removeWhere(
      (s) =>
          (step.stepKey.isNotEmpty && s.stepKey == step.stepKey) ||
          s.title.toLowerCase().trim() == step.title.toLowerCase().trim(),
    );
    workflowSteps.refresh();
    return true;
  }

  Future<bool> addTask({
    required String title,
    required String startDate,
    required String estEndDate,
    String? description,
    List<String>? photos,
  }) async {
    final newStep = ProjectWorkflowStep(
      stepNumber: workflowSteps.length + 1,
      title: title,
      startDate: startDate,
      endDate: estEndDate,
      estEndDate: estEndDate,
      completedDate: '-',
      status: 'In Progress',
      timelineBadge: 'In Progress',
      description: description ?? '',
      photos: photos ?? const [
        'assets/images/projects/project_1.png',
        'assets/images/projects/project_2.png',
      ],
      completionPct: 15,
    );
    workflowSteps.add(newStep);
    workflowSteps.refresh();

    if (leadId.value.isNotEmpty) {
      await createTimelineTask(
        title: title,
        description: description,
        attachments: photos,
      );
    }
    return true;
  }

  Future<bool> updateWorkflowStep({
    required String stepTitle,
    required String status,
    required String startDate,
    required String endDate,
    String? description,
    List<String>? photos,
    String? stepKey,
    int? percentComplete,
  }) async {
    final index = workflowSteps.indexWhere(
      (s) =>
          (stepKey != null && s.stepKey.isNotEmpty && s.stepKey == stepKey) ||
          s.title.toLowerCase().trim() == stepTitle.toLowerCase().trim(),
    );

    String effectiveStepKey = stepKey ?? '';
    final calculatedPct = percentComplete ??
        (status.toLowerCase().contains('complete')
            ? 100
            : (status.toLowerCase().contains('progress') ? 50 : 0));

    if (index != -1) {
      final current = workflowSteps[index];
      if (effectiveStepKey.isEmpty) {
        effectiveStepKey = current.stepKey;
      }
      workflowSteps[index] = current.copyWith(
        status: status,
        startDate: startDate.isNotEmpty ? startDate : current.startDate,
        endDate: endDate.isNotEmpty ? endDate : current.endDate,
        description: description ?? current.description,
        photos: photos ?? current.photos,
        completionPct: calculatedPct,
      );
      workflowSteps.refresh();
    }

    if (effectiveStepKey.isEmpty) {
      effectiveStepKey = stepTitle
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    }

    if (leadId.value.isNotEmpty) {
      final payload = <String, dynamic>{
        'status': status,
        'percentComplete': calculatedPct,
        if (startDate.isNotEmpty && startDate != '-') 'startDate': startDate,
        if (endDate.isNotEmpty && endDate != '-') 'endDate': endDate,
        if (description != null && description.isNotEmpty) 'notes': description,
        if (photos != null && photos.isNotEmpty)
          'attachments':
              photos.map((p) => {'name': 'Site photo', 'url': p}).toList(),
      };
      try {
        await _progressService.updateProjectStep(
          leadId: leadId.value,
          stepKey: effectiveStepKey,
          payload: payload,
        );
        _refreshPhases(leadId.value);
      } catch (e, st) {
        AppLogger.e('Error updating step via API', error: e, stackTrace: st, tag: 'PROJ_DETAILS_CTRL');
      }
    }
    return true;
  }

  Future<void> _refreshPhases(String id) async {
    try {
      final phasesData = await _progressService.getProjectPhases(id);
      if (phasesData != null && phasesData['steps'] is List) {
        final rawSteps = phasesData['steps'] as List;
        final parsedSteps = <ProjectWorkflowStep>[];
        for (int i = 0; i < rawSteps.length; i++) {
          final s = rawSteps[i];
          if (s is Map) {
            parsedSteps.add(
              ProjectWorkflowStep.fromJson(Map<String, dynamic>.from(s), i + 1),
            );
          }
        }
        if (parsedSteps.isNotEmpty) {
          workflowSteps.assignAll(parsedSteps);
        }
      }
    } catch (_) {}
  }

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
        _progressService.getProjectPhases(id),
        _drawingsService.getMedia(id),
      ]);
      await fetchTimelineTasks(id);
      final res = results[0];
      final progressData = results[1];
      final drawingsData = results[2];
      final bomData = results[3];
      final phasesData = results[4];
      final mediaData = results[5];
      if (progressData != null) progress.assignAll(progressData);
      if (mediaData != null) _collectFiles(mediaData, isDirectMedia: true);
      if (res != null) _collectFiles(res);
      if (drawingsData != null) _collectFiles(drawingsData);
      if (phasesData != null) _collectFiles(phasesData);

      // Collect attachments from timeline tasks into media
      for (final t in timelineTasks) {
        for (final att in t.attachments) {
          if (att.isNotEmpty && !media.any((existing) => existing['url'] == att)) {
            media.add({'name': t.title, 'url': att, 'type': 'photo'});
          }
        }
      }

      // If media is still empty, query global media API as fallback
      if (media.isEmpty) {
        try {
          final globalMedia = await _drawingsService.getGlobalMedia();
          if (globalMedia != null) {
            _collectFilesForProject(globalMedia, id);
          }
        } catch (_) {}
      }

      List rawSteps = [];
      if (phasesData != null && phasesData['steps'] is List) {
        rawSteps = phasesData['steps'] as List;
      } else if (progressData != null && progressData['steps'] is List) {
        rawSteps = progressData['steps'] as List;
      }
      if (rawSteps.isNotEmpty) {
        final parsedSteps = <ProjectWorkflowStep>[];
        for (int i = 0; i < rawSteps.length; i++) {
          final s = rawSteps[i];
          if (s is Map) {
            parsedSteps.add(
              ProjectWorkflowStep.fromJson(Map<String, dynamic>.from(s), i + 1),
            );
          }
        }
        if (parsedSteps.isNotEmpty) {
          workflowSteps.assignAll(parsedSteps);
        }
      }

      if (phasesData != null) {
        if (phasesData['currentStepLabel'] != null &&
            phasesData['currentStepLabel'].toString().isNotEmpty) {
          workflowStatus.value = phasesData['currentStepLabel'].toString();
        } else if (phasesData['overallProgressPct'] != null) {
          workflowStatus.value = '${phasesData['overallProgressPct']}% Complete';
        }
      }
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
          for (int i = 0; i < list.length; i++) {
            final item = list[i];
            if (item is Map) {
              final mItem = Map<String, dynamic>.from(item);
              if (mItem['createdAt'] == null && mItem['created_at'] == null) {
                mItem['createdAt'] = DateTime.fromMillisecondsSinceEpoch(1600000000000 + i * 1000).toIso8601String();
              }
              parsed.add(DeliveryItem.fromJson(mItem));
            }
          }
          parsed.sort((a, b) {
            final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
            final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
            if (aTime != bTime) return bTime.compareTo(aTime);
            return b.id.compareTo(a.id);
          });
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

  void _collectFiles(dynamic value, {bool isDirectMedia = false}) {
    final foundMedia = <Map<String, String>>[];
    final foundBom = <Map<String, String>>[];

    void processUrl(String rawUrl, {String name = '', String type = ''}) {
      if (rawUrl.isEmpty || rawUrl == 'null') return;
      String url = rawUrl.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        if (url.startsWith('/')) {
          url = '${ApiConstants.serverOrigin}$url';
        } else if (url.startsWith('uploads/') ||
            url.startsWith('media/') ||
            url.startsWith('files/')) {
          url = '${ApiConstants.serverOrigin}/$url';
        } else {
          return;
        }
      }
      final lower = '$name $type $url'.toLowerCase();
      final entry = {
        'url': url,
        'name': name.isEmpty ? 'Site Media' : name,
        'type': type.isEmpty ? 'photo' : type,
      };
      if (lower.contains('bom')) {
        foundBom.add(entry);
      }
      if (isDirectMedia ||
          lower.contains('photo') ||
          lower.contains('image') ||
          lower.contains('video') ||
          lower.contains('media') ||
          lower.contains('upload') ||
          RegExp(r'\.(png|jpe?g|webp|gif|mp4|mov)(\?|$)').hasMatch(lower)) {
        foundMedia.add(entry);
      }
    }

    void visit(dynamic node) {
      if (node == null) return;
      if (node is List) {
        for (final item in node) {
          if (item is String && (item.startsWith('http') || item.startsWith('/'))) {
            processUrl(item);
          } else {
            visit(item);
          }
        }
        return;
      }
      if (node is! Map) return;

      final map = Map<String, dynamic>.from(node);
      final rawUrl = (map['url'] ??
              map['fileUrl'] ??
              map['signedUrl'] ??
              map['mediaUrl'] ??
              map['photoUrl'] ??
              map['imageUrl'] ??
              map['image'] ??
              map['photo'] ??
              map['attachmentUrl'] ??
              map['downloadUrl'] ??
              map['secure_url'] ??
              map['path'])
          ?.toString()
          .trim();
      final name = (map['name'] ?? map['fileName'] ?? map['title'] ?? '')
          .toString();
      final type = (map['type'] ?? map['fileType'] ?? map['mimeType'] ?? '')
          .toString();

      if (rawUrl != null && rawUrl.isNotEmpty && rawUrl != 'null') {
        processUrl(rawUrl, name: name, type: type);
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

  void _collectFilesForProject(dynamic globalMediaData, String targetId) {
    dynamic mediaData = globalMediaData;
    if (mediaData is Map && mediaData.containsKey('data')) {
      mediaData = mediaData['data'];
    }
    List mediaProjects = [];
    if (mediaData is Map && mediaData['projects'] is List) {
      mediaProjects = mediaData['projects'] as List;
    } else if (mediaData is List) {
      mediaProjects = mediaData;
    }

    for (final mp in mediaProjects) {
      if (mp is Map) {
        final mLeadId =
            (mp['leadId'] ?? mp['projectId'] ?? mp['_id'] ?? '').toString();
        final pCode =
            (mp['projectId'] ?? mp['jobId'] ?? mp['code'] ?? '').toString();
        if (mLeadId == targetId || pCode == targetId || targetId.isEmpty) {
          final rawDocs = mp['documents'] ?? mp['media'] ?? mp['files'];
          if (rawDocs != null) {
            _collectFiles(rawDocs, isDirectMedia: true);
          }
        }
      }
    }
  }
}
