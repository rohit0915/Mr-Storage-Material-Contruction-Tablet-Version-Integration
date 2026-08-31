import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/constants/get_builder_ids.dart';
import '../../../app/services/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';

class DashboardController extends GetxController {
  DashboardController({DashboardService? dashboardService, ApiClient? apiClient})
      : _dashboardService = dashboardService ?? Get.put(DashboardService()),
        _apiClient = apiClient ?? Get.find<ApiClient>();

  final DashboardService _dashboardService;
  final ApiClient _apiClient;

  final searchController = TextEditingController();

  final selectedMenu = 'Dashboard'.obs;
  final selectedProject = 'All Projects'.obs;
  final selectedBuilding = 'All Buildings'.obs;
  final selectedStatus = 'All Status'.obs;
  final dateRange = '24 Mar 2025 - 31 Mar 2025'.obs;

  List<String> projectOptions = ['All Projects'];
  List<String> buildingOptions = ['All Buildings'];
  List<String> statusOptions = ['All Status'];

  bool isLoading = false;
  String errorMessage = '';

  void selectMenu(String title) {
    selectedMenu.value = title;
    update([AppGetIds.dashboardFilters]);
  }

  void setProjectFilter(String value) {
    selectedProject.value = value;
    update([AppGetIds.dashboardFilters]);
    fetchDashboardData();
  }

  void setBuildingFilter(String value) {
    selectedBuilding.value = value;
    update([AppGetIds.dashboardFilters]);
    fetchDashboardData();
  }

  void setStatusFilter(String value) {
    selectedStatus.value = value;
    update([AppGetIds.dashboardFilters]);
    fetchDashboardData();
  }

  void setDateRangeFilter(String value) {
    dateRange.value = value;
    update([AppGetIds.dashboardFilters]);
    fetchDashboardData();
  }

  // Dashboard Data Lists updated via GetBuilder ID
  List<MetricItem> metrics = <MetricItem>[
    const MetricItem(
      value: '0',
      title: 'Total Projects',
      subtitle: 'Active Projects',
      icon: Icons.layers_outlined,
      iconBg: Color(0xFFF97316),
      iconColor: Colors.white,
      subtitleColor: AppColors.success,
      up: true,
    ),
    const MetricItem(
      value: '0',
      title: 'On Track',
      subtitle: 'On Schedule',
      icon: Icons.access_time_filled_rounded,
      iconBg: Color(0xFF1E293B),
      iconColor: Colors.white,
      subtitleColor: AppColors.success,
      up: true,
    ),
    const MetricItem(
      value: '0',
      title: 'Delayed',
      subtitle: 'Needs Attention',
      icon: Icons.calendar_month_rounded,
      iconBg: Color(0xFF3B82F6),
      iconColor: Colors.white,
      subtitleColor: AppColors.danger,
      up: false,
    ),
    const MetricItem(
      value: '0',
      title: 'Completed',
      subtitle: 'Finished',
      icon: Icons.assignment_turned_in_rounded,
      iconBg: Color(0xFFEC4899),
      iconColor: Colors.white,
      subtitleColor: AppColors.success,
      up: true,
    ),
    const MetricItem(
      value: '0%',
      title: 'Completion Rate',
      subtitle: 'Average Completion',
      icon: Icons.pie_chart_rounded,
      iconBg: Color(0xFFF97316),
      iconColor: Colors.white,
      subtitleColor: AppColors.success,
      up: true,
    ),
    const MetricItem(
      value: '0',
      title: 'Upcoming Deadlines',
      subtitle: 'Next 30 days',
      icon: Icons.timer_rounded,
      iconBg: Color(0xFFEF4444),
      iconColor: Colors.white,
      subtitleColor: AppColors.success,
      up: true,
    ),
  ];

  List<ChartSlice> deliverySlices = <ChartSlice>[
    const ChartSlice(label: 'Delivered', percent: 0, color: Color(0xFF0D5C75)),
    const ChartSlice(label: 'In Transit', percent: 0, color: Color(0xFFFFB800)),
    const ChartSlice(label: 'Out for Delivery', percent: 0, color: Color(0xFFE91E63)),
    const ChartSlice(label: 'Delayed', percent: 0, color: Color(0xFF0F2C59)),
  ];

