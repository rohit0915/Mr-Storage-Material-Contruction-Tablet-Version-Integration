import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import '../widgets/active_sites_card.dart';
import '../widgets/dashboard_overview_title.dart';
import '../widgets/deadlines_card.dart';
import '../widgets/delivery_overview_card.dart';
import '../widgets/filter_row.dart';
import '../widgets/freight_carriers_card.dart';
import '../widgets/material_request_card.dart';
import '../widgets/metric_cards_row.dart';
import '../widgets/project_timeline_card.dart';
import '../widgets/recent_activity_card.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
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
            SizedBox(height: gap),
            const MetricCardsRow(),
            SizedBox(height: gap),
            const FilterRow(),
            SizedBox(height: gap),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 900;
                if (isNarrow) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(child: DeliveryOverviewCard()),
                          SizedBox(width: colGap),
                          const Expanded(child: MaterialRequestCard()),
                        ],
                      ),
                      SizedBox(height: gap),
                      const ActiveSitesCard(),
                      SizedBox(height: gap),
                      Row(
                        children: [
                          const Expanded(child: DeadlinesCard()),
                          SizedBox(width: colGap),
                          const Expanded(child: ProjectTimelineCard()),
                        ],
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
                        const Expanded(flex: 3, child: DeliveryOverviewCard()),
                        SizedBox(width: colGap),
                        const Expanded(flex: 3, child: MaterialRequestCard()),
                        SizedBox(width: colGap),
                        const Expanded(flex: 5, child: ActiveSitesCard()),
                      ],
                    ),
                    SizedBox(height: gap),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: DeadlinesCard()),
                        SizedBox(width: colGap),
                        const Expanded(child: ProjectTimelineCard()),
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
