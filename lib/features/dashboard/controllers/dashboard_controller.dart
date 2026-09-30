import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/constants/app_assets.dart';
import '../../../app/constants/get_builder_ids.dart';
import '../../../app/services/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';

class DashboardController extends GetxController {
  DashboardController({
    DashboardService? dashboardService,
    ApiClient? apiClient,
  }) : _dashboardService = dashboardService ?? Get.put(DashboardService()),
       _apiClient = apiClient ?? Get.find<ApiClient>();

  final DashboardService _dashboardService;
  final ApiClient _apiClient;

  final searchController = TextEditingController();

  final selectedMenu = 'Dashboard'.obs;
  final selectedProject = 'All Projects'.obs;
  final selectedBuilding = 'All Buildings'.obs;
  final selectedStatus = 'All Status'.obs;
  final dateRange = 'Date: Default (Today)'.obs;

  final _projectIds = <String, String>{'All Projects': ''};
  final _buildingIds = <String, String>{'All Buildings': ''};
  final _statusValues = <String, String>{'All Status': ''};
  String? _fromDate;
  String? _toDate;

  final projectOptions = <String>['All Projects'].obs;
  final buildingOptions = <String>['All Buildings'].obs;
  final statusOptions = <String>['All Status'].obs;

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

  void setDateRangeFilter(DateTimeRange value) {
    dateRange.value =
        '${DateFormat('dd MMM yyyy').format(value.start)} - '
        '${DateFormat('dd MMM yyyy').format(value.end)}';
    _fromDate = DateFormat('yyyy-MM-dd').format(value.start);
    _toDate = DateFormat('yyyy-MM-dd').format(value.end);
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
      subtitle: '0.0% on track',
      icon: Icons.access_time_filled_rounded,
      iconBg: Color(0xFF1E293B),
      iconColor: Colors.white,
      subtitleColor: AppColors.success,
      up: true,
    ),
    const MetricItem(
      value: '0',
      title: 'Delayed',
      subtitle: '0.0% delayed',
      icon: Icons.calendar_month_rounded,
      iconBg: Color(0xFF3B82F6),
      iconColor: Colors.white,
      subtitleColor: AppColors.danger,
      up: false,
    ),
    const MetricItem(
      value: '0',
      title: 'Completed',
      subtitle: '0.00% completed',
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
    const ChartSlice(
      label: 'Out for Delivery',
      percent: 0,
      color: Color(0xFFE91E63),
    ),
    const ChartSlice(label: 'Delayed', percent: 0, color: Color(0xFF0F2C59)),
  ];

  List<ChartSlice> materialSlices = <ChartSlice>[
    const ChartSlice(label: 'Approved', percent: 0, color: Color(0xFF0D5C75)),
    const ChartSlice(
      label: 'Pending Approval',
      percent: 0,
      color: Color(0xFFFFB800),
    ),
    const ChartSlice(label: 'Rejected', percent: 0, color: Color(0xFFE91E63)),
    const ChartSlice(
      label: 'Urgent Requests',
      percent: 0,
      color: Color(0xFF0F2C59),
    ),
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
      final res = await _apiClient.get(ApiConstants.dashboardFilters);
      if (res is Map && res['data'] is Map) {
        final data = res['data'] as Map;
        final pOpts = <String>['All Projects'];
        final bOpts = <String>['All Buildings'];
        final sOpts = <String>['All Status'];
        _projectIds
          ..clear()
          ..['All Projects'] = '';
        _buildingIds
          ..clear()
          ..['All Buildings'] = '';
        _statusValues
          ..clear()
          ..['All Status'] = '';

        for (final item in data['projects'] as List? ?? const []) {
          if (item is Map) {
            final pName = item['projectName']?.toString().trim();
            final jId = item['jobId']?.toString().trim();
            final id = item['_id']?.toString();
            if (pName != null && pName.isNotEmpty && id != null) {
              final label = jId == null || jId.isEmpty
                  ? pName
                  : '$pName ($jId)';
              pOpts.add(label);
              _projectIds[label] = id;
            }
          }
        }

        for (final item in data['buildings'] as List? ?? const []) {
          if (item is Map && item['_id'] != null) {
            final name = item['name']?.toString().trim().isNotEmpty == true
                ? item['name'].toString().trim()
                : 'Building ${item['buildingNumber'] ?? ''}'.trim();
            var label = name;
            var duplicate = 2;
            while (_buildingIds.containsKey(label)) {
              label = '$name ($duplicate)';
              duplicate++;
            }
            bOpts.add(label);
            _buildingIds[label] = item['_id'].toString();
          }
        }

        for (final value in data['statuses'] as List? ?? const []) {
          final raw = value.toString();
          final label = raw
              .split('_')
              .map(
                (part) => part.isEmpty
                    ? part
                    : '${part[0].toUpperCase()}${part.substring(1)}',
              )
              .join(' ');
          sOpts.add(label);
          _statusValues[label] = raw;
        }

        projectOptions.assignAll(pOpts);
        buildingOptions.assignAll(bOpts);
        statusOptions.assignAll(sOpts);
        update([AppGetIds.dashboardFilters]);
      }
    } catch (e) {
      AppLogger.w(
        'Failed to fetch filter options from API: $e',
        tag: 'DASHBOARD_CTRL',
      );
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
        projectId: _projectIds[selectedProject.value],
        buildingId: _buildingIds[selectedBuilding.value],
        status: _statusValues[selectedStatus.value],
        fromDate: _fromDate,
        toDate: _toDate,
      );
      if (data != null) {
        _populateDataFromApi(data);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Dashboard fetch error',
        error: e,
        stackTrace: stackTrace,
        tag: 'DASHBOARD_CTRL',
      );
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

