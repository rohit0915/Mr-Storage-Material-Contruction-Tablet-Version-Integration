import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../models/dashboard_models.dart';

class DashboardController extends GetxController {
  final searchController = TextEditingController();

  final selectedMenu = 'Dashboard'.obs;
  final selectedProject = 'All Projects'.obs;
  final selectedBuilding = 'All Buildings'.obs;
  final selectedStatus = 'All Status'.obs;
  final dateRange = '24 Mar 2025 - 31 Mar 2025'.obs;

  void selectMenu(String title) {
    selectedMenu.value = title;
  }

  // Same clock/stat icon, different solid Figma colors per card
  final metrics = <MetricItem>[
    const MetricItem(
      value: '18',
      title: 'Total Projects',
      subtitle: '15% by Yesterday',
      iconAsset: AppAssets.iconStatClock,
      iconBg: AppColors.chartYellow,
      iconColor: Colors.white,
      subtitleColor: AppColors.success,
      up: true,
    ),
    const MetricItem(
      value: '12',
      title: 'On Track',
      subtitle: '68.2%',
      iconAsset: AppAssets.iconStatClock,
      iconBg: AppColors.chartTeal,
      iconColor: Colors.white,
      subtitleColor: AppColors.success,
      up: true,
    ),
    const MetricItem(
      value: '4',
      title: 'Delayed',
      subtitle: '22.2%',
      iconAsset: AppAssets.iconStatClock,
      iconBg: Color(0xFF5B9BD5),
      iconColor: Colors.white,
      subtitleColor: AppColors.danger,
      up: false,
    ),
    const MetricItem(
      value: '2',
      title: 'Completed',
      subtitle: '11.11%',
      iconAsset: AppAssets.iconStatClock,
      iconBg: AppColors.chartPink,
      iconColor: Colors.white,
      subtitleColor: AppColors.danger,
      up: false,
    ),
    const MetricItem(
      value: '72%',
      title: 'Completion Rate',
      subtitle: 'Average Completion',
      iconAsset: AppAssets.iconStatClock,
      iconBg: Color(0xFFE67E22),
      iconColor: Colors.white,
      subtitleColor: AppColors.success,
      up: true,
    ),
    const MetricItem(
      value: '5',
      title: 'Upcoming Deadlines',
      subtitle: 'Next 30 days',
      iconAsset: AppAssets.iconStatClock,
      iconBg: AppColors.danger,
      iconColor: Colors.white,
      subtitleColor: AppColors.success,
      up: true,
    ),
  ];

  final deliverySlices = const <ChartSlice>[
    ChartSlice(label: 'Delivered', percent: 40, color: AppColors.chartTeal),
    ChartSlice(label: 'In Transit', percent: 35, color: AppColors.chartYellow),
    ChartSlice(label: 'Out for Delivery', percent: 15, color: AppColors.chartPink),
    ChartSlice(label: 'Delayed', percent: 10, color: AppColors.chartPurple),
  ];

  final materialSlices = const <ChartSlice>[
    ChartSlice(label: 'Approved', percent: 40, color: AppColors.chartTeal),
    ChartSlice(label: 'Pending Approval', percent: 35, color: AppColors.chartYellow),
    ChartSlice(label: 'Rejected', percent: 20, color: AppColors.chartPink),
    ChartSlice(label: 'Urgent Requests', percent: 5, color: AppColors.chartPurple),
  ];

  final sites = const <SiteRow>[
    SiteRow(
      project: 'Downtown Office Complex',
      location: 'Site A',
      progress: 0.65,
      deadline: '12/09/2024',
      status: 'Delayed',
      statusColor: AppColors.danger,
      barColor: AppColors.orange,
    ),
    SiteRow(
      project: 'Riverside Apartments',
      location: 'Site B',
      progress: 0.48,
      deadline: '18/10/2024',
      status: 'On Track',
      statusColor: AppColors.success,
      barColor: AppColors.info,
    ),
    SiteRow(
      project: 'Harbor Logistics Hub',
      location: 'Site C',
      progress: 0.72,
      deadline: '05/11/2024',
      status: 'In Transit',
      statusColor: AppColors.chartPink,
      barColor: AppColors.chartYellow,
    ),
    SiteRow(
      project: 'Central Mall Expansion',
      location: 'Site D',
      progress: 0.35,
      deadline: '22/12/2024',
      status: 'On Track',
      statusColor: AppColors.success,
      barColor: AppColors.chartPurple,
    ),
  ];