  List<ChartSlice> materialSlices = <ChartSlice>[
    const ChartSlice(label: 'Approved', percent: 0, color: Color(0xFF0D5C75)),
    const ChartSlice(label: 'Pending Approval', percent: 0, color: Color(0xFFFFB800)),
    const ChartSlice(label: 'Rejected', percent: 0, color: Color(0xFFE91E63)),
    const ChartSlice(label: 'Urgent Requests', percent: 0, color: Color(0xFF0F2C59)),
  ];

  List<SiteRow> sites = [];
  List<DeadlineItem> deadlines = [];
  List<TimelineStep> timeline = [];
  List<CarrierRow> carriers = [];
  List<FreightSummary> freightSummaries = [];
  List<ActivityItem> activities = [];

  @override
  void onInit() {
    super.onInit();
    fetchFilterOptions();
    fetchDashboardData();
  }

  Future<void> fetchFilterOptions() async {
    try {
      final res = await _apiClient.get(ApiConstants.projects);
      if (res is Map && res['data'] is Map && res['data']['projects'] is List) {
        final list = res['data']['projects'] as List;
        final pOpts = <String>{'All Projects'};
        final bOpts = <String>{'All Buildings'};
        final sOpts = <String>{'All Status'};

        for (final item in list) {
          if (item is Map) {
            final pName = item['projectName']?.toString().trim();
            final jId = item['jobId']?.toString().trim();
            if (jId != null && jId.isNotEmpty && pName != null && pName.isNotEmpty) {
              pOpts.add('$jId: $pName');
            } else if (pName != null && pName.isNotEmpty) {
              pOpts.add(pName);
            }

            final bType = item['buildingType']?.toString().trim();
            if (bType != null && bType.isNotEmpty) {
              final capitalized = bType[0].toUpperCase() + bType.substring(1);
              bOpts.add(capitalized);
            }

            final status = item['lifecycleStatus']?.toString().trim();
            if (status != null && status.isNotEmpty) {
              sOpts.add(status);
            }
          }
        }

        projectOptions = pOpts.toList();
        buildingOptions = bOpts.toList();
        statusOptions = sOpts.toList();
        update([AppGetIds.dashboardFilters]);
      }
    } catch (e) {
      AppLogger.w('Failed to fetch filter options from API: $e', tag: 'DASHBOARD_CTRL');
    }
  }