  double _parseNum(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
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

      metrics = [
        MetricItem(
          value: total,
          title: 'Total Projects',
          subtitle: '${ps['totalChangePctVsYesterday'] ?? 0}% by Yesterday',
          icon: Icons.layers_outlined,
          iconBg: const Color(0xFFF97316),
          iconColor: Colors.white,
          subtitleColor: AppColors.success,
          up: true,
        ),
        MetricItem(
          value: onTrack,
          title: 'On Track',
          subtitle: '${ps['onTrackPct'] ?? 0}% on track',
          icon: Icons.access_time_filled_rounded,
          iconBg: const Color(0xFF1E293B),
          iconColor: Colors.white,
          subtitleColor: AppColors.success,
          up: true,
        ),
        MetricItem(
          value: delayed,
          title: 'Delayed',
          subtitle: '${ps['delayedPct'] ?? 0}% delayed',
          icon: Icons.calendar_month_rounded,
          iconBg: const Color(0xFF3B82F6),
          iconColor: Colors.white,
          subtitleColor: AppColors.danger,
          up: false,
        ),
        MetricItem(
          value: completed,
          title: 'Completed',
          subtitle: '${ps['completedPct'] ?? 0}% completed',
          icon: Icons.assignment_turned_in_rounded,
          iconBg: const Color(0xFFEC4899),
          iconColor: Colors.white,
          subtitleColor: AppColors.success,
          up: true,
        ),
        MetricItem(
          value: completionRate,
          title: 'Completion Rate',
          subtitle:
              ps['completionRateLabel']?.toString() ?? 'Average Completion',
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
      final delivered = _parseNum(doMap['delivered']);
      final inTransit = _parseNum(doMap['inTransit']);
      final outForDelivery = _parseNum(doMap['outForDelivery']);
      final delayed = _parseNum(doMap['delayed']);

      deliverySlices = [
        ChartSlice(
          label: 'Delivered',
          percent: delivered,
          color: const Color(0xFF0D5C75),
        ),
        ChartSlice(
          label: 'In Transit',
          percent: inTransit,
          color: const Color(0xFFFFB800),
        ),
        ChartSlice(
          label: 'Out for Delivery',
          percent: outForDelivery,
          color: const Color(0xFFE91E63),
        ),
        ChartSlice(
          label: 'Delayed',
          percent: delayed,
          color: const Color(0xFF0F2C59),
        ),
      ];
      update([AppGetIds.deliveryOverview]);
    }

    // 3. materialOverview -> materialSlices
    Map<String, dynamic>? moMap;
    if (data['materialOverview'] is Map) {
      moMap = Map<String, dynamic>.from(data['materialOverview'] as Map);
    } else if (data['materialRequestOverview'] is Map) {
      moMap = Map<String, dynamic>.from(data['materialRequestOverview'] as Map);
    } else if (data['materialRequests'] is Map) {
      moMap = Map<String, dynamic>.from(data['materialRequests'] as Map);
    } else if (data['materialStats'] is Map) {
      moMap = Map<String, dynamic>.from(data['materialStats'] as Map);
    }

    if (moMap != null) {
      final approved = _parseNum(moMap['approved']);
      final pending = _parseNum(
        moMap['pendingApproval'] ??
            moMap['pending'] ??
            moMap['pending_approval'],
      );
      final rejected = _parseNum(moMap['rejected']);
      final urgent = _parseNum(moMap['urgentRequests'] ?? moMap['urgent']);

      materialSlices = [
        ChartSlice(
          label: 'Approved',
          percent: approved,
          color: const Color(0xFF0D5C75),
        ),
        ChartSlice(
          label: 'Pending Approval',
          percent: pending,
          color: const Color(0xFFFFB800),
        ),
        ChartSlice(
          label: 'Rejected',
          percent: rejected,
          color: const Color(0xFFE91E63),
        ),
        ChartSlice(
          label: 'Urgent Requests',
          percent: urgent,
          color: const Color(0xFF0F2C59),
        ),
      ];
      update([AppGetIds.materialOverview]);
    } else {
      final rootPending = _parseNum(
        data['pendingApproval'] ?? data['pendingRequests'] ?? data['pending'],
      );
      final rootApproved = _parseNum(
        data['approvedRequests'] ?? data['approved'],
      );
      final rootRejected = _parseNum(
        data['rejectedRequests'] ?? data['rejected'],
      );
      final rootUrgent = _parseNum(data['urgentRequests'] ?? data['urgent']);

      materialSlices = [
        ChartSlice(
          label: 'Approved',
          percent: rootApproved,
          color: const Color(0xFF0D5C75),
        ),
        ChartSlice(
          label: 'Pending Approval',
          percent: rootPending,
          color: const Color(0xFFFFB800),
        ),
        ChartSlice(
          label: 'Rejected',
          percent: rootRejected,
          color: const Color(0xFFE91E63),
        ),
        ChartSlice(
          label: 'Urgent Requests',
          percent: rootUrgent,
          color: const Color(0xFF0F2C59),
        ),
      ];
      update([AppGetIds.materialOverview]);

      // Asynchronously query material-requests API to count exact pending approval items
      _fetchMaterialRequestsSummary();
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
      deadlines = parsed.isEmpty ? _webFallbackDeadlines : parsed;
    } else {
      deadlines = _webFallbackDeadlines;
      update([AppGetIds.upcomingDeadlines]);
    }

    // 5. activeSites
    if (data['activeSites'] is List) {
      final list = data['activeSites'] as List;
      final parsed = <SiteRow>[];
      for (final item in list) {
        if (item is Map) {
          parsed.add(SiteRow.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      sites = parsed;
    } else {
      sites = [];
    }
    update([AppGetIds.activeSites]);

    // 6. timeline
    if (data['projectTimelineOverall'] is List) {
      final list = data['projectTimelineOverall'] as List;
      final parsed = <TimelineStep>[];
      for (final item in list) {
        if (item is Map) {
          parsed.add(TimelineStep.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      timeline = parsed;
    } else {
      timeline = [];
    }
    update([AppGetIds.projectTimeline]);

    // 7. recentActivities
    if (data['recentActivity'] is List) {
      final list = data['recentActivity'] as List;
      final parsed = <ActivityItem>[];
      for (final item in list) {
        if (item is Map) {
          parsed.add(ActivityItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      activities = parsed.take(5).toList();
    } else if (data['recentDeliveries'] is List) {
      final list = data['recentDeliveries'] as List;
      final parsed = <ActivityItem>[];
      for (final item in list) {
        if (item is Map) {
          parsed.add(ActivityItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      activities = parsed.take(5).toList();
    } else {
      activities = [];
    }
    update([AppGetIds.recentActivities]);

    // 8. carriers
    if (data['freightCarriers'] is Map &&
        data['freightCarriers']['rows'] is List) {
      final list = data['freightCarriers']['rows'] as List;
      final parsed = <CarrierRow>[];
      for (final item in list) {
        if (item is Map) {
          parsed.add(CarrierRow.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      carriers = parsed.isEmpty ? _webFallbackCarriers : parsed;
    } else {
      carriers = _webFallbackCarriers;
    }
    final totals = data['freightCarriers'] is Map
        ? data['freightCarriers']['totals']
        : null;
    freightSummaries = totals is Map
        ? [
            FreightSummary(
              value: '${totals['totalLoadsToday'] ?? 0}',
              label: 'Total Loads Today',
              iconAsset: AppAssets.iconTruckGreen,
              iconBg: const Color(0xFFF97316),
            ),
            FreightSummary(
              value: '${totals['onTime'] ?? 0} (${totals['onTimePct'] ?? 0}%)',
              label: 'On time',
              iconAsset: AppAssets.iconTruckGreen,
              iconBg: const Color(0xFFF97316),
            ),
            FreightSummary(
              value:
                  '${totals['delayed'] ?? 0} (${totals['delayedPct'] ?? 0}%)',
              label: 'Delayed',
              iconAsset: AppAssets.iconTruckGreen,
              iconBg: const Color(0xFFF97316),
            ),
          ]
        : [];
    update([AppGetIds.freightCarriers]);
  }

  Future<void> _fetchMaterialRequestsSummary() async {
    try {
      final res = await _apiClient.get(
        ApiConstants.materialRequests,
        queryParams: const {'limit': '100'},
      );
      List list = [];
      if (res is List) {
        list = res;
      } else if (res is Map) {
        if (res['data'] is List) {
          list = res['data'];
        } else if (res['data'] is Map && res['data']['requests'] is List) {
          list = res['data']['requests'];
        } else if (res['requests'] is List) {
          list = res['requests'];
        }
      }

      double pendingCount = 0;
      double approvedCount = 0;
      double rejectedCount = 0;
      double urgentCount = 0;

      for (final item in list) {
        if (item is Map) {
          final st = (item['status'] ?? item['requestStatus'] ?? '')
              .toString()
              .toLowerCase();
          final prio = (item['priority'] ?? item['priorityLevel'] ?? '')
              .toString()
              .toLowerCase();
          if (prio.contains('urgent') || prio.contains('high')) {
            urgentCount++;
          }
          if (st.contains('pend') ||
              st.contains('submit') ||
              st.contains('review') ||
              st == 'pending') {
            pendingCount++;
          } else if (st.contains('appr') || st == 'approved') {
            approvedCount++;
          } else if (st.contains('rej') || st == 'rejected') {
            rejectedCount++;
          }
        }
      }

      if (pendingCount > 0 ||
          approvedCount > 0 ||
          rejectedCount > 0 ||
          urgentCount > 0) {
        materialSlices = [
          ChartSlice(
            label: 'Approved',
            percent: approvedCount,
            color: const Color(0xFF0D5C75),
          ),
          ChartSlice(
            label: 'Pending Approval',
            percent: pendingCount,
            color: const Color(0xFFFFB800),
          ),
          ChartSlice(
            label: 'Rejected',
            percent: rejectedCount,
            color: const Color(0xFFE91E63),
          ),
          ChartSlice(
            label: 'Urgent Requests',
            percent: urgentCount,
            color: const Color(0xFF0F2C59),
          ),
        ];
        update([AppGetIds.materialOverview]);
      }
    } catch (e) {
      AppLogger.w(
        'Failed to fetch material requests summary: $e',
        tag: 'DASHBOARD_CTRL',
      );
    }
  }

  void resetFilters() {
    selectedProject.value = 'All Projects';
    selectedBuilding.value = 'All Buildings';
    selectedStatus.value = 'All Status';
    dateRange.value = 'Date: Default (Today)';
    _fromDate = null;
    _toDate = null;
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

const _webFallbackDeadlines = <DeadlineItem>[
  DeadlineItem(
    project: 'Downtown Office Complex',
    location: 'Site A',
    date: 'May 25, 2025',
    daysLeft: '6 Days Left',
  ),
  DeadlineItem(
    project: 'Residential Tower A',
    location: 'Site A',
    date: 'May 25, 2025',
    daysLeft: '6 Days Left',
  ),
  DeadlineItem(
    project: 'Downtown Office Complex',
    location: 'Site A',
    date: 'May 25, 2025',
    daysLeft: '6 Days Left',
  ),
  DeadlineItem(
    project: 'Residential Tower A',
    location: 'Site A',
    date: 'May 25, 2025',
    daysLeft: '6 Days Left',
  ),
  DeadlineItem(
    project: 'Downtown Office Complex',
    location: 'Site A',
    date: 'May 25, 2025',
    daysLeft: '6 Days Left',
  ),
];

const _webFallbackCarriers = <CarrierRow>[
  CarrierRow(
    carrier: 'Roadking Logistics',
    loadsToday: '12',
    onTime: '10',
    delayed: '2',
    priority: 'On Time',
    priorityColor: AppColors.badgeGreen,
  ),
  CarrierRow(
    carrier: 'Swift Transport',
    loadsToday: '8',
    onTime: '8',
    delayed: '0',
    priority: 'On Time',
    priorityColor: AppColors.badgeGreen,
  ),
  CarrierRow(
    carrier: 'Global Freight Lines',
    loadsToday: '5',
    onTime: '3',
    delayed: '2',
    priority: 'Delayed',
    priorityColor: AppColors.badgeRed,
  ),
  CarrierRow(
    carrier: 'Eagle Freight',
    loadsToday: '6',
    onTime: '6',
    delayed: '2',
    priority: 'On Time',
    priorityColor: AppColors.badgeGreen,
  ),
  CarrierRow(
    carrier: 'Prime Freight',
    loadsToday: '3',
    onTime: '3',
    delayed: '1',
    priority: 'Delayed',
    priorityColor: AppColors.badgeRed,
  ),
];
