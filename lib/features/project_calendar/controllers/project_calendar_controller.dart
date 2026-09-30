import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/utils/app_logger.dart';
import '../models/project_calendar_models.dart';
import '../services/project_calendar_service.dart';
import '../widgets/add_delivery_dialog.dart';

class ProjectCalendarController extends GetxController {
  ProjectCalendarController({ProjectCalendarService? calendarService})
    : _calendarService = calendarService ?? Get.put(ProjectCalendarService());

  final ProjectCalendarService _calendarService;

  final selectedTab = ProjectCalendarTab.calendar.obs;
  final focusedMonth = DateTime.now().obs;
  final selectedDay = DateTime.now().day.obs;
  final selectedProjectId = ''.obs;
  final dropdownOpen = false.obs;

  bool isLoadingProjects = false;
  bool isLoadingCalendar = false;
  String errorMessage = '';

  List<CalendarProjectOption> projects = [];
  Map<int, List<CalendarDayEvent>> monthEvents = {};
  Map<int, List<DeliveryItem>> dayDeliveriesMap = {};
  List<ProjectCardItem> projectCards = [];

  CalendarProjectOption? get selectedProject {
    if (projects.isEmpty) return null;
    return projects.firstWhere(
      (p) => p.id == selectedProjectId.value,
      orElse: () => projects.first,
    );
  }

  List<CalendarDayEvent> get selectedDayEvents =>
      monthEvents[selectedDay.value] ?? const [];

  List<DeliveryItem> get selectedDayDeliveries =>
      dayDeliveriesMap[selectedDay.value] ?? const [];

