import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import 'section_card.dart';
import 'stat_icon_box.dart';

class MetricCardsRow extends StatelessWidget {
  const MetricCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = DashboardGap.page(context);

    return GetBuilder<DashboardController>(
      id: AppGetIds.dashboardMetrics,
      builder: (controller) {
        final list = controller.metrics;
        if (list.isEmpty) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 850;
            if (isNarrow) {
              final colWidth = (constraints.maxWidth - gap * 2) / 3;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: list
                    .map((m) => SizedBox(
                          width: colWidth,
                          child: MetricCard(item: m),
                        ))
                    .toList(),
              );
            }

            return Row(
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  Expanded(child: MetricCard(item: list[i])),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.item});

  final MetricItem item;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final valueSize = (size.width * 0.016).clamp(16.0, 22.0);
    final titleSize = (size.width * 0.009).clamp(10.0, 12.0);
    final subSize = (size.width * 0.008).clamp(9.0, 11.0);
    final iconSize = (size.width * 0.026).clamp(32.0, 38.0);

    return SectionCard(
      padding: EdgeInsets.all((size.width * 0.01).clamp(12.0, 20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatIconBox(color: item.iconBg, icon: item.icon, size: iconSize),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                item.up ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                size: 14,
                color: item.subtitleColor,
              ),
              SizedBox(width: size.width * 0.003),
              Expanded(
                child: Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: subSize,
                    fontWeight: FontWeight.w600,
                    color: item.subtitleColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
