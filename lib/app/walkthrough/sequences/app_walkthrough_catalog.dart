import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../models/walkthrough_sequence.dart';
import '../models/walkthrough_step.dart';
import '../services/walkthrough_registry.dart';

/// Predefined catalogue of all walkthrough tours and module deep dives across the application.
class AppWalkthroughCatalog {
  AppWalkthroughCatalog._();

  static const String mainTourId = 'main_tour';
  static const String dashboardTourId = 'dashboard_tour';
  static const String projectCalendarTourId = 'project_calendar_tour';
  static const String drawingsTourId = 'drawings_tour';
  static const String tasksTourId = 'tasks_tour';
  static const String materialRequestsTourId = 'material_requests_tour';
  static const String deliveryTrackingTourId = 'delivery_tour';
  static const String dispatchVerificationTourId = 'dispatch_tour';
  static const String chatTourId = 'chat_tour';

  /// Returns all available walkthrough sequences.
  static List<WalkthroughSequence> getAllSequences() {
    return [
      buildMainTour(),
      buildDashboardTour(),
      buildProjectCalendarTour(),
      buildDrawingsTour(),
      buildTasksTour(),
      buildMaterialRequestsTour(),
      buildDeliveryTrackingTour(),
      buildDispatchVerificationTour(),
      buildChatTour(),
    ];
  }

