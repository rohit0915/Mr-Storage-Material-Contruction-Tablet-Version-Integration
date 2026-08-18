import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/label_printing_controller.dart';

class LabelPrintingToolbar extends GetView<LabelPrintingController> {
  const LabelPrintingToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.width * 0.010).clamp(12.0, 14.0);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: (size.height * 0.048).clamp(42.0, 48.0),
            child: TextField(
              controller: controller.searchController,
              style: TextStyle(fontSize: fontSize, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: fontSize,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: fontSize + 6,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.012,
                  vertical: size.height * 0.012,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: size.width * 0.008),
        OutlinedButton.icon(
          onPressed: () {
            Get.snackbar(
              'Filter',
              'Filter options will be available soon.',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          },
          icon: const Icon(Icons.filter_list_rounded, size: 18),
          label: Text(
            'Filter',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.cardBorder),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.012,
              vertical: size.height * 0.014,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const Spacer(),
        Obx(() {
          final sort = controller.sortOption.value;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.010),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<LabelSortOption>(
                value: sort,
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                items: const [
                  DropdownMenuItem(
                    value: LabelSortOption.latest,
                    child: Text('Sort by: Latest'),
                  ),
                  DropdownMenuItem(
                    value: LabelSortOption.oldest,
                    child: Text('Sort by: Oldest'),
                  ),
                  DropdownMenuItem(
                    value: LabelSortOption.weightHigh,
                    child: Text('Sort by: Weight (High)'),
                  ),
                  DropdownMenuItem(
                    value: LabelSortOption.weightLow,
                    child: Text('Sort by: Weight (Low)'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) controller.setSort(v);
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}
