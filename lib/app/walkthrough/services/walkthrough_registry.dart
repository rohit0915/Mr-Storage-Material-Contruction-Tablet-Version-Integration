import 'package:flutter/material.dart';

/// Central singleton registry to look up, attach, and locate target widgets across the entire app.
class WalkthroughRegistry {
  WalkthroughRegistry._();

  static final WalkthroughRegistry instance = WalkthroughRegistry._();

  final Map<String, GlobalKey> _keys = {};

  /// Predefined constant key names across the app for safe referencing.
  static const String appBarMenu = 'app_bar_menu';
  static const String appBarGreeting = 'app_bar_greeting';
  static const String appBarNotifications = 'app_bar_notifications';
  static const String appBarProfile = 'app_bar_profile';

  static const String drawerHeader = 'drawer_header';
  static const String drawerItemDashboard = 'drawer_item_dashboard';
  static const String drawerItemProjectCalendar = 'drawer_item_project_calendar';
  static const String drawerItemDrawings = 'drawer_item_drawings';
  static const String drawerItemTasks = 'drawer_item_tasks';
  static const String drawerItemMaterialRequest = 'drawer_item_material_request';
  static const String drawerItemDeliveryTracking = 'drawer_item_delivery_tracking';
  static const String drawerItemDispatchVerification = 'drawer_item_dispatch_verification';
  static const String drawerItemCommunication = 'drawer_item_communication';

  static const String dashboardTitle = 'dashboard_title';
  static const String dashboardExportBtn = 'dashboard_export_btn';
  static const String dashboardMetricsRow = 'dashboard_metrics_row';
  static const String dashboardFilterRow = 'dashboard_filter_row';
  static const String dashboardDeliveryCard = 'dashboard_delivery_card';
  static const String dashboardMaterialCard = 'dashboard_material_card';
  static const String dashboardActiveSitesCard = 'dashboard_active_sites_card';
  static const String dashboardFreightCard = 'dashboard_freight_card';
  static const String dashboardRecentActivity = 'dashboard_recent_activity';

  static const String projectCalendarHeader = 'project_calendar_header';
  static const String projectCalendarTabs = 'project_calendar_tabs';
  static const String projectCalendarViewBody = 'project_calendar_view_body';
  static const String projectCalendarAddTaskBtn = 'project_calendar_add_task_btn';
  static const String projectCalendarAddDeliveryBtn = 'project_calendar_add_delivery_btn';

  static const String drawingsHeader = 'drawings_header';
  static const String drawingsUploadBtn = 'drawings_upload_btn';
  static const String drawingsCategoryChips = 'drawings_category_chips';
  static const String drawingsSearchBar = 'drawings_search_bar';
  static const String drawingsGrid = 'drawings_grid';

  static const String tasksSummaryRow = 'tasks_summary_row';
  static const String tasksBoard = 'tasks_board';
  static const String tasksAddBtn = 'tasks_add_btn';

  static const String dailyWorkLogsHeader = 'daily_work_logs_header';
  static const String dailyWorkLogsAddBtn = 'daily_work_logs_add_btn';
  static const String dailyWorkLogsFilters = 'daily_work_logs_filters';
  static const String dailyWorkLogsTable = 'daily_work_logs_table';

  static const String materialRequestsSummary = 'material_requests_summary';
  static const String materialRequestsAddBtn = 'material_requests_add_btn';
  static const String materialRequestsFilters = 'material_requests_filters';
  static const String materialRequestsTable = 'material_requests_table';

  static const String deliveryTrackingSummary = 'delivery_tracking_summary';
  static const String deliveryTrackingList = 'delivery_tracking_list';

  static const String dispatchVerificationSteps = 'dispatch_verification_steps';
  static const String dispatchVerificationTable = 'dispatch_verification_table';

  static const String chatSidebar = 'chat_sidebar';
  static const String chatMessageThread = 'chat_message_thread';
  static const String chatInputArea = 'chat_input_area';

  static const String profileHeader = 'profile_header';
  static const String profileSettingsBtn = 'profile_settings_btn';
  static const String settingsWalkthroughOption = 'settings_walkthrough_option';

  /// Returns the GlobalKey registered under [name]. If not already created, creates and caches it.
  GlobalKey getKey(String name) {
    return _keys.putIfAbsent(name, () => GlobalKey(debugLabel: name));
  }

  /// Checks if a key has already been created for [name].
  GlobalKey? findKey(String name) => _keys[name];

  /// Computes the absolute screen Rect for the widget registered with [name].
  /// Returns null if widget is not currently attached or mounted.
  Rect? getTargetRect(String name) {
    final key = _keys[name];
    if (key == null || key.currentContext == null) return null;

    final renderObject = key.currentContext!.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return null;

    final translation = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;

    if (size.width <= 0 || size.height <= 0) return null;

    return Rect.fromLTWH(
      translation.dx,
      translation.dy,
      size.width,
      size.height,
    );
  }

  /// Scrolls the widget registered with [name] into view if it is inside a Scrollable.
  Future<void> ensureVisible(
    String name, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    final key = _keys[name];
    final context = key?.currentContext;
    if (context == null) return;

    try {
      await Scrollable.ensureVisible(
        context,
        duration: duration,
        curve: curve,
        alignment: 0.5,
      );
    } catch (_) {
      // Not inside a scrollable or already visible
    }
  }

  /// Clears non-persistent key references when destroying controllers.
  void clear() {
    _keys.clear();
  }
}
