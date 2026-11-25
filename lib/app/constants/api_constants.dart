class ApiConstants {
  ApiConstants._();

  /// Primary base URL from live web panel environment
  static const String baseUrl = 'https://uat.flyweistechnology.com/api';

  /// Local fallback base URL if running local backend server
  static const String localBaseUrl = 'http://localhost:3000/api';

  /// Socket.io server origin (stripped of /api path)
  static String get serverOrigin {
    try {
      final uri = Uri.parse(baseUrl);
      return uri.origin;
    } catch (_) {
      return 'https://uat.flyweistechnology.com';
    }
  }

  /// Socket.io namespace for staff/construction panels
  static const String socketNamespace = '/admin';

  // Auth & User Settings
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String userProfile = '/construction/profile';
  static const String userSettings = '/construction/settings';

  // Dashboard & Projects
  static const String dashboard = '/construction/dashboard';
  static const String dashboardFilters = '/construction/dashboard/filters';
  static const String adminOverview = '/admin/construction/overview';
  static const String adminOverviewFilters = '/admin/construction/overview/filters';
  static const String projects = '/construction/projects';
  static String projectDetails(String leadId) =>
      '/construction/projects/$leadId';
  static String projectBOM(String leadId) =>
      '/construction/projects/$leadId/bom';
  static String consolidatedBOM(String leadId) =>
      '/construction/projects/$leadId/consolidated-bom';
  static String bomFiles(String leadId) =>
      '/construction/projects/$leadId/bom-files';
  static String projectMaterialDeliveries(String leadId) =>
      '/construction/projects/$leadId/material-deliveries';
  static const String projectCalendar = '/construction/projects/calendar';

  // Drawings & Attachments
  static const String drawings = '/construction/drawings';
  static const String media = '/construction/media';
  static String projectDrawings(String leadId) =>
      '/construction/drawings/$leadId';
  static String projectBuildingDrawings(String leadId) =>
      '/construction/projects/$leadId/building-drawings';
  static String projectMedia(String leadId) =>
      '/construction/media/$leadId';

  // Tasks & Work Logs
  static const String taskStats = '/construction/tasks/stats';
  static const String tasks = '/construction/tasks';
  static String taskDetail(String taskId) => '/construction/tasks/$taskId';
  static String projectTimelineTasks(String leadId) =>
      '/construction/projects/$leadId/timeline-tasks';
  static String completeTask(String taskId) =>
      '/construction/tasks/$taskId/complete';
  static const String workLogs = '/construction/work-logs';

  // Material Requests
  static const String materialRequests = '/construction/material-requests';
  static const String materialRequestsFilters =
      '/construction/material-requests/filters';
  static String materialRequestDetail(String requestId) =>
      '/construction/material-requests/$requestId';
  static String materialRequestStatus(String requestId) =>
      '/construction/material-requests/$requestId/status';
  static String materialRequestQuotations(String requestId) =>
      '/construction/material-requests/$requestId/quotations';
  static String materialRequestItemDelivered(
    String requestId, [
    String? itemId,
  ]) => itemId != null
      ? '/construction/material-requests/$requestId/items/$itemId/deliver'
      : '/construction/material-requests/$requestId/item-delivered';

  // Delivery Tracking
  static const String deliveries = '/construction/deliveries';
  static const String deliveryFilters = '/construction/deliveries/filters';
  static String deliveryDetail(String deliveryId) =>
      '/construction/deliveries/$deliveryId';
  static String markDeliveryReceived(String deliveryId) =>
      '/construction/deliveries/$deliveryId/mark-received';
  static String markDeliveryPartial(String deliveryId) =>
      '/construction/deliveries/$deliveryId/mark-partial';
  static const String deliveryScanBundle =
      '/construction/deliveries/scan-bundle';
  static String deliverySiteContact(String deliveryId) =>
      '/construction/deliveries/$deliveryId/site-contact';
  static String deliveryDownloadPackingList(String deliveryId) =>
      '/construction/deliveries/$deliveryId/download/packing-list';
  static String deliveryDownloadBillOfLading(String deliveryId) =>
      '/construction/deliveries/$deliveryId/download/bill-of-lading';

  // Progress Tracker, Phases & Milestones
  static String projectPhases(String leadId) =>
      '/construction/projects/$leadId/phases';
  static String projectProgress(String leadId) =>
      '/construction/projects/$leadId/progress';
  static String projectMilestones(String leadId) =>
      '/construction/projects/$leadId/milestones';
  static String milestoneDetail(String milestoneId) =>
      '/construction/milestones/$milestoneId';
  static String projectStep(String leadId, String stepKey) =>
      '/construction/projects/$leadId/steps/$stepKey';
  static String projectStepAttachments(String leadId, String stepKey) =>
      '/construction/projects/$leadId/steps/$stepKey/attachments';

  // Label Printing
  static const String labels = '/construction/labels';
  static String labelsUrl({
    int page = 1,
    int limit = 10,
    String? projectId,
    String? status,
    String? search,
    String? sortBy,
  }) {
    final params = <String>[
      'page=$page',
      'limit=$limit',
      if (projectId != null && projectId.isNotEmpty)
        'projectId=${Uri.encodeComponent(projectId)}',
      if (status != null && status.isNotEmpty)
        'status=${Uri.encodeComponent(status)}',
      if (search != null && search.isNotEmpty)
        'search=${Uri.encodeComponent(search)}',
      if (sortBy != null && sortBy.isNotEmpty)
        'sortBy=${Uri.encodeComponent(sortBy)}',
    ];
    return '/construction/labels?${params.join('&')}';
  }
  static const String labelPrint = '/construction/labels/print';

  // Bundle Scan
  static const String bundleScan = '/construction/bundle-scan';
  static String bundleScanUrl({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String? status,
    String? projectId,
  }) {
    final params = <String>[
      'page=$page',
      'limit=$limit',
      if (search != null && search.isNotEmpty)
        'search=${Uri.encodeComponent(search)}',
      if (sortBy != null && sortBy.isNotEmpty)
        'sortBy=${Uri.encodeComponent(sortBy)}',
      if (status != null && status.isNotEmpty)
        'status=${Uri.encodeComponent(status)}',
      if (projectId != null && projectId.isNotEmpty)
        'projectId=${Uri.encodeComponent(projectId)}',
    ];
    return '/construction/bundle-scan?${params.join('&')}';
  }
  static const String bundleScanSubmit = '/construction/bundle-scan/scan';
  static const String bundleScanExport = '/construction/bundle-scan/export';
  static String bundleDetail(String id) => '/construction/bundles/$id';
  static String bundleVerify(String id) => '/construction/bundles/$id/verify';
  static String bundleStaged(String id) =>
      '/construction/bundles/$id/mark-staged';
  static String bundleLoaded(String id) =>
      '/construction/bundles/$id/mark-loaded';
  static String bundleMismatch(String id) =>
      '/construction/bundles/$id/report-mismatch';
  static String bundleReprint(String id) =>
      '/construction/bundles/$id/reprint-label';

  // Packing List
  static const String packingLists = '/construction/packing-lists';
  static String packingListsUrl({
    int page = 1,
    int limit = 10,
    String? projectId,
    String? search,
  }) {
    final params = <String>[
      'page=$page',
      'limit=$limit',
      if (projectId != null && projectId.isNotEmpty)
        'projectId=${Uri.encodeComponent(projectId)}',
      if (search != null && search.isNotEmpty)
        'search=${Uri.encodeComponent(search)}',
    ];
    return '/construction/packing-lists?${params.join('&')}';
  }
  static String packingListDetail(String id) =>
      '/construction/packing-lists/$id';
  static const String packingListExport = '/construction/packing-lists/export';
  static String packingListDownloadPdf(String id) =>
      '/construction/packing-lists/$id/download-pdf';
  static String packingListMarkReady(String id) =>
      '/construction/packing-lists/$id/mark-ready';
  static String packingListMarkLoading(String id) =>
      '/construction/packing-lists/$id/mark-loading';
  static String packingListMarkDispatch(String id) =>
      '/construction/packing-lists/$id/mark-dispatch';

  // 3-step logistics navigation
  static const String packingListsProjects =
      '/construction/packing-lists/projects';
  static String packingListsProjectLoads(String leadId) =>
      '/construction/packing-lists/projects/$leadId/loads';
  static String packingListsLoadBundles(String packingListId) =>
      '/construction/packing-lists/loads/$packingListId/bundles';

  static const String labelsProjects = '/construction/labels/projects';
  static String labelsProjectLoads(String leadId) =>
      '/construction/labels/projects/$leadId/loads';
  static String labelsLoadBundles(String packingListId) =>
      '/construction/labels/loads/$packingListId/bundles';

  static const String bundleScanProjects =
      '/construction/bundle-scan/projects';
  static String bundleScanProjectLoads(String leadId) =>
      '/construction/bundle-scan/projects/$leadId/loads';
  static String bundleScanLoadBundles(String packingListId) =>
      '/construction/bundle-scan/loads/$packingListId/bundles';

  // Plant Project Tabs & Mismatch Orders
  static String plantProjectAdditionalMaterialRequests(
    String leadId, {
    int page = 1,
    int limit = 20,
  }) =>
      '/plant/projects/$leadId/additional-material-requests?page=$page&limit=$limit';

  static String plantProjectMismatchOrders(
    String leadId, {
    int page = 1,
    int limit = 20,
    String? status,
  }) {
    final params = <String>[
      'page=$page',
      'limit=$limit',
      if (status != null && status.isNotEmpty)
        'status=${Uri.encodeComponent(status)}',
    ];
    return '/plant/projects/$leadId/mismatch-orders?${params.join('&')}';
  }

  static String plantMismatchOrderStatus(String mismatchId) =>
      '/plant/mismatch-orders/$mismatchId/status';

  // Dispatch Verification
  static const String dispatchVerification =
      '/construction/dispatch-verification';
  static const String dispatchVerificationProjects =
      '/construction/dispatch-verification/projects';
  static String dispatchVerificationUrl({
    int page = 1,
    int limit = 10,
    String? projectId,
  }) {
    final params = <String>[
      'page=$page',
      'limit=$limit',
      if (projectId != null && projectId.isNotEmpty)
        'projectId=${Uri.encodeComponent(projectId)}',
    ];
    return '/construction/dispatch-verification?${params.join('&')}';
  }
  static String dispatchVerificationDetail(String id) =>
      '/construction/dispatch-verification/$id';
  static String dispatchVerificationVerify(String id) =>
      '/construction/dispatch-verification/$id/verify-load';
  static String dispatchVerificationConfirm(String id) =>
      '/construction/dispatch-verification/$id/confirm-dispatch';

  // Notifications
  static const String notifications = '/notifications';
  static String notificationsUrl({int page = 1, int limit = 20}) =>
      '/notifications?page=$page&limit=$limit';
  static const String notificationUnreadCount = '/notifications/unread-count';
  static String notificationMarkRead(String id) => '/notifications/$id/read';
  static const String notificationMarkAllRead = '/notifications/read-all';
  static String notificationDetail(String id) => '/notifications/$id';

  // Team Chat / Internal Communication
  static const String chatUsers = '/team-chat/users';
  static String chatUsersUrl(String search) =>
      '/team-chat/users?search=${Uri.encodeComponent(search)}';
  static const String chatConversations = '/team-chat/conversations';
  static const String chatUnreadCount =
      '/team-chat/unread-count'; // Assuming this exists, fallback
  static String chatDirectMessages(
    String userId, {
    int page = 1,
    int limit = 30,
  }) => '/team-chat/direct/$userId/messages?page=$page&limit=$limit';
  static const String chatUploadPresignedUrl = '/upload/presigned-url';
  static const String chatGroups = '/team-chat/groups';
  static String chatGroupDetail(String groupId) => '/team-chat/groups/$groupId';
  static String chatGroupMembers(String groupId) =>
      '/team-chat/groups/$groupId/members';
  static String chatGroupMessages(
    String groupId, {
    int page = 1,
    int limit = 30,
  }) => '/team-chat/groups/$groupId/messages?page=$page&limit=$limit';
}
