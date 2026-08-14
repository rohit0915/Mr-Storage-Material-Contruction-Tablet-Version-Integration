import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import 'section_card.dart';
import 'stat_icon_box.dart';
import 'status_badge.dart';

class FreightCarriersCard extends GetView<DashboardController> {
  const FreightCarriersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.012).clamp(13.0, 15.0);
    final cellSize = (size.width * 0.009).clamp(10.0, 12.0);
    final gap = DashboardGap.item(context);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Freight Carriers & Deliveries',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.cardBorder),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.01,
                    vertical: size.height * 0.008,
                  ),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DashboardGap.radius),
                  ),
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: cellSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DashboardGap.section(context)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.006,
              vertical: size.height * 0.008,
            ),
            decoration: BoxDecoration(
              color: AppColors.tableHeader,
              borderRadius: BorderRadius.circular(DashboardGap.radius),
            ),
            child: Row(
              children: [
                _Col('Carrier', flex: 3, size: cellSize),
                _Col('Loads Today', flex: 2, size: cellSize),
                _Col('On Time', flex: 2, size: cellSize),
                _Col('Delayed', flex: 2, size: cellSize),
                _Col('Priority', flex: 2, size: cellSize),
              ],
            ),
          ),
          SizedBox(height: gap),
          ...controller.carriers.map((row) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: gap * 0.8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.carrier,
                      style: TextStyle(
                        fontSize: cellSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(row.loadsToday, style: TextStyle(fontSize: cellSize)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(row.onTime, style: TextStyle(fontSize: cellSize)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(row.delayed, style: TextStyle(fontSize: cellSize)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusBadge(
                        label: row.priority,
                        color: row.priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: DashboardGap.section(context)),
          Row(
            children: [
              for (var i = 0; i < controller.freightSummaries.length; i++) ...[
                if (i > 0) SizedBox(width: DashboardGap.page(context)),
                Expanded(
                  child: _SummaryTile(item: controller.freightSummaries[i]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Col extends StatelessWidget {
  const _Col(this.text, {required this.flex, required this.size});

  final String text;
  final int flex;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.item});

  final FreightSummary item;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final valueSize = (size.width * 0.012).clamp(13.0, 16.0);
    final labelSize = (size.width * 0.008).clamp(9.0, 11.0);
    final iconSize = (size.width * 0.028).clamp(32.0, 38.0);

    // Figma freight stat card: icon on top, value + label below (gap 8)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DashboardGap.radius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatIconBox(color: item.iconBg, size: iconSize),
          const SizedBox(height: 8),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: labelSize,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