  static const allProjectsOption = CalendarProjectOption(
    id: '',
    name: 'All Projects',
    code: 'ALL',
    imageAsset: '',
  );

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh calendar data whenever screen is rendered
    fetchCalendarData();
  }

  Future<void> initData() async {
    await fetchProjects();
    await fetchCalendarData();
  }

  int projectPage = 1;
  int projectLimit = 10;
  int projectTotalPages = 1;
  int projectTotalResults = 0;

  Future<void> fetchProjects({int? page, int? limit}) async {
    if (page != null) projectPage = page;
    if (limit != null) projectLimit = limit;

    isLoadingProjects = true;
    update([AppGetIds.projectCards, AppGetIds.projectDropdown]);
    try {
      final res = await _calendarService.getProjects(
        page: projectPage,
        limit: projectLimit,
      );
      if (res != null) {
        List itemsList = [];
        if (res is Map) {
          if (res['projects'] is List) {
            itemsList = res['projects'] as List;
          } else if (res['data'] is List) {
            itemsList = res['data'] as List;
          } else if (res['items'] is List) {
            itemsList = res['items'] as List;
          }

          final rawPages =
              res['totalPages'] ??
              res['pages'] ??
              res['total_pages'] ??
              res['pagination']?['totalPages'];
          projectTotalPages = int.tryParse(rawPages?.toString() ?? '') ?? 1;

          final rawTotal =
              res['totalProjects'] ??
              res['total'] ??
              res['totalResults'] ??
              res['pagination']?['total'];
          projectTotalResults =
              int.tryParse(rawTotal?.toString() ?? '') ?? itemsList.length;

          final rawCurr =
              res['currentPage'] ?? res['page'] ?? res['pagination']?['page'];
          if (rawCurr != null) {
            projectPage = int.tryParse(rawCurr.toString()) ?? projectPage;
          }
        } else if (res is List) {
          itemsList = res;
          projectTotalResults = itemsList.length;
          projectTotalPages = (projectTotalResults / projectLimit).ceil().clamp(
            1,
            999,
          );
        }

        if (projectTotalPages < 1) projectTotalPages = 1;

        final parsedOptions = <CalendarProjectOption>[allProjectsOption];
        final parsedCards = <ProjectCardItem>[];

        for (final item in itemsList) {
          if (item is Map) {
            final mapItem = Map<String, dynamic>.from(item);
            parsedOptions.add(CalendarProjectOption.fromJson(mapItem));
            parsedCards.add(ProjectCardItem.fromJson(mapItem));
          }
        }

        projects = parsedOptions;
        projectCards = parsedCards;
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'fetchProjects Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'CALENDAR_CTRL',
      );
    } finally {
      isLoadingProjects = false;
      update([AppGetIds.projectCards, AppGetIds.projectDropdown]);
    }
  }

  void changeProjectPage(int page) {
    if (page < 1 || page > projectTotalPages || page == projectPage) return;
    fetchProjects(page: page);
  }

  void changeProjectLimit(int limit) {
    if (limit == projectLimit) return;
    fetchProjects(page: 1, limit: limit);
  }

  Future<void> fetchCalendarData() async {
    isLoadingCalendar = true;
    update([AppGetIds.calendarEvents]);
    try {
      final m = focusedMonth.value.month;
      final y = focusedMonth.value.year;
      final leadId = selectedProjectId.value.isNotEmpty
          ? selectedProjectId.value
          : null;

      final res = await _calendarService.getProjectCalendar(
        month: m,
        year: y,
        leadId: leadId,
      );

      if (res != null) {
        Map<String, dynamic>? calendarMap;
        if (res is Map) {
          if (res['calendar'] is Map) {
            calendarMap = Map<String, dynamic>.from(res['calendar'] as Map);
          } else {
            calendarMap = Map<String, dynamic>.from(res);
          }
        }

        if (calendarMap != null) {
          final newEvents = <int, List<CalendarDayEvent>>{};
          final newDeliveriesMap = <int, List<DeliveryItem>>{};

          calendarMap.forEach((key, val) {
            int? dayNum;
            String cleanKey = key;
            if (cleanKey.contains('T')) {
              cleanKey = cleanKey.split('T')[0];
            }
            if (cleanKey.contains('-')) {
              final parts = cleanKey.split('-');
              if (parts.length == 3) {
                dayNum = int.tryParse(parts[2]);
              }
            } else {
              dayNum = int.tryParse(cleanKey);
            }

            List itemsList = [];
            if (val is List) {
              itemsList = val;
            } else if (val is Map) {
              itemsList = [val];
            }

            if (itemsList.isNotEmpty) {
              final dayEventList = <CalendarDayEvent>[];
              final dayDeliveryList = <DeliveryItem>[];

              for (final dItem in itemsList) {
                if (dItem is Map) {
                  final dMap = Map<String, dynamic>.from(dItem);
                  dayEventList.add(CalendarDayEvent.fromJson(dMap));
                  dayDeliveryList.add(DeliveryItem.fromJson(dMap));
                }
              }

              if (dayNum != null && dayNum >= 1 && dayNum <= 31) {
                if (dayEventList.isNotEmpty) {
                  newEvents[dayNum] = dayEventList;
                }
                if (dayDeliveryList.isNotEmpty) {
                  newDeliveriesMap[dayNum] = dayDeliveryList;
                }
              }
            }
          });

          monthEvents = newEvents;
          dayDeliveriesMap = newDeliveriesMap;
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'fetchCalendarData Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'CALENDAR_CTRL',
      );
    } finally {
      isLoadingCalendar = false;
      update([AppGetIds.calendarEvents]);
    }
  }

  void setTab(ProjectCalendarTab tab) {
    selectedTab.value = tab;
    dropdownOpen.value = false;
    update([
      AppGetIds.projectCalendarTab,
      AppGetIds.projectCards,
      AppGetIds.projectDropdown,
    ]);
  }

  void selectDay(int day) {
    selectedDay.value = day;
    update([AppGetIds.calendarEvents]);
  }

  void previousMonth() {
    final m = focusedMonth.value;
    focusedMonth.value = DateTime(m.year, m.month - 1, 1);
    fetchCalendarData();
  }

  void nextMonth() {
    final m = focusedMonth.value;
    focusedMonth.value = DateTime(m.year, m.month + 1, 1);
    fetchCalendarData();
  }

  void goToday() {
    final now = DateTime.now();
    focusedMonth.value = DateTime(now.year, now.month, 1);
    selectedDay.value = now.day;
    fetchCalendarData();
  }

  void selectProject(String id) {
    selectedProjectId.value = id;
    dropdownOpen.value = false;
    update([AppGetIds.projectDropdown, AppGetIds.projectCards]);
    fetchCalendarData();
  }

  void toggleDropdown() {
    dropdownOpen.value = !dropdownOpen.value;
    update([AppGetIds.projectDropdown]);
  }

  void closeDropdown() {
    dropdownOpen.value = false;
    update([AppGetIds.projectDropdown]);
  }

  Future<void> openAddDelivery(BuildContext context) async {
    dropdownOpen.value = false;
    update([AppGetIds.projectDropdown]);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddDeliveryDialog(),
    );
    if (confirmed == true && context.mounted) {
      await fetchCalendarData();
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const DeliverySuccessDialog(),
        );
      }
    }
  }
}
