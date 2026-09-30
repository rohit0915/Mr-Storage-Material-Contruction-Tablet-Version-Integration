class ApiConstants {
  ApiConstants._();

    /// Primary base URL from live web panel environment
  static const String baseUrl =
      'https://mr-storage-backend-025k.onrender.com/api';

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

  // Auth & User Settings
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String userProfile = '/auth/profile';
  static const String userSettings = '/auth/settings';

  // Dashboard & Projects
  static const String dashboard = '/construction/dashboard';
  static const String dashboardFilters = '/construction/dashboard/filters';
  static const String projects = '/construction/projects';
  static String projectDetails(String leadId) =>
      '/construction/projects/$leadId';
  static String projectBOM(String leadId) =>
      '/construction/projects/$leadId/bom';
  static const String projectCalendar = '/construction/projects/calendar';

  // Drawings & Attachments
  static const String drawings = '/construction/drawings';
  static String projectDrawings(String leadId) =>
      '/construction/drawings/$leadId';

  // Tasks & Work Logs
  static const String taskStats = '/construction/tasks/stats';
  static const String tasks = '/construction/tasks';
  static String taskDetail(String taskId) => '/construction/tasks/$taskId';
  static const String workLogs = '/construction/work-logs';

  // Material Requests
  static const String materialRequests = '/construction/material-requests';
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

  // Progress Tracker & Milestones
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
  static String labelsUrl({int page = 1, int limit = 10}) =>
      '/construction/labels?page=$page&limit=$limit';
  static const String labelPrint = '/construction/labels/print';

  // Bundle Scan
  static const String bundleScan = '/construction/bundle-scan';
  static String bundleScanUrl({int page = 1, int limit = 10}) =>
      '/construction/bundle-scan?page=$page&limit=$limit';
  static const String bundleScanSubmit = '/construction/bundle-scan/scan';
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
  static String packingListsUrl({int page = 1, int limit = 10}) =>
      '/construction/packing-lists?page=$page&limit=$limit';
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

  // Dispatch Verification
  static const String dispatchVerification =
      '/construction/dispatch-verification';
  static String dispatchVerificationUrl({int page = 1, int limit = 10}) =>
      '/construction/dispatch-verification?page=$page&limit=$limit';
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
  static const String chatUnreadCount = '/team-chat/unread-count';
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
