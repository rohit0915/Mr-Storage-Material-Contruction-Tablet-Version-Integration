import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/constants/get_builder_ids.dart';
import '../../../app/walkthrough/controllers/walkthrough_controller.dart';
import '../../../app/walkthrough/sequences/app_walkthrough_catalog.dart';
import '../../../app/walkthrough/services/walkthrough_registry.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import '../widgets/active_sites_card.dart';
import '../widgets/dashboard_overview_title.dart';
import '../widgets/delivery_overview_card.dart';
import '../widgets/filter_row.dart';
import '../widgets/freight_carriers_card.dart';
import '../widgets/material_request_card.dart';
import '../widgets/metric_cards_row.dart';
import '../widgets/recent_activity_card.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<WalkthroughController>()) {
        final args = Get.arguments;
        final fromLogin = (args is Map && args['fromLogin'] == true);
        WalkthroughController.to.checkFirstTimeOnboarding(force: fromLogin);
      }
    });

    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = DashboardGap.section(context);
    final colGap = DashboardGap.page(context);

    return AppScaffold(
      menuTitle: 'Dashboard',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DashboardOverviewTitle(),
            // _TourWelcomeBanner moved to Navigation Drawer per user request
            GetBuilder<DashboardController>(
              id: AppGetIds.dashboardMetrics,
              builder: (controller) => Column(
                children: [
                  if (controller.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (controller.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(child: Text(controller.errorMessage)),
                          TextButton(
                            onPressed: controller.fetchDashboardData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: gap),
            KeyedSubtree(
              key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.dashboardMetricsRow),
              child: const MetricCardsRow(),
            ),
            SizedBox(height: gap),
            KeyedSubtree(
              key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.dashboardFilterRow),
              child: const FilterRow(),
            ),
            SizedBox(height: gap),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KeyedSubtree(
                        key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.dashboardDeliveryCard),
                        child: const DeliveryOverviewCard(),
                      ),
                      SizedBox(height: gap),
                      KeyedSubtree(
                        key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.dashboardMaterialCard),
                        child: const MaterialRequestCard(),
                      ),
                      SizedBox(height: gap),
                      KeyedSubtree(
                        key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.dashboardActiveSitesCard),
                        child: const ActiveSitesCard(),
                      ),
                      SizedBox(height: gap),
                      const FreightCarriersCard(),
                      SizedBox(height: gap),
                      const RecentActivityCard(),
                    ],
                  );
                }
                final isNarrow = constraints.maxWidth < 900;
                if (isNarrow) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: KeyedSubtree(
                              key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.dashboardDeliveryCard),
                              child: const DeliveryOverviewCard(),
                            ),
                          ),
                          SizedBox(width: colGap),
                          Expanded(
                            child: KeyedSubtree(
                              key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.dashboardMaterialCard),
                              child: const MaterialRequestCard(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: gap),
                      KeyedSubtree(
                        key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.dashboardActiveSitesCard),
                        child: const ActiveSitesCard(),
                      ),
                      SizedBox(height: gap),
                      const FreightCarriersCard(),
                      SizedBox(height: gap),
                      const RecentActivityCard(),
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: KeyedSubtree(
                            key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.dashboardDeliveryCard),
                            child: const DeliveryOverviewCard(),
                          ),
                        ),
                        SizedBox(width: colGap),
                        Expanded(
                          flex: 3,
                          child: KeyedSubtree(
                            key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.dashboardMaterialCard),
                            child: const MaterialRequestCard(),
                          ),
                        ),
                        SizedBox(width: colGap),
                        Expanded(
                          flex: 6,
                          child: KeyedSubtree(
                            key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.dashboardActiveSitesCard),
                            child: const ActiveSitesCard(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: gap),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(flex: 6, child: FreightCarriersCard()),
                        SizedBox(width: colGap),
                        const Expanded(flex: 4, child: RecentActivityCard()),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TourWelcomeBanner extends StatelessWidget {
  const _TourWelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.explore_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interactive Application Walkthrough',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Learn how to navigate projects, track dispatches, inspect drawings, and manage site tasks.',
                  style: TextStyle(
                    color: Color(0xFFDBEAFE),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              if (Get.isRegistered<WalkthroughController>()) {
                WalkthroughController.to.showWelcomeModal(context);
              }
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Start Tour', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E3A8A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
