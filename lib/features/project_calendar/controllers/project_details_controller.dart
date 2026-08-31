import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../models/project_calendar_models.dart';
import '../services/project_calendar_service.dart';

class ProjectDetailsController extends GetxController {
  ProjectDetailsController({ProjectCalendarService? calendarService})
      : _calendarService = calendarService ?? Get.find<ProjectCalendarService>();

  final ProjectCalendarService _calendarService;

  final isLoading = true.obs;
  final projectId = ''.obs;
  final leadId = ''.obs;
  final title = 'Project Details'.obs;
  final location = 'Site Location'.obs;
  final buildingType = 'Warehouse'.obs;
  final lifecycleStatus = 'initial_contact'.obs;
  final customerName = ''.obs;
  final customerEmail = ''.obs;

  final deliveries = <DeliveryItem>[].obs;
  final tasks = <Map<String, dynamic>>[].obs;

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
      final res = await _calendarService.getProjectDetails(id);
      if (res != null) {
        if (res['project'] is Map) {
          final pMap = res['project'] as Map;
          title.value = pMap['projectName']?.toString() ?? title.value;
          location.value = pMap['location']?.toString() ?? location.value;
          buildingType.value = pMap['buildingType']?.toString() ?? buildingType.value;
          projectId.value = pMap['jobId']?.toString() ?? projectId.value;
          lifecycleStatus.value = pMap['lifecycleStatus']?.toString() ?? lifecycleStatus.value;

          if (pMap['customerId'] is Map) {
            final cMap = pMap['customerId'] as Map;
            final fn = cMap['firstName']?.toString() ?? '';
            final ln = cMap['lastName']?.toString() ?? '';
            customerName.value = '$fn $ln'.trim();
            customerEmail.value = cMap['email']?.toString() ?? '';
          }
        }

        if (res['deliveries'] is List) {
          final list = res['deliveries'] as List;
          final parsed = <DeliveryItem>[];
          for (final item in list) {
            if (item is Map) {
              parsed.add(DeliveryItem.fromJson(Map<String, dynamic>.from(item)));
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
      }
    } catch (e, stackTrace) {
      AppLogger.e('fetchDetails Error for $id', error: e, stackTrace: stackTrace, tag: 'PROJ_DETAILS_CTRL');
    } finally {
      isLoading.value = false;
    }
  }
}
