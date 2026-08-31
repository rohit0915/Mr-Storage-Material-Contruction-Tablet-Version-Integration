class ApiConstants {
  ApiConstants._();

  /// Primary base URL from live web panel environment
  static const String baseUrl = 'https://mr-storage-backend-025k.onrender.com/api';

  /// Local fallback base URL if running local backend server
  static const String localBaseUrl = 'http://localhost:3000/api';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Dashboard & Projects
  static const String dashboard = '/construction/dashboard';
  static const String projects = '/construction/projects';
  static String projectDetails(String leadId) => '/construction/projects/$leadId';
  static const String projectCalendar = '/construction/projects/calendar';

  // Drawings & Attachments
  static const String drawings = '/construction/drawings';
  static String projectDrawings(String leadId) => '/construction/drawings/$leadId';

  // Tasks & Work Logs
  static const String taskStats = '/construction/tasks/stats';
  static const String tasks = '/construction/tasks';
  static String taskDetail(String taskId) => '/construction/tasks/$taskId';
  static const String workLogs = '/construction/work-logs';

  // Material Requests
  static const String materialRequests = '/construction/material-requests';
  static String materialRequestDetail(String requestId) => '/construction/material-requests/$requestId';
  static String materialRequestStatus(String requestId) => '/construction/material-requests/$requestId/status';

  // Delivery Tracking
  static const String deliveries = '/construction/deliveries';
  static String deliveryDetail(String deliveryId) => '/construction/deliveries/$deliveryId';
  static String markDeliveryReceived(String deliveryId) => '/construction/deliveries/$deliveryId/mark-received';
  static String markDeliveryPartial(String deliveryId) => '/construction/deliveries/$deliveryId/mark-partial';

  // Progress Tracker & Milestones
  static String projectProgress(String leadId) => '/construction/projects/$leadId/progress';
  static String projectMilestones(String leadId) => '/construction/projects/$leadId/milestones';
  static String milestoneDetail(String milestoneId) => '/construction/milestones/$milestoneId';
}