  final deadlines = const <DeadlineItem>[
    DeadlineItem(
      project: 'Downtown Office Complex',
      location: 'Site A',
      date: 'May 25, 2025',
      daysLeft: '6 Days Left',
    ),
    DeadlineItem(
      project: 'Riverside Apartments',
      location: 'Site B',
      date: 'May 28, 2025',
      daysLeft: '9 Days Left',
    ),
    DeadlineItem(
      project: 'Harbor Logistics Hub',
      location: 'Site C',
      date: 'Jun 02, 2025',
      daysLeft: '14 Days Left',
    ),
    DeadlineItem(
      project: 'Central Mall Expansion',
      location: 'Site D',
      date: 'Jun 10, 2025',
      daysLeft: '22 Days Left',
    ),
  ];

  final timeline = const <TimelineStep>[
    TimelineStep(
      title: 'Planning',
      date: '14/01/2024',
      status: 'Completed',
      statusColor: AppColors.success,
      done: true,
    ),
    TimelineStep(
      title: 'Design',
      date: '02/02/2024',
      status: 'Completed',
      statusColor: AppColors.success,
      done: true,
    ),
    TimelineStep(
      title: 'Procurement',
      date: '18/03/2024',
      status: 'Completed',
      statusColor: AppColors.success,
      done: true,
    ),
    TimelineStep(
      title: 'Execution',
      date: '22/04/2024',
      status: 'Inprogress',
      statusColor: AppColors.chartPurple,
      done: false,
      inProgress: true,
    ),
    TimelineStep(
      title: 'Handover',
      date: '30/06/2024',
      status: 'Upcoming',
      statusColor: AppColors.chartPurple,
      done: false,
    ),
  ];

  final carriers = const <CarrierRow>[
    CarrierRow(
      carrier: 'Roadking Logistics',
      loadsToday: '12',
      onTime: '10',
      delayed: '2',
      priority: 'On Time',
      priorityColor: AppColors.success,
    ),
    CarrierRow(
      carrier: 'Swift Transport',
      loadsToday: '9',
      onTime: '7',
      delayed: '2',
      priority: 'Delayed',
      priorityColor: AppColors.danger,
    ),
    CarrierRow(
      carrier: 'Metro Freight Co',
      loadsToday: '8',
      onTime: '8',
      delayed: '0',
      priority: 'On Time',
      priorityColor: AppColors.success,
    ),
    CarrierRow(
      carrier: 'Prime Haulers',
      loadsToday: '5',
      onTime: '4',
      delayed: '1',
      priority: 'Delayed',
      priorityColor: AppColors.danger,
    ),
  ];

  // Same clock/stat icon with Figma freight colors
  final freightSummaries = const <FreightSummary>[
    FreightSummary(
      value: '34',
      label: 'Total Loads Today',
      iconAsset: AppAssets.iconStatClock,
      iconBg: AppColors.chartYellow,
      progressColor: AppColors.chartYellow,
    ),
    FreightSummary(
      value: '29 (85.8%)',
      label: 'On Time',
      iconAsset: AppAssets.iconStatClock,
      iconBg: Color(0xFFC4A484),
      progressColor: Color(0xFFC4A484),
    ),
    FreightSummary(
      value: '5 (14.7%)',
      label: 'Delayed',
      iconAsset: AppAssets.iconStatClock,
      iconBg: AppColors.chartPurple,
      progressColor: AppColors.chartPurple,
    ),
  ];

  final activities = const <ActivityItem>[
    ActivityItem(
      title: 'New shipper file received for ABC Warehouse (SHP1044)',
      time: '05:00:14 PM',
      iconAsset: AppAssets.iconDocBlue,
    ),
    ActivityItem(
      title: 'Freight dispatch confirmed for Site B delivery',
      time: '04:22:08 PM',
      iconAsset: AppAssets.iconTruckGreen,
    ),
    ActivityItem(
      title: 'Drawing revision uploaded for Downtown Office Complex',
      time: '03:18:45 PM',
      iconAsset: AppAssets.iconCompassPurple,
    ),
    ActivityItem(
      title: 'Production target for today is 83%',
      time: '02:05:22 PM',
      iconAsset: AppAssets.iconChartPink,
    ),
    ActivityItem(
      title: 'Material request report generated for Site C',
      time: '11:30:14 AM',
      iconAsset: AppAssets.iconDocChartPink,
    ),
  ];

  void resetFilters() {
    selectedProject.value = 'All Projects';
    selectedBuilding.value = 'All Buildings';
    selectedStatus.value = 'All Status';
    dateRange.value = '24 Mar 2025 - 31 Mar 2025';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