  Future<void> fetchDashboardData() async {
    isLoading = true;
    errorMessage = '';
    update([
      AppGetIds.dashboardMetrics,
      AppGetIds.deliveryOverview,
      AppGetIds.activeSites,
      AppGetIds.upcomingDeadlines,
      AppGetIds.projectTimeline,
      AppGetIds.recentActivities,
      AppGetIds.freightCarriers,
    ]);

    try {
      final data = await _dashboardService.getDashboardData(
        project: selectedProject.value,
        building: selectedBuilding.value,
        status: selectedStatus.value,
        dateRange: dateRange.value,
      );
      if (data != null) {
        _populateDataFromApi(data);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Dashboard fetch error', error: e, stackTrace: stackTrace, tag: 'DASHBOARD_CTRL');
      errorMessage = 'Failed to load API data.';
    } finally {
      isLoading = false;
      update([
        AppGetIds.dashboardMetrics,
        AppGetIds.deliveryOverview,
        AppGetIds.materialOverview,
        AppGetIds.activeSites,
        AppGetIds.upcomingDeadlines,
        AppGetIds.projectTimeline,
        AppGetIds.recentActivities,
        AppGetIds.freightCarriers,
      ]);
    }
  }

  void _populateDataFromApi(Map<String, dynamic> data) {
    // 1. projectStats -> metrics
    if (data['projectStats'] is Map) {
      final ps = Map<String, dynamic>.from(data['projectStats'] as Map);
      final total = ps['total']?.toString() ?? '0';
      final onTrack = ps['onTrack']?.toString() ?? '0';
      final delayed = ps['delayed']?.toString() ?? '0';
      final completed = ps['completed']?.toString() ?? '0';
      final completionRate = ps['completionRate'] != null
          ? '${ps['completionRate']}%'
          : '0%';
      final upcomingDeadlines = ps['upcomingDeadlines']?.toString() ?? '0';

      final totalNum = (ps['total'] as num?)?.toDouble() ?? 0.0;
      final onTrackNum = (ps['onTrack'] as num?)?.toDouble() ?? 0.0;
      final delayedNum = (ps['delayed'] as num?)?.toDouble() ?? 0.0;
      final completedNum = (ps['completed'] as num?)?.toDouble() ?? 0.0;

      final onTrackPct = totalNum > 0 ? ((onTrackNum / totalNum) * 100).toStringAsFixed(1) : '0';
      final delayedPct = totalNum > 0 ? ((delayedNum / totalNum) * 100).toStringAsFixed(1) : '0';
      final completedPct = totalNum > 0 ? ((completedNum / totalNum) * 100).toStringAsFixed(2) : '0';

      metrics = [
        MetricItem(
          value: total,
          title: 'Total Projects',
          subtitle: 'Active Projects',
          icon: Icons.layers_outlined,
          iconBg: const Color(0xFFF97316),
          iconColor: Colors.white,
          subtitleColor: AppColors.success,
          up: true,
        ),
        MetricItem(
          value: onTrack,
          title: 'On Track',
          subtitle: '$onTrackPct% on track',
          icon: Icons.access_time_filled_rounded,
          iconBg: const Color(0xFF1E293B),
          iconColor: Colors.white,
          subtitleColor: AppColors.success,
          up: true,
        ),
        MetricItem(
          value: delayed,
          title: 'Delayed',
          subtitle: '$delayedPct% delayed',
          icon: Icons.calendar_month_rounded,
          iconBg: const Color(0xFF3B82F6),
          iconColor: Colors.white,
          subtitleColor: AppColors.danger,
          up: false,
        ),
        MetricItem(
          value: completed,
          title: 'Completed',
          subtitle: '$completedPct% completed',
          icon: Icons.assignment_turned_in_rounded,
          iconBg: const Color(0xFFEC4899),
          iconColor: Colors.white,
          subtitleColor: AppColors.success,
          up: true,
        ),
        MetricItem(
          value: completionRate,
          title: 'Completion Rate',
          subtitle: 'Average Completion',
          icon: Icons.pie_chart_rounded,
          iconBg: const Color(0xFFF97316),
          iconColor: Colors.white,
          subtitleColor: AppColors.success,
          up: true,
        ),
        MetricItem(
          value: upcomingDeadlines,
          title: 'Upcoming Deadlines',
          subtitle: 'Next 30 days',
          icon: Icons.timer_rounded,
          iconBg: const Color(0xFFEF4444),
          iconColor: Colors.white,
          subtitleColor: AppColors.success,
          up: true,
        ),
      ];
      update([AppGetIds.dashboardMetrics]);
    }

    // 2. deliveryOverview -> deliverySlices
    if (data['deliveryOverview'] is Map) {
      final doMap = Map<String, dynamic>.from(data['deliveryOverview'] as Map);
      final delivered = (doMap['delivered'] as num?)?.toDouble() ?? 0.0;
      final inTransit = (doMap['inTransit'] as num?)?.toDouble() ?? 0.0;
      final outForDelivery = (doMap['outForDelivery'] as num?)?.toDouble() ?? 0.0;
      final delayed = (doMap['delayed'] as num?)?.toDouble() ?? 0.0;

      deliverySlices = [
        ChartSlice(label: 'Delivered', percent: delivered, color: const Color(0xFF0D5C75)),
        ChartSlice(label: 'In Transit', percent: inTransit, color: const Color(0xFFFFB800)),
        ChartSlice(label: 'Out for Delivery', percent: outForDelivery, color: const Color(0xFFE91E63)),
        ChartSlice(label: 'Delayed', percent: delayed, color: const Color(0xFF0F2C59)),
      ];
      update([AppGetIds.deliveryOverview]);
    }

    // 3. materialOverview -> materialSlices
    if (data['materialOverview'] is Map) {
      final moMap = Map<String, dynamic>.from(data['materialOverview'] as Map);
      final approved = (moMap['approved'] as num?)?.toDouble() ?? 0.0;
      final pending = (moMap['pending'] as num?)?.toDouble() ?? 0.0;
      final rejected = (moMap['rejected'] as num?)?.toDouble() ?? 0.0;
      final urgent = (moMap['urgent'] as num?)?.toDouble() ?? 0.0;

      materialSlices = [
        ChartSlice(label: 'Approved', percent: approved, color: const Color(0xFF0D5C75)),
        ChartSlice(label: 'Pending Approval', percent: pending, color: const Color(0xFFFFB800)),
        ChartSlice(label: 'Rejected', percent: rejected, color: const Color(0xFFE91E63)),
        ChartSlice(label: 'Urgent Requests', percent: urgent, color: const Color(0xFF0F2C59)),
      ];
      update([AppGetIds.materialOverview]);
    }

    // 4. upcomingDeadlines List
    if (data['upcomingDeadlines'] is List) {
      final list = data['upcomingDeadlines'] as List;
      final parsed = <DeadlineItem>[];
      for (final item in list) {
        if (item is Map) {
          parsed.add(DeadlineItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      deadlines = parsed;
      update([AppGetIds.upcomingDeadlines]);
    }

    // 5. recentDeliveries List -> sites
    if (data['recentDeliveries'] is List) {
      final list = data['recentDeliveries'] as List;
      final parsed = <SiteRow>[];
      for (final item in list) {
        if (item is Map) {
          parsed.add(SiteRow.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      sites = parsed;
      update([AppGetIds.activeSites]);
    }

    // 6. taskOverview / timeline
    if (data['taskOverview'] is List && (data['taskOverview'] as List).isNotEmpty) {
      final list = data['taskOverview'] as List;
      final parsed = <TimelineStep>[];
      for (final item in list) {
        if (item is Map) {
          parsed.add(TimelineStep.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      timeline = parsed;
    } else {
      // Default 5 Overall Construction Project Timeline steps matching Web design
      timeline = const [
        TimelineStep(
          title: 'Planning',
          date: '-',
          status: 'COMPLETED',
          statusColor: AppColors.badgeGreen,
          done: true,
        ),
        TimelineStep(
          title: 'Design',
          date: '-',
          status: 'COMPLETED',
          statusColor: AppColors.badgeGreen,
          done: true,
        ),
        TimelineStep(
          title: 'Procurement',
          date: '-',
          status: 'COMPLETED',
          statusColor: AppColors.badgeGreen,
          done: true,
        ),
        TimelineStep(
          title: 'Execution',
          date: '-',
          status: 'INPROGRESS',
          statusColor: Color(0xFF3B82F6),
          done: false,
          inProgress: true,
        ),
        TimelineStep(
          title: 'Handover',
          date: '-',
          status: 'UPCOMING',
          statusColor: Color(0xFFEC4899),
          done: false,
        ),
      ];
    }
    update([AppGetIds.projectTimeline]);

    // 7. recentActivities
    if (data['recentActivities'] is List) {
      final list = data['recentActivities'] as List;
      final parsed = <ActivityItem>[];
      for (final item in list) {
        if (item is Map) {
          parsed.add(ActivityItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      activities = parsed;
      update([AppGetIds.recentActivities]);
    }

    // 8. carriers
    if (data['carriers'] is List) {
      final list = data['carriers'] as List;
      final parsed = <CarrierRow>[];
      for (final item in list) {
        if (item is Map) {
          parsed.add(CarrierRow.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      carriers = parsed;
      update([AppGetIds.freightCarriers]);
    }
  }

  void resetFilters() {
    selectedProject.value = 'All Projects';
    selectedBuilding.value = 'All Buildings';
    selectedStatus.value = 'All Status';
    dateRange.value = '24 Mar 2025 - 31 Mar 2025';
    update([AppGetIds.dashboardFilters]);
    AppToast.showInfo(
      title: 'Filters Reset',
      description: 'Dashboard filters have been reset to default values.',
    );
    fetchDashboardData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}


