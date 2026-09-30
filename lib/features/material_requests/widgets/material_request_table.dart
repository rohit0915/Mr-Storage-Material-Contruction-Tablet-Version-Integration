import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/material_requests_controller.dart';
import '../models/material_request_models.dart';
import 'material_request_details_dialog.dart';

import '../../../app/widgets/app_shimmer.dart';

class MaterialRequestTable extends GetView<MaterialRequestsController> {
  const MaterialRequestTable({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cellFont = (size.width * 0.008).clamp(11.0, 12.0);
    final titleSize = (size.width * 0.012).clamp(14.0, 16.0);

    return Obx(() {
      if (controller.isLoading.value) {
        return const AppShimmerTable(rowCount: 6);
      }
      final _ = controller.pageIndex.value;
      final rows = controller.pageRequests;
      final totalCount = controller.serverTotal.value;
      final currentPage = controller.pageIndex.value;
      final totalPages = controller.totalPages;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                size.width * 0.012,
                size.height * 0.016,
                size.width * 0.012,
                size.height * 0.010,
              ),
              child: Text(
                'Material Request ($totalCount)',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final minTableWidth = constraints.maxWidth.clamp(
                  1150.0,
                  2400.0,
                );
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: minTableWidth,
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.tableHeader,
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.cardBorder,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              _HeadCell(
                                flex: 2,
                                text: 'Request ID',
                                size: cellFont,
                              ),
                              _HeadCell(
                                flex: 3,
                                text: 'Project / Site',
                                size: cellFont,
                              ),
                              _HeadCell(
                                flex: 2,
                                text: 'Requested Items',
                                size: cellFont,
                              ),
                              _HeadCell(
                                flex: 2,
                                text: 'Request Date',
                                size: cellFont,
                              ),
                              _HeadCell(
                                flex: 2,
                                text: 'Required By',
                                size: cellFont,
                              ),
                              _HeadCell(
                                flex: 2,
                                text: 'Status',
                                size: cellFont,
                              ),
                              _HeadCell(
                                flex: 2,
                                text: 'Priority',
                                size: cellFont,
                              ),
                              _HeadCell(
                                flex: 2,
                                text: 'Actions',
                                size: cellFont,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        ...rows.asMap().entries.map(
                          (entry) => _DataRow(
                            item: entry.value,
                            cellFont: cellFont,
                            isEven: entry.key % 2 == 0,
                          ),
                        ),
                        if (rows.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No material requests found.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: cellFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
            _PaginationFooter(
              currentPage: currentPage,
              totalPages: totalPages,
              totalCount: totalCount,
              pageSize: controller.pageSize,
            ),
          ],
        ),
      );
    });
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.item,
    required this.cellFont,
    this.isEven = true,
  });

  final MaterialRequestBoardItem item;
  final double cellFont;
  final bool isEven;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    final timeFmt = DateFormat('hh:mm a');

    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF8FAFC),
        border: const Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _DataCell(
            flex: 2,
            child: Text(
              item.id,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: cellFont,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _DataCell(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.project,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: cellFont,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  item.site,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: cellFont - 1,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _DataCell(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.requestedItemsCount} Items',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: cellFont,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.itemsPreview.isNotEmpty)
                  Text(
                    item.itemsPreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: cellFont - 1,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          _DataCell(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dateFmt.format(item.requestDate),
                  style: TextStyle(
                    fontSize: cellFont,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  timeFmt.format(item.requestDate),
                  style: TextStyle(
                    fontSize: cellFont - 1,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _DataCell(
            flex: 2,
            child: Text(
              item.requiredBy == null ? '-' : dateFmt.format(item.requiredBy!),
              style: TextStyle(
                fontSize: cellFont,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _DataCell(flex: 2, child: _StatusLabel(status: item.status)),
          _DataCell(flex: 2, child: _PriorityLabel(priority: item.priority)),
          _DataCell(
            flex: 2,
            isLast: true,
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () async {
                  final detail = await Get.find<MaterialRequestsController>()
                      .loadDetails(item);
                  if (!context.mounted) return;
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => MaterialRequestDetailsDialog(item: detail),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  backgroundColor: const Color(0xFFF9FAFB),
                  side: const BorderSide(color: AppColors.cardBorder),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: cellFont,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationFooter extends GetView<MaterialRequestsController> {
  const _PaginationFooter({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
  });

  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.width * 0.009).clamp(11.0, 12.0);

    final pages = _visiblePages(currentPage, totalPages);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.012,
        vertical: size.height * 0.014,
      ),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                'Showing',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Text(
                      '$pageSize',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Results',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
          const Spacer(),
          _PageArrow(
            icon: Icons.chevron_left,
            enabled: currentPage > 0,
            onTap: controller.prevPage,
          ),
          const SizedBox(width: 6),
          ...pages.map((p) {
            if (p == -1) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: fontSize,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _PageNumber(
                page: p + 1,
                isActive: p == currentPage,
                onTap: () => controller.goToPage(p),
              ),
            );
          }),
          const SizedBox(width: 6),
          _PageArrow(
            icon: Icons.chevron_right,
            enabled: currentPage < totalPages - 1,
            onTap: controller.nextPage,
          ),
        ],
      ),
    );
  }

  List<int> _visiblePages(int current, int total) {
    if (total <= 5) {
      return List.generate(total, (i) => i);
    }
    if (current <= 1) return [0, 1, 2, -1, total - 1];
    if (current >= total - 2) return [0, -1, total - 3, total - 2, total - 1];
    return [0, -1, current, -1, total - 1];
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  const _PageNumber({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  final int page;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? AppColors.primaryBlue : AppColors.cardBorder,
            width: isActive ? 2 : 1,
          ),
          color: Colors.white,
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell({
    required this.flex,
    required this.text,
    required this.size,
    this.isLast = false,
  });

  final int flex;
  final String text;
  final double size;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  right: BorderSide(
                    color: AppColors.cardBorder.withValues(alpha: 0.7),
                  ),
                ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: size,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.flex,
    required this.child,
    this.isLast = false,
  });

  final int flex;
  final Widget child;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  right: BorderSide(
                    color: AppColors.cardBorder.withValues(alpha: 0.5),
                  ),
                ),
        ),
        child: child,
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final MaterialRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      MaterialRequestStatus.pending => (
        'Pending',
        const Color(0xFF92400E),
        const Color(0xFFFEF3C7),
      ),
      MaterialRequestStatus.approved => (
        'Approved',
        const Color(0xFF166534),
        const Color(0xFFDCFCE7),
      ),
      MaterialRequestStatus.rejected => (
        'Rejected',
        const Color(0xFF991B1B),
        const Color(0xFFFEE2E2),
      ),
      MaterialRequestStatus.cancelled => (
        'Cancelled',
        const Color(0xFF991B1B),
        const Color(0xFFFEE2E2),
      ),
      MaterialRequestStatus.fulfilled => (
        'Fulfilled',
        const Color(0xFF166534),
        const Color(0xFFDCFCE7),
      ),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: (MediaQuery.sizeOf(context).width * 0.008).clamp(
              11.0,
              12.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityLabel extends StatelessWidget {
  const _PriorityLabel({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      'High' => const Color(0xFFDC2626),
      'Medium' => const Color(0xFFD97706),
      _ => const Color(0xFF2563EB),
    };

    return Text(
      priority,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: (MediaQuery.sizeOf(context).width * 0.008).clamp(11.0, 12.0),
      ),
    );
  }
}
