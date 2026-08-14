import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../models/project_calendar_models.dart';
import '../widgets/add_delivery_dialog.dart';

class ProjectCalendarController extends GetxController {
  final selectedTab = ProjectCalendarTab.calendar.obs;
  final focusedMonth = DateTime(2025, 1, 1).obs;
  final selectedDay = 19.obs;
  final selectedProjectId = '1'.obs;
  final dropdownOpen = false.obs;

  final projects = const <CalendarProjectOption>[
    CalendarProjectOption(
      id: '1',
      name: 'ABC Warehouse',
      code: 'PRJ-2025-0015',
      imageAsset: AppAssets.thumbBuilding,
    ),
    CalendarProjectOption(
      id: '2',
      name: 'Riverside Office Complex',
      code: 'PRJ-2025-0016',
      imageAsset: AppAssets.thumbBuilding,
    ),
    CalendarProjectOption(
      id: '3',
      name: 'XYZ Building Complex',
      code: 'PRJ-2025-0017',
      imageAsset: AppAssets.thumbBuilding,
    ),
    CalendarProjectOption(
      id: '4',
      name: 'James Court',
      code: 'PRJ-2025-0018',
      imageAsset: AppAssets.thumbBuilding,
    ),
    CalendarProjectOption(
      id: '5',
      name: 'Dupleix Villa',
      code: 'PRJ-2025-0019',
      imageAsset: AppAssets.thumbBuilding,
    ),
  ];

  final Map<int, List<CalendarDayEvent>> monthEvents = {
    5: const [CalendarDayEvent(title: 'Columns D1-D5')],
    8: const [CalendarDayEvent(title: 'Roof Beams')],
    12: const [CalendarDayEvent(title: 'Slab G1')],
    15: const [CalendarDayEvent(title: 'Window Frames')],
    19: const [
      CalendarDayEvent(title: 'Facade Panels', color: AppColors.primaryBlue),
      CalendarDayEvent(title: 'Staircase Structure', color: AppColors.orange),
      CalendarDayEvent(title: 'Overall Project', color: AppColors.chartPink),
    ],
    22: const [CalendarDayEvent(title: 'Column C1-C8')],
    28: const [CalendarDayEvent(title: 'Ceiling Works')],
    30: const [CalendarDayEvent(title: 'Paint & Finishes')],
  };

  final deliveries = const <DeliveryItem>[
    DeliveryItem(
      id: 'DEL-2001',
      title: 'Primary Frame Steel',
      location: 'ABC Logistics Warehouse',
      quantity: '45,000 lbs',
      stagingArea: 'Yard-A',
      arrival: 'Mar 24, 10:00 AM',
      departure: 'Mar 24, 02:00 PM',
    ),
    DeliveryItem(
      id: 'DEL-2002',
      title: 'Secondary Beams',
      location: 'ABC Logistics Warehouse',
      quantity: '28,500 lbs',
      stagingArea: 'Yard-B',
      arrival: 'Mar 24, 11:30 AM',
      departure: 'Mar 24, 03:15 PM',
    ),
  ];

  final projectCards = const <ProjectCardItem>[
    ProjectCardItem(
      title: 'Downtown Office Complex',
      location: 'Construction Site A',
      projectId: 'PRO-2025-0031',
      status: 'Work in Progress',
      statusColor: AppColors.chartYellow,
      priority: 'High',
      priorityColor: AppColors.danger,
      imageAsset: AppAssets.project1,
    ),
    ProjectCardItem(
      title: 'Riverside Apartments',
      location: 'Construction Site B',
      projectId: 'PRO-2025-0032',
      status: 'Completed',
      statusColor: AppColors.success,
      priority: 'Medium',
      priorityColor: AppColors.chartYellow,
      imageAsset: AppAssets.project2,
    ),
    ProjectCardItem(
      title: 'Harbor Logistics Hub',
      location: 'Construction Site C',
      projectId: 'PRO-2025-0033',
      status: 'Work in Progress',
      statusColor: AppColors.chartYellow,
      priority: 'High',
      priorityColor: AppColors.danger,
      imageAsset: AppAssets.project3,
    ),
    ProjectCardItem(
      title: 'Central Mall Expansion',
      location: 'Construction Site D',
      projectId: 'PRO-2025-0034',
      status: 'Canceled',
      statusColor: AppColors.danger,
      priority: 'Medium',
      priorityColor: AppColors.chartYellow,
      imageAsset: AppAssets.project4,
    ),
    ProjectCardItem(
      title: 'North Gate Warehouse',
      location: 'Construction Site E',
      projectId: 'PRO-2025-0035',
      status: 'Completed',
      statusColor: AppColors.success,
      priority: 'High',
      priorityColor: AppColors.danger,
      imageAsset: AppAssets.project5,
    ),
    ProjectCardItem(
      title: 'East Bay Facility',
      location: 'Construction Site F',
      projectId: 'PRO-2025-0036',
      status: 'Work in Progress',
      statusColor: AppColors.chartYellow,
      priority: 'Medium',
      priorityColor: AppColors.chartYellow,
      imageAsset: AppAssets.project6,
    ),
  ];

  CalendarProjectOption get selectedProject =>
      projects.firstWhere((p) => p.id == selectedProjectId.value);

  List<CalendarDayEvent> get selectedDayEvents =>
      monthEvents[selectedDay.value] ?? const [];

  void setTab(ProjectCalendarTab tab) {
    selectedTab.value = tab;
    dropdownOpen.value = false;
  }

  void selectDay(int day) => selectedDay.value = day;

  void previousMonth() {
    final m = focusedMonth.value;
    focusedMonth.value = DateTime(m.year, m.month - 1, 1);
  }

  void nextMonth() {
    final m = focusedMonth.value;
    focusedMonth.value = DateTime(m.year, m.month + 1, 1);
  }

  void goToday() {
    final now = DateTime.now();
    focusedMonth.value = DateTime(now.year, now.month, 1);
    selectedDay.value = now.day;
  }

  void selectProject(String id) {
    selectedProjectId.value = id;
    dropdownOpen.value = false;
  }

  void toggleDropdown() => dropdownOpen.value = !dropdownOpen.value;

  void closeDropdown() => dropdownOpen.value = false;

  Future<void> openAddDelivery(BuildContext context) async {
    dropdownOpen.value = false;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddDeliveryDialog(),
    );
    if (confirmed == true && context.mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const DeliverySuccessDialog(),
      );
    }
  }
}