  /// Finds a sequence by its ID.
  static WalkthroughSequence? findSequenceById(String id) {
    try {
      return getAllSequences().firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // A. MAIN APPLICATION TOUR (Comprehensive: Dashboard + Navigation Drawer + Cards)
  // ───────────────────────────────────────────────────────────────────────────
  static WalkthroughSequence buildMainTour() {
    return WalkthroughSequence(
      id: mainTourId,
      title: 'Complete Application Guided Tour',
      description: 'Comprehensive overview of Steel Building Depot Construction tablet app.',
      route: AppRoutes.dashboard,
      badgeText: 'Primary Tour',
      steps: [
        // Step 1: Welcome & Overview
        const WalkthroughStep(
          id: 'main_welcome',
          title: 'Welcome to Steel Building Depot Construction',
          category: WalkthroughCategory.welcome,
          description:
              'This enterprise tablet app empowers field supervisors, project managers, and logistics coordinators to track construction sites, manage deliveries, inspect dispatches, and coordinate daily tasks in real-time.',
          tips: 'You can replay this guided walkthrough anytime from your Profile Settings.',
          actionInstruction: 'Tap Next to learn about navigation and main application features.',
          preferredPosition: TooltipPosition.center,
        ),

        // Step 2: Top Application Bar
        const WalkthroughStep(
          id: 'main_app_bar_menu',
          title: 'Main Navigation & Drawer Button',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.appBarMenu,
          targetRoute: AppRoutes.dashboard,
          description:
              'Tap this menu icon at any time to expand the full navigation drawer. It gives you instant access to all core modules: Projects, Drawings, Tasks, Deliveries, and Dispatches.',
          actionInstruction: 'Tap Next to see user account and notification controls.',
          preferredPosition: TooltipPosition.bottom,
        ),

        // Step 3: Notifications & User Profile
        const WalkthroughStep(
          id: 'main_app_bar_actions',
          title: 'Alerts & Profile Controls',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.appBarNotifications,
          targetRoute: AppRoutes.dashboard,
          description:
              'The notification bell keeps you alerted about live delivery updates, material approvals, and urgent site notices. The user avatar leads to your Profile and Application Settings.',
          tips: 'Unread alerts display a red badge for immediate attention.',
          preferredPosition: TooltipPosition.bottom,
        ),

        // Step 4: Live KPI Metrics
        const WalkthroughStep(
          id: 'main_dashboard_metrics',
          title: 'Live Construction KPI Metrics',
          category: WalkthroughCategory.analytics,
          targetKeyName: WalkthroughRegistry.dashboardMetricsRow,
          targetRoute: AppRoutes.dashboard,
          description:
              'Monitor key field metrics at a glance: Active Construction Sites, Total Inbound Deliveries, Pending Material Requests, and Freight Carriers in transit.',
          tips: 'These metrics refresh automatically via real-time WebSocket updates.',
          exploreModuleId: dashboardTourId,
          exploreTitle: 'Explore Dashboard in Depth',
          deepDivePrompt: 'Want an in-depth walkthrough of all dashboard analytics, export reports, and metric breakdown?',
          deepDiveMinutes: 3,
          preferredPosition: TooltipPosition.auto,
        ),

        // Step 5: Advanced Search & Filtering
        const WalkthroughStep(
          id: 'main_dashboard_filters',
          title: 'Multi-Criteria Filter Engine',
          category: WalkthroughCategory.action,
          targetKeyName: WalkthroughRegistry.dashboardFilterRow,
          targetRoute: AppRoutes.dashboard,
          description:
              'Filter analytics and records by Project Name, Date Range, and Operational Status. Use the Reset button to return to global site overview.',
          actionInstruction: 'Filtering updates all charts and metric cards simultaneously.',
          preferredPosition: TooltipPosition.bottom,
        ),

        // Step 6: Navigation Drawer Intro (Auto-Opens Drawer)
        WalkthroughStep(
          id: 'main_drawer_header',
          title: 'Field Navigation Drawer',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.drawerHeader,
          targetRoute: AppRoutes.dashboard,
          description:
              'The left navigation drawer is your primary navigation hub. Let\'s explore each dedicated module available to your field operations crew.',
          preferredPosition: TooltipPosition.right,
          actionBefore: () async {
            try {
              final ctx = Get.context;
              if (ctx != null) Scaffold.of(ctx).openDrawer();
            } catch (_) {}
          },
        ),

        // Step 7: Drawer - Dashboard
        const WalkthroughStep(
          id: 'main_drawer_dashboard',
          title: 'Drawer: Dashboard Command Center',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.drawerItemDashboard,
          targetRoute: AppRoutes.dashboard,
          description:
              'Return to the main command dashboard at any time to monitor high-level project statuses, delivery timelines, and recent field actions.',
          preferredPosition: TooltipPosition.right,
        ),

        // Step 8: Drawer - Project & Calendar
        const WalkthroughStep(
          id: 'main_drawer_project_calendar',
          title: 'Drawer: Project & Calendar',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.drawerItemProjectCalendar,
          targetRoute: AppRoutes.dashboard,
          description:
              'Access the interactive construction timeline, Gantt charts, crane scheduling, and scheduled delivery milestones for every jobsite.',
          exploreModuleId: projectCalendarTourId,
          exploreTitle: 'Explore Projects & Calendar in Depth',
          deepDivePrompt: 'Want to inspect jobsite calendar workflows, task assignments, and crane scheduling?',
          deepDiveMinutes: 4,
          preferredPosition: TooltipPosition.right,
        ),

        // Step 9: Drawer - Drawings & Attachments
        const WalkthroughStep(
          id: 'main_drawer_drawings',
          title: 'Drawer: Drawings & Attachments',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.drawerItemDrawings,
          targetRoute: AppRoutes.dashboard,
          description:
              'View certified structural blueprints, foundation anchor bolt layouts, 3D erection framing diagrams, and engineering change notices.',
          exploreModuleId: drawingsTourId,
          exploreTitle: 'Explore Drawings in Depth',
          deepDivePrompt: 'Want to explore engineering blueprints, revision histories, and site upload workflows?',
          deepDiveMinutes: 4,
          preferredPosition: TooltipPosition.right,
        ),

        // Step 10: Drawer - Tasks
        const WalkthroughStep(
          id: 'main_drawer_tasks',
          title: 'Drawer: Tasks & Daily Logs',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.drawerItemTasks,
          targetRoute: AppRoutes.dashboard,
          description:
              'Assign daily site activities to erector crews, track task progression through Kanban stages, and file daily work logs.',
          exploreModuleId: tasksTourId,
          exploreTitle: 'Explore Tasks in Depth',
          deepDivePrompt: 'Want to inspect task boards, priority filters, and supervisor daily log submissions?',
          deepDiveMinutes: 3,
          preferredPosition: TooltipPosition.right,
        ),

        // Step 11: Drawer - Material Request
        const WalkthroughStep(
          id: 'main_drawer_material_request',
          title: 'Drawer: Material Requests',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.drawerItemMaterialRequest,
          targetRoute: AppRoutes.dashboard,
          description:
              'Submit urgent requests for additional framing fasteners, trim pieces, flashing, or structural bolts directly to the plant or warehouse.',
          exploreModuleId: materialRequestsTourId,
          exploreTitle: 'Explore Material Requests in Depth',
          deepDivePrompt: 'Want to track urgent jobsite material orders, part numbers, and approval statuses?',
          deepDiveMinutes: 3,
          preferredPosition: TooltipPosition.right,
        ),

        // Step 12: Drawer - Delivery Tracking
        const WalkthroughStep(
          id: 'main_drawer_delivery_tracking',
          title: 'Drawer: Delivery Tracking',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.drawerItemDeliveryTracking,
          targetRoute: AppRoutes.dashboard,
          description:
              'Track live freight shipments en route to your jobsites, contact flatbed drivers, inspect bills of lading, and check off received bundles.',
          exploreModuleId: deliveryTrackingTourId,
          exploreTitle: 'Explore Delivery Tracking in Depth',
          deepDivePrompt: 'Want live GPS freight tracking, carrier ETAs, and bundle count verifications?',
          deepDiveMinutes: 3,
          preferredPosition: TooltipPosition.right,
        ),

        // Step 13: Drawer - Dispatch Verification
        const WalkthroughStep(
          id: 'main_drawer_dispatch_verification',
          title: 'Drawer: Dispatch Verification',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.drawerItemDispatchVerification,
          targetRoute: AppRoutes.dashboard,
          description:
              'Execute the 4-step dispatch chain of custody: Project validation, packing list check, bundle barcode scanning, and electronic sign-off.',
          exploreModuleId: dispatchVerificationTourId,
          exploreTitle: 'Explore Dispatch Verification in Depth',
          deepDivePrompt: 'Want to inspect the 4-step dispatch chain of custody and mobile barcode scanning?',
          deepDiveMinutes: 4,
          preferredPosition: TooltipPosition.right,
        ),

        // Step 14: Drawer - Communication (Auto-Closes Drawer After Step)
        WalkthroughStep(
          id: 'main_drawer_communication',
          title: 'Drawer: Communication Hub',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.drawerItemCommunication,
          targetRoute: AppRoutes.dashboard,
          description:
              'Coordinate with project managers, structural detailers, and plant logistics staff through project-specific real-time chat channels.',
          exploreModuleId: chatTourId,
          exploreTitle: 'Explore Communication in Depth',
          deepDivePrompt: 'Want to inspect real-time project messaging channels and field issue escalation?',
          deepDiveMinutes: 2,
          preferredPosition: TooltipPosition.right,
          actionAfter: () async {
            try {
              final ctx = Get.context;
              if (ctx != null) Navigator.of(ctx).pop();
            } catch (_) {}
          },
        ),

        // Step 15: Inbound Delivery Pipeline Card
        const WalkthroughStep(
          id: 'main_dashboard_delivery',
          title: 'Inbound Delivery Pipeline',
          category: WalkthroughCategory.workflow,
          targetKeyName: WalkthroughRegistry.dashboardDeliveryCard,
          targetRoute: AppRoutes.dashboard,
          description:
              'Track high-priority shipments, carrier status, ETA dates, and bundle counts. Click "View All Deliveries" to inspect individual shipments.',
          exploreModuleId: deliveryTrackingTourId,
          exploreTitle: 'Explore Delivery Tracking in Depth',
          deepDivePrompt: 'Want to check upcoming flatbed deliveries and bundle manifests?',
          deepDiveMinutes: 3,
          preferredPosition: TooltipPosition.top,
        ),

        // Step 16: Material Requests Status Card
        const WalkthroughStep(
          id: 'main_dashboard_material',
          title: 'Material Requests Summary',
          category: WalkthroughCategory.action,
          targetKeyName: WalkthroughRegistry.dashboardMaterialCard,
          targetRoute: AppRoutes.dashboard,
          description:
              'Review outstanding requests for site materials, approval stages, and scheduled dispatch dates from the plant.',
          exploreModuleId: materialRequestsTourId,
          exploreTitle: 'Explore Material Requests in Depth',
          deepDivePrompt: 'Want to inspect site material requisitions and shipment timelines?',
          deepDiveMinutes: 3,
          preferredPosition: TooltipPosition.top,
        ),

        // Step 17: Active Construction Sites
        const WalkthroughStep(
          id: 'main_dashboard_sites',
          title: 'Active Construction Sites',
          category: WalkthroughCategory.feature,
          targetKeyName: WalkthroughRegistry.dashboardActiveSitesCard,
          targetRoute: AppRoutes.dashboard,
          description:
              'Review progress percentages, lead supervisors, and milestone statuses across all active steel building installations.',
          exploreModuleId: projectCalendarTourId,
          exploreTitle: 'Explore Projects & Calendar in Depth',
          deepDivePrompt: 'Want to review detailed construction phases and jobsite milestones?',
          deepDiveMinutes: 4,
          preferredPosition: TooltipPosition.top,
        ),

        // Step 18: Tour Completion & Settings Replay
        const WalkthroughStep(
          id: 'main_conclusion',
          title: 'You Are Ready to Build! 🏗️',
          category: WalkthroughCategory.welcome,
          description:
              'You have explored the essentials of the Steel Building Depot Construction system. You can launch individual module tours anytime, or retake this walkthrough from Settings.',
          tips: 'Use the Navigation Drawer on the top left to switch between modules at any time.',
          preferredPosition: TooltipPosition.center,
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // B. DASHBOARD IN-DEPTH TOUR
  // ───────────────────────────────────────────────────────────────────────────
  static WalkthroughSequence buildDashboardTour() {
    return WalkthroughSequence(
      id: dashboardTourId,
      title: 'Dashboard Analytics In-Depth Tour',
      description: 'Deep dive into KPI calculations, site metrics, filters, and reports.',
      route: AppRoutes.dashboard,
      parentTourId: mainTourId,
      badgeText: 'Module Tour',
      steps: [
        const WalkthroughStep(
          id: 'dash_export',
          title: 'Export Jobsite Analytics',
          category: WalkthroughCategory.action,
          targetKeyName: WalkthroughRegistry.dashboardExportBtn,
          targetRoute: AppRoutes.dashboard,
          description:
              'Download clean PDF or Excel summaries of active construction sites, delivery timeliness, and material request backlogs.',
          tips: 'Exports automatically apply your currently active filter settings.',
          preferredPosition: TooltipPosition.bottom,
        ),
        const WalkthroughStep(
          id: 'dash_metrics_deep',
          title: 'KPI Calculation Details',
          category: WalkthroughCategory.analytics,
          targetKeyName: WalkthroughRegistry.dashboardMetricsRow,
          targetRoute: AppRoutes.dashboard,
          description:
              'Metrics update dynamically in real time: "Active Sites" indicates projects currently undergoing steel erection, while "Inbound Deliveries" counts flatbed trailers in transit.',
          preferredPosition: TooltipPosition.bottom,
        ),
        const WalkthroughStep(
          id: 'dash_filters_deep',
          title: 'Date Range & Site Filters',
          category: WalkthroughCategory.action,
          targetKeyName: WalkthroughRegistry.dashboardFilterRow,
          targetRoute: AppRoutes.dashboard,
          description:
              'Filter by specific projects to isolate site dispatches and crew tasks. Selecting a custom date range isolates work logs and completed deliveries.',
          preferredPosition: TooltipPosition.bottom,
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // C. PROJECT & CALENDAR TOUR (In Depth)
  // ───────────────────────────────────────────────────────────────────────────
  static WalkthroughSequence buildProjectCalendarTour() {
    return WalkthroughSequence(
      id: projectCalendarTourId,
      title: 'Projects & Calendar In-Depth Tour',
      description: 'Gantt timeline, crane scheduling, delivery events, and workflow milestones.',
      route: AppRoutes.projectCalendar,
      parentTourId: mainTourId,
      badgeText: 'Module Tour',
      steps: [
        const WalkthroughStep(
          id: 'proj_tabs',
          title: 'Project Switching Tabs',
          category: WalkthroughCategory.navigation,
          targetKeyName: WalkthroughRegistry.projectCalendarTabs,
          targetRoute: AppRoutes.projectCalendar,
          description:
              'Switch between assigned projects to view their specific erection schedules, foundation sign-offs, and staging area constraints.',
          preferredPosition: TooltipPosition.bottom,
        ),
        const WalkthroughStep(
          id: 'proj_add_delivery',
          title: 'Schedule Inbound Delivery',
          category: WalkthroughCategory.action,
          targetKeyName: WalkthroughRegistry.projectCalendarAddDeliveryBtn,
          targetRoute: AppRoutes.projectCalendar,
          description:
              'Schedule a delivery event on the jobsite calendar. Specify flatbed arrival window, carrier, and required crane staging time.',
          tips: 'Prevents multiple heavy flatbeds arriving simultaneously on constrained sites.',
          preferredPosition: TooltipPosition.bottom,
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // D. DRAWINGS & ATTACHMENTS TOUR (In Depth)
  // ───────────────────────────────────────────────────────────────────────────
  static WalkthroughSequence buildDrawingsTour() {
    return WalkthroughSequence(
      id: drawingsTourId,
      title: 'Drawings & Attachments In-Depth Tour',
      description: 'Certified architectural plans, framing blueprints, 3D erection guides, and BOM.',
      route: AppRoutes.drawings,
      parentTourId: mainTourId,
      badgeText: 'Module Tour',
      steps: [
        const WalkthroughStep(
          id: 'drw_upload',
          title: 'Upload Site Documentation',
          category: WalkthroughCategory.action,
          targetKeyName: WalkthroughRegistry.drawingsUploadBtn,
          targetRoute: AppRoutes.drawings,
          description:
              'Field crews can upload high-resolution site progress photos, foundation inspection certifications, and annotated PDF markups.',
          tips: 'Supports PDF, DWG exports, PNG, JPG, and video walkthroughs.',
          preferredPosition: TooltipPosition.bottom,
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // E. TASKS & WORK LOGS TOUR (In Depth)
  // ───────────────────────────────────────────────────────────────────────────
  static WalkthroughSequence buildTasksTour() {
    return WalkthroughSequence(
      id: tasksTourId,
      title: 'Tasks & Daily Work Logs In-Depth Tour',
      description: 'Crew assignments, erection milestones, punch lists, and daily work logs.',
      route: AppRoutes.tasks,
      parentTourId: mainTourId,
      badgeText: 'Module Tour',
      steps: [
        const WalkthroughStep(
          id: 'tasks_summary',
          title: 'Task Status Metrics',
          category: WalkthroughCategory.analytics,
          targetKeyName: WalkthroughRegistry.tasksSummaryRow,
          targetRoute: AppRoutes.tasks,
          description:
              'Track total tasks across Pending, In Progress, In Review, and Completed stages. Identify bottlenecks in structural erection early.',
          preferredPosition: TooltipPosition.bottom,
        ),
        const WalkthroughStep(
          id: 'tasks_board',
          title: 'Interactive Kanban Board',
          category: WalkthroughCategory.workflow,
          targetKeyName: WalkthroughRegistry.tasksBoard,
          targetRoute: AppRoutes.tasks,
          description:
              'Visual task cards organized by workflow stage. Drag and drop cards to update status, tap a card to view detailed instructions or assign erectors.',
          tips: 'Filter by priority to focus on critical crane and anchor bolt tasks first.',
          preferredPosition: TooltipPosition.top,
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // F. MATERIAL REQUESTS TOUR (In Depth)
  // ───────────────────────────────────────────────────────────────────────────
  static WalkthroughSequence buildMaterialRequestsTour() {
    return WalkthroughSequence(
      id: materialRequestsTourId,
      title: 'Material Requests In-Depth Tour',
      description: 'Requisition structural components, hardware, insulation, and trim parts.',
      route: AppRoutes.materialRequests,
      parentTourId: mainTourId,
      badgeText: 'Module Tour',
      steps: [
        const WalkthroughStep(
          id: 'mat_add',
          title: 'Submit New Material Request',
          category: WalkthroughCategory.action,
          targetKeyName: WalkthroughRegistry.materialRequestsAddBtn,
          targetRoute: AppRoutes.materialRequests,
          description:
              'Tap this button when additional materials are required on site. Select project, part categories, quantities, and urgency level.',
          preferredPosition: TooltipPosition.bottom,
        ),
        const WalkthroughStep(
          id: 'mat_summary',
          title: 'Requisition Status Summary',
          category: WalkthroughCategory.analytics,
          targetKeyName: WalkthroughRegistry.materialRequestsSummary,
          targetRoute: AppRoutes.materialRequests,
          description:
              'Track open requests, approved purchase orders, dispatched parts, and delivered items.',
          preferredPosition: TooltipPosition.bottom,
        ),
        const WalkthroughStep(
          id: 'mat_table',
          title: 'Material Requisitions Registry',
          category: WalkthroughCategory.workflow,
          targetKeyName: WalkthroughRegistry.materialRequestsTable,
          targetRoute: AppRoutes.materialRequests,
          description:
              'Inspect itemized part lists, vendor notes, and plant dispatch tracking numbers for every requisition.',
          preferredPosition: TooltipPosition.top,
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // G. DELIVERY TRACKING TOUR (In Depth)
  // ───────────────────────────────────────────────────────────────────────────
  static WalkthroughSequence buildDeliveryTrackingTour() {
    return WalkthroughSequence(
      id: deliveryTrackingTourId,
      title: 'Delivery Tracking In-Depth Tour',
      description: 'Live freight shipments, driver contact, bill of lading, and QR arrival check-in.',
      route: AppRoutes.deliveryTracking,
      parentTourId: mainTourId,
      badgeText: 'Module Tour',
      steps: [
        const WalkthroughStep(
          id: 'del_list',
          title: 'Active Shipments Stream',
          category: WalkthroughCategory.workflow,
          targetKeyName: WalkthroughRegistry.deliveryTrackingList,
          targetRoute: AppRoutes.deliveryTracking,
          description:
              'Each card displays tracking number, freight carrier, estimated arrival window, and bundle count. Tap to inspect packing list or verify bundles with the QR scanner.',
          preferredPosition: TooltipPosition.top,
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // H. DISPATCH VERIFICATION TOUR (In Depth)
  // ───────────────────────────────────────────────────────────────────────────
  static WalkthroughSequence buildDispatchVerificationTour() {
    return WalkthroughSequence(
      id: dispatchVerificationTourId,
      title: 'Dispatch Verification In-Depth Tour',
      description: '4-step chain of custody: Project -> Packing List -> Bundle QR Scan -> Sign-off.',
      route: AppRoutes.dispatchVerification,
      parentTourId: mainTourId,
      badgeText: 'Module Tour',
      steps: [
        const WalkthroughStep(
          id: 'disp_wizard',
          title: '4-Step Verification Workflow',
          category: WalkthroughCategory.workflow,
          targetKeyName: WalkthroughRegistry.dispatchVerificationSteps,
          targetRoute: AppRoutes.dispatchVerification,
          description:
              'This module enforces quality control before dispatch: Step 1 verifies the Project, Step 2 checks the Packing List, Step 3 scans individual bundle barcodes, and Step 4 captures digital sign-off.',
          tips: 'Prevents missing parts and wrong deliveries before trucks leave the facility.',
          preferredPosition: TooltipPosition.bottom,
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // I. CHAT & COMMUNICATION TOUR (In Depth)
  // ───────────────────────────────────────────────────────────────────────────
  static WalkthroughSequence buildChatTour() {
    return WalkthroughSequence(
      id: chatTourId,
      title: 'Communication & Chat In-Depth Tour',
      description: 'Real-time project channels, direct supervisor messaging, and media sharing.',
      route: AppRoutes.chat,
      parentTourId: mainTourId,
      badgeText: 'Module Tour',
      steps: [
        const WalkthroughStep(
          id: 'chat_rooms',
          title: 'Project Channels & Contacts',
          category: WalkthroughCategory.feature,
          targetKeyName: WalkthroughRegistry.chatSidebar,
          targetRoute: AppRoutes.chat,
          description:
              'Chat channels are organized by Project Site and Department. Easily message your field crew or project engineers.',
          preferredPosition: TooltipPosition.right,
        ),
        const WalkthroughStep(
          id: 'chat_thread',
          title: 'Live Real-time Message Stream',
          category: WalkthroughCategory.feature,
          targetKeyName: WalkthroughRegistry.chatMessageThread,
          targetRoute: AppRoutes.chat,
          description:
              'Messages update instantly via WebSocket. Share photos of on-site obstacles, ask for clarifications, and keep audit logs.',
          preferredPosition: TooltipPosition.left,
        ),
      ],
    );
  }
}
