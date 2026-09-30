import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/material_requests_controller.dart';

class MaterialRequestPaginationBar extends GetView<MaterialRequestsController> {
  const MaterialRequestPaginationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.010).clamp(8.0, 12.0);

    return Obx(() {
      final total = controller.serverTotal.value;
      if (total == 0) {
        return const SizedBox.shrink();
      }

      final start = controller.pageIndex.value * controller.pageSize + 1;
      final end = (start + controller.pageSize - 1).clamp(1, total);

      final current = controller.pageIndex.value;
      final pages = controller.totalPages;

      return Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Showing $start to $end Results',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: (size.width * 0.010).clamp(12.0, 13.0),
                ),
              ),
            ),
            Row(
              children: [
                _PageButton(
                  label: 'Prev',
                  enabled: current > 0,
                  onTap: controller.prevPage,
                ),
                SizedBox(width: gap),
                Wrap(
                  spacing: 6,
                  children: List.generate(pages, (i) {
                    return _PageNumber(
                      index: i,
                      isActive: i == current,
                      onTap: () => controller.goToPage(i),
                    );
                  }),
                ),
                SizedBox(width: gap),
                _PageButton(
                  label: 'Next',
                  enabled: current < pages - 1,
                  onTap: controller.nextPage,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: enabled ? Colors.white : const Color(0xFFF3F4F6),
        side: BorderSide(color: AppColors.cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(label),
    );
  }
}

class _PageNumber extends StatelessWidget {
  const _PageNumber({
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  final int index;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : Colors.white,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
