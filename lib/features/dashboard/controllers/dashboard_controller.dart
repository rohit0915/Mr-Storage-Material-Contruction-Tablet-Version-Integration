import 'package:file_picker/file_picker.dart';
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
import '../services/dashboard_report.dart';

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
  final dateRange = 'All dates'.obs;

  final _projectIds = <String, String>{'All Projects': ''};
  final _allBuildings = <Map<String, dynamic>>[];
  final _buildingIds = <String, String>{'All Buildings': ''};
  final _statusValues = <String, String>{'All Status': ''};
  String? _fromDate;
  String? _toDate;

  final projectOptions = <String>['All Projects'].obs;
  final buildingOptions = <String>['All Buildings'].obs;
  final statusOptions = <String>['All Status'].obs;

  bool isLoading = false;
  bool isExporting = false;
  bool hasLoadedData = false;
  String errorMessage = '';
  int _requestVersion = 0;
  double deliveryTotal = 0;
  double materialTotal = 0;
  double materialPending = 0;

  void selectMenu(String title) {
    selectedMenu.value = title;
    update([AppGetIds.dashboardFilters]);
  }

  void setProjectFilter(String value) {
    selectedProject.value = value;
    selectedBuilding.value = 'All Buildings';
    _refreshBuildingOptions();
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

  void setDateRangeFilter(DateTimeRange? value) {
    if (value == null) {
      dateRange.value = 'All dates';
      _fromDate = null;
      _toDate = null;
      update([AppGetIds.dashboardFilters]);
      fetchDashboardData();
      return;
    }
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
              final baseLabel = jId == null || jId.isEmpty
                  ? pName
                  : '$pName ($jId)';
              var label = baseLabel;
              var duplicate = 2;
              while (_projectIds.containsKey(label)) {
                label = '$baseLabel ($duplicate)';
                duplicate++;
              }
              pOpts.add(label);
              _projectIds[label] = id;
            }
          }
        }

        _allBuildings
          ..clear()
          ..addAll(
            (data['buildings'] as List? ?? []).whereType<Map>().map(
              (b) => Map<String, dynamic>.from(b),
            ),
          );

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
        _refreshBuildingOptions();
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

  void _refreshBuildingOptions() {
    final projectId = _projectIds[selectedProject.value] ?? '';
    _buildingIds
      ..clear()
      ..['All Buildings'] = '';
    for (final item in _allBuildings) {
      if (projectId.isNotEmpty && item['leadId']?.toString() != projectId) {
        continue;
      }
      final id = item['_id']?.toString() ?? '';
      if (id.isEmpty) continue;
      final name = (item['name'] ?? 'Building ${item['buildingNumber'] ?? ''}')
          .toString();
      var label = name;
      var suffix = 2;
      while (_buildingIds.containsKey(label)) {
        label = '$name (${suffix++})';
      }
      _buildingIds[label] = id;
    }
    buildingOptions.assignAll(_buildingIds.keys);
  }

  Future<void> fetchDashboardData() async {
    final requestVersion = ++_requestVersion;
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
      if (requestVersion != _requestVersion) return;
      if (data == null) throw const FormatException('Missing dashboard data');
      _populateDataFromApi(data);
      hasLoadedData = true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Dashboard fetch error',
        error: e,
        stackTrace: stackTrace,
        tag: 'DASHBOARD_CTRL',
      );
      if (requestVersion != _requestVersion) return;
      errorMessage = 'Unable to load dashboard. Please retry.';
    } finally {
      if (requestVersion == _requestVersion) {
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
  }

  double _parseNum(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  void _populateDataFromApi(Map<String, dynamic> data) {
    // Clear sections before applying a new API snapshot.
    metrics = [];
    deliverySlices = [];
    materialSlices = [];
    deliveryTotal = 0;
    materialTotal = 0;
    materialPending = 0;
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
      deliveryTotal = _parseNum(
        doMap['total'] ??
            doMap['totalDeliveries'] ??
            (delivered + inTransit + outForDelivery + delayed),
      );

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
      materialPending = pending;
      materialTotal = _parseNum(
        moMap['total'] ??
            moMap['totalRequests'] ??
            (approved + pending + rejected),
      );

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
    } else if ([
      'pendingApproval',
      'pendingRequests',
      'pending',
      'approvedRequests',
      'approved',
      'rejectedRequests',
      'rejected',
      'urgentRequests',
      'urgent',
    ].any(data.containsKey)) {
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
      materialPending = rootPending;
      materialTotal = rootApproved + rootPending + rootRejected;

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
    } else {
      deadlines = [];
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
      carriers = parsed;
    } else {
      carriers = [];
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

  Future<void> exportReport() async {
    if (isExporting || isLoading) return;
    if (!hasLoadedData || errorMessage.isNotEmpty) {
      AppToast.showWarning(
        title: 'Report unavailable',
        description: 'Load the dashboard successfully before exporting.',
      );
      return;
    }
    isExporting = true;
    update([AppGetIds.dashboardMetrics]);
    try {
      // Capture the displayed API snapshot and its filters before opening the dialog.
      final rows = <List<Object?>>[
        ['Construction Dashboard Report'],
        ['Generated', DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())],
        ['Project', selectedProject.value],
        ['Building', selectedBuilding.value],
        ['Status', selectedStatus.value],
        ['Date range', dateRange.value],
        [],
        ['Project Metrics'],
        ['Metric', 'Value', 'Details'],
        ...metrics.map((m) => [m.title, m.value, m.subtitle]),
        [],
        ['Delivery Overview'],
        ['Total deliveries', deliveryTotal],
        ['Status', 'Count'],
        ...deliverySlices.map((s) => [s.label, s.percent]),
        [],
        ['Material Request Overview'],
        ['Total requests', materialTotal],
        ['Status / Priority', 'Count'],
        ...materialSlices.map((s) => [s.label, s.percent]),
        [],
        ['Active Construction Sites'],
        ['Project', 'Location', 'Progress (%)', 'Deadline', 'Delivery Status'],
        ...sites.map(
          (s) => [
            s.project,
            s.location,
            (s.progress * 100).toStringAsFixed(1),
            s.deadline,
            s.status,
          ],
        ),
        [],
        ['Upcoming Project Deadlines'],
        ['Project', 'Location', 'Deadline', 'Days Left'],
        ...deadlines.map((d) => [d.project, d.location, d.date, d.daysLeft]),
        [],
        ['Project Timeline'],
        ['Stage', 'Date', 'Status'],
        ...timeline.map((t) => [t.title, t.date, t.status]),
        [],
        ['Freight Carriers & Deliveries'],
        ['Carrier', 'Loads Today', 'On Time', 'Delayed', 'Priority'],
        ...carriers.map(
          (c) => [c.carrier, c.loadsToday, c.onTime, c.delayed, c.priority],
        ),
        ...freightSummaries.map((s) => [s.label, s.value]),
        [],
        ['Recent Activity'],
        ['Activity', 'Time'],
        ...activities.map((a) => [a.title, a.time]),
      ];
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Save dashboard report',
        fileName:
            'construction_dashboard_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
        mimeType: 'text/csv',
        bytes: encodeDashboardCsv(rows),
      );
      if (saved != null) {
        AppToast.showSuccess(
          title: 'Report exported',
          description: 'Dashboard CSV report saved successfully.',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Dashboard export failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'DASHBOARD_CTRL',
      );
      AppToast.showError(
        title: 'Export failed',
        description: 'Unable to save the report. Please try again.',
      );
    } finally {
      isExporting = false;
      update([AppGetIds.dashboardMetrics]);
    }
  }

  void resetFilters() {
    selectedProject.value = 'All Projects';
    selectedBuilding.value = 'All Buildings';
    _refreshBuildingOptions();
    selectedStatus.value = 'All Status';
    dateRange.value = 'All dates';
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
