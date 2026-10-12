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
  final calendarViewMode = 'Month'.obs;

  bool isLoadingProjects = false;
  bool isLoadingCalendar = false;
  String errorMessage = '';

  List<CalendarProjectOption> projects = [];
  Map<int, List<CalendarDayEvent>> monthEvents = {};
  Map<int, List<DeliveryItem>> dayDeliveriesMap = {};
  List<ProjectCardItem> projectCards = [];

  CalendarProjectOption? get selectedProject {
    if (projects.isEmpty) return null;
    final sel = selectedProjectId.value.trim().toLowerCase();
    if (sel.isEmpty) return projects.first;
    return projects.firstWhere(
      (p) =>
          (p.id.isNotEmpty && p.id.toLowerCase() == sel) ||
          (p.code.isNotEmpty && p.code.toLowerCase() == sel) ||
          (p.name.isNotEmpty && p.name.toLowerCase() == sel),
      orElse: () => projects.first,
    );
  }

  List<CalendarDayEvent> get selectedDayEvents {
    final list = List<CalendarDayEvent>.from(monthEvents[selectedDay.value] ?? const []);
    list.sort((a, b) {
      final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
      if (aTime != bTime) return bTime.compareTo(aTime);
      return 0;
    });
    return list;
  }

  List<DeliveryItem> get selectedDayDeliveries {
    final list = List<DeliveryItem>.from(dayDeliveriesMap[selectedDay.value] ?? const []);
    list.sort((a, b) {
      final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
      if (aTime != bTime) return bTime.compareTo(aTime);
      return b.id.compareTo(a.id);
    });
    return list;
  }

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
    if (projects.length <= 1) {
      fetchAllProjectOptions();
    }
    // Refresh calendar data whenever screen is rendered
    fetchCalendarData();
  }

  Future<void> initData() async {
    await fetchAllProjectOptions();
    await fetchProjects();
    await fetchCalendarData();
  }

  Future<void> fetchAllProjectOptions() async {
    try {
      final rawList = await _calendarService.getAllProjects();
      final optionsMap = <String, CalendarProjectOption>{};
      optionsMap[''] = allProjectsOption;

      for (final item in rawList) {
        final opt = CalendarProjectOption.fromJson(item);
        if (opt.id.isNotEmpty) {
          optionsMap[opt.id] = opt;
        }
      }

      if (optionsMap.length > 1) {
        projects = optionsMap.values.toList();
        update([AppGetIds.projectDropdown]);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'fetchAllProjectOptions Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'CALENDAR_CTRL',
      );
    }
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

        final currentOptions = Map<String, CalendarProjectOption>.fromEntries(
          projects.map((p) => MapEntry(p.id, p)),
        );
        if (!currentOptions.containsKey('')) {
          currentOptions[''] = allProjectsOption;
        }

        final parsedCards = <ProjectCardItem>[];

        for (final item in itemsList) {
          if (item is Map) {
            final mapItem = Map<String, dynamic>.from(item);
            final opt = CalendarProjectOption.fromJson(mapItem);
            if (opt.id.isNotEmpty && !currentOptions.containsKey(opt.id)) {
              currentOptions[opt.id] = opt;
            }
            parsedCards.add(ProjectCardItem.fromJson(mapItem));
          }
        }

        projects = currentOptions.values.toList();
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
        final newEvents = <int, List<CalendarDayEvent>>{};
        final newDeliveriesMap = <int, List<DeliveryItem>>{};

        List rawDeliveriesList = [];
        Map<String, dynamic>? calendarMap;

        if (res is Map) {
          final dataMap = res['data'] is Map ? res['data'] as Map : res;
          if (dataMap['deliveries'] is List) {
            rawDeliveriesList = dataMap['deliveries'] as List;
          } else if (dataMap['items'] is List) {
            rawDeliveriesList = dataMap['items'] as List;
          }
          if (dataMap['calendar'] is Map) {
            calendarMap = Map<String, dynamic>.from(dataMap['calendar'] as Map);
          } else if (res['calendar'] is Map) {
            calendarMap = Map<String, dynamic>.from(res['calendar'] as Map);
          }
        } else if (res is List) {
          rawDeliveriesList = res;
        }

        // 1. Process array of deliveries from backend
        for (int i = 0; i < rawDeliveriesList.length; i++) {
          final dItem = rawDeliveriesList[i];
          if (dItem is Map) {
            final dMap = Map<String, dynamic>.from(dItem);
            if (dMap['createdAt'] == null && dMap['created_at'] == null) {
              dMap['createdAt'] = DateTime.fromMillisecondsSinceEpoch(1600000000000 + i * 1000).toIso8601String();
            }
            final deliveryObj = DeliveryItem.fromJson(dMap);
            final eventObj = CalendarDayEvent.fromJson(dMap);

            // Extract date to place on calendar day
            final sched = dMap['schedule'] is Map ? dMap['schedule'] as Map : {};
            final rawDateStr = (sched['deliveryDate'] ??
                    sched['arrivalDate'] ??
                    sched['pickupDate'] ??
                    dMap['deliveryDate'] ??
                    dMap['arrivalDate'] ??
                    dMap['date'] ??
                    dMap['createdAt'] ??
                    '').toString();

            DateTime? dt;
            if (rawDateStr.isNotEmpty) {
              dt = DateTime.tryParse(rawDateStr)?.toLocal();
              if (dt == null && rawDateStr.contains('-')) {
                final cleanStr = rawDateStr.split(' ')[0].split('T')[0];
                final parts = cleanStr.split('-');
                if (parts.length == 3) {
                  dt = DateTime(
                    int.parse(parts[0]),
                    int.parse(parts[1]),
                    int.parse(parts[2]),
                  );
                }
              }
            }

            if (dt != null && dt.month == m && dt.year == y) {
              final dayNum = dt.day;
              newEvents.putIfAbsent(dayNum, () => []).add(eventObj);
              newDeliveriesMap.putIfAbsent(dayNum, () => []).add(deliveryObj);
            }
          }
        }

        // 2. Process calendar map if backend returns date-keyed object
        if (calendarMap != null) {
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

            if (dayNum != null &&
                dayNum >= 1 &&
                dayNum <= 31 &&
                itemsList.isNotEmpty) {
              final dayEventList = newEvents.putIfAbsent(dayNum, () => []);
              final dayDeliveryList =
                  newDeliveriesMap.putIfAbsent(dayNum, () => []);

              for (int j = 0; j < itemsList.length; j++) {
                final dItem = itemsList[j];
                if (dItem is Map) {
                  final dMap = Map<String, dynamic>.from(dItem);
                  if (dMap['createdAt'] == null && dMap['created_at'] == null) {
                    dMap['createdAt'] = DateTime.fromMillisecondsSinceEpoch(1600000000000 + j * 1000).toIso8601String();
                  }
                  dayEventList.add(CalendarDayEvent.fromJson(dMap));
                  dayDeliveryList.add(DeliveryItem.fromJson(dMap));
                }
              }
            }
          });
        }

        // Sort each day's deliveries and events with most recent first
        for (final day in newDeliveriesMap.keys) {
          newDeliveriesMap[day]!.sort((a, b) {
            final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
            final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
            if (aTime != bTime) {
              return bTime.compareTo(aTime); // descending: recent first
            }
            return b.id.compareTo(a.id);
          });
        }

        for (final day in newEvents.keys) {
          newEvents[day]!.sort((a, b) {
            final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
            final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
            if (aTime != bTime) {
              return bTime.compareTo(aTime); // descending: recent first
            }
            return 0;
          });
        }

        monthEvents = newEvents;
        dayDeliveriesMap = newDeliveriesMap;
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

  void selectMonthYear(DateTime dt) {
    focusedMonth.value = DateTime(dt.year, dt.month, 1);
    selectedDay.value = dt.day;
    fetchCalendarData();
  }

  void selectProject(String id) {
    String targetId = id;
    if (id.isNotEmpty) {
      for (final p in projects) {
        if (p.id.toLowerCase() == id.toLowerCase() ||
            (p.code.isNotEmpty && p.code.toLowerCase() == id.toLowerCase()) ||
            p.name.toLowerCase() == id.toLowerCase()) {
          targetId = p.id;
          break;
        }
      }
    }
    selectedProjectId.value = targetId;
    dropdownOpen.value = false;
    update([
      AppGetIds.projectDropdown,
      AppGetIds.projectCards,
      AppGetIds.calendarEvents,
    ]);
    fetchCalendarData();
  }

  void selectProjectAndOpenCalendar(ProjectCardItem item) {
    CalendarProjectOption? match;
    for (final p in projects) {
      if (p.id.isNotEmpty && (p.id == item.realLeadId || p.id == item.projectId)) {
        match = p;
        break;
      }
      if (p.code.isNotEmpty && (p.code == item.projectId || p.code == item.realLeadId)) {
        match = p;
        break;
      }
      if (p.name.isNotEmpty && p.name.toLowerCase() == item.title.toLowerCase()) {
        match = p;
        break;
      }
    }

    if (match == null && item.title.isNotEmpty) {
      final newOption = CalendarProjectOption(
        id: item.realLeadId.isNotEmpty ? item.realLeadId : item.projectId,
        name: item.title,
        code: item.projectId,
        imageAsset: item.imageAsset,
      );
      projects.add(newOption);
      match = newOption;
    }

    final idToSelect = match != null && match.id.isNotEmpty
        ? match.id
        : (item.realLeadId.isNotEmpty ? item.realLeadId : item.projectId);

    selectedProjectId.value = idToSelect;
    dropdownOpen.value = false;
    selectedTab.value = ProjectCalendarTab.calendar;

    update([
      AppGetIds.projectCalendarTab,
      AppGetIds.projectDropdown,
      AppGetIds.projectCards,
      AppGetIds.calendarEvents,
    ]);

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

    final currentDate = DateTime(
      focusedMonth.value.year,
      focusedMonth.value.month,
      selectedDay.value.clamp(1, 28),
    );

    final result = await showDialog<AddDeliveryResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddDeliveryDialog(initialDate: currentDate),
    );

    if (result != null && context.mounted) {
      final addedDate = result.date;
      focusedMonth.value = DateTime(addedDate.year, addedDate.month, 1);
      selectedDay.value = addedDate.day;

      // If a project filter was active that doesn't match the new delivery's leadId, clear it
      if (selectedProjectId.value.isNotEmpty &&
          selectedProjectId.value != result.leadId) {
        selectedProjectId.value = '';
      }
      update([AppGetIds.projectDropdown]);

      await fetchCalendarData();

      // Ensure the newly created delivery appears in the calendar and right-hand list
      _ensureDeliveryPresent(result);

      if (context.mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const DeliverySuccessDialog(),
        );
      }
    }
  }

  void _ensureDeliveryPresent(AddDeliveryResult result) {
    final day = result.date.day;
    final currentEvents = List<CalendarDayEvent>.from(monthEvents[day] ?? []);
    final currentDeliveries =
        List<DeliveryItem>.from(dayDeliveriesMap[day] ?? []);

    final eventIdx = currentEvents.indexWhere((e) => e.title == result.title);
    if (eventIdx >= 0) {
      final existing = currentEvents.removeAt(eventIdx);
      currentEvents.insert(0, existing);
    } else {
      currentEvents.insert(
        0,
        CalendarDayEvent(
          title: result.title,
          color: const Color(0xFFEC4899), // Pink dot for scheduled
          createdAt: DateTime.now(),
        ),
      );
    }
    monthEvents[day] = currentEvents;

    final deliveryIdx = currentDeliveries.indexWhere(
      (d) =>
          d.title == result.title ||
          (result.title.isNotEmpty && d.description == result.title),
    );
    if (deliveryIdx >= 0) {
      final existing = currentDeliveries.removeAt(deliveryIdx);
      currentDeliveries.insert(0, existing);
    } else {
      String projectName = 'Project';
      final match = projects.firstWhereOrNull((p) => p.id == result.leadId);
      if (match != null) {
        projectName = match.name;
      }

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final formattedDate =
          '${months[result.date.month - 1]} ${result.date.day}, ${result.date.year}';

      final dData = result.deliveryData?['delivery'] is Map
          ? Map<String, dynamic>.from(result.deliveryData!['delivery'] as Map)
          : (result.deliveryData ?? {});

      final delId =
          dData['_id']?.toString() ??
          dData['id']?.toString() ??
          'del-${DateTime.now().millisecondsSinceEpoch}';
      final delNumber =
          dData['deliveryNumber']?.toString() ?? 'DEL-${result.date.year}';

      currentDeliveries.insert(
        0,
        DeliveryItem(
          id: delId,
          code: delNumber,
          title: result.title,
          projectName: projectName,
          location:
              result.sectionLocation != null &&
                  result.sectionLocation!.isNotEmpty
              ? result.sectionLocation!
              : 'Site Location',
          date: formattedDate,
          status: 'Scheduled',
          statusColor: const Color(0xFFEC4899),
          description: result.description ?? '',
          createdAt: DateTime.now(),
        ),
      );
    }
    dayDeliveriesMap[day] = currentDeliveries;

    update([AppGetIds.calendarEvents]);
  }
}
