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
                final minTableWidth =
                    constraints.maxWidth < 1180.0 ? 1180.0 : constraints.maxWidth;
                return Scrollbar(
                  thumbVisibility: false,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: minTableWidth,
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFF1F5F9),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                _HeadCell(
                                  flex: 13,
                                  text: 'REQUEST ID',
                                  size: cellFont,
                                ),
                                _HeadCell(
                                  flex: 17,
                                  text: 'PROJECT / SITE',
                                  size: cellFont,
                                ),
                                _HeadCell(
                                  flex: 11,
                                  text: 'ITEMS',
                                  size: cellFont,
                                ),
                                _HeadCell(
                                  flex: 12,
                                  text: 'DATE',
                                  size: cellFont,
                                ),
                                _HeadCell(
                                  flex: 11,
                                  text: 'REQUIRED',
                                  size: cellFont,
                                ),
                                _HeadCell(
                                  flex: 12,
                                  text: 'STATUS',
                                  size: cellFont,
                                ),
                                _HeadCell(
                                  flex: 11,
                                  text: 'PRIORITY',
                                  size: cellFont,
                                ),
                                _HeadCell(
                                  flex: 11,
                                  text: 'ACTIONS',
                                  size: cellFont,
                                  alignment: Alignment.center,
                                  textAlign: TextAlign.center,
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
        color: isEven ? Colors.white : const Color(0xFFFAFAFA),
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _DataCell(
            flex: 13,
            child: Text(
              item.id,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: cellFont,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _DataCell(
            flex: 17,
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
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.requestedItemsCount} Items',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
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
            flex: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dateFmt.format(item.requestDate),
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: cellFont,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  timeFmt.format(item.requestDate),
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: cellFont - 1,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _DataCell(
            flex: 11,
            child: Text(
              item.requiredBy == null ? '-' : dateFmt.format(item.requiredBy!),
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: cellFont,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _DataCell(
            flex: 12,
            child: _StatusLabel(status: item.status),
          ),
          _DataCell(
            flex: 11,
            child: _PriorityLabel(priority: item.priority),
          ),
          _DataCell(
            flex: 11,
            alignment: Alignment.center,
            isLast: true,
            child: SizedBox(
              height: 30,
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
                  foregroundColor: const Color(0xFF374151),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 0,
                  ),
                  minimumSize: const Size(60, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'View',
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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
    this.alignment = Alignment.centerLeft,
    this.textAlign = TextAlign.start,
    this.isLast = false,
  });

  final int flex;
  final String text;
  final double size;
  final Alignment alignment;
  final TextAlign textAlign;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        alignment: alignment,
        child: Text(
          text,
          textAlign: textAlign,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
          maxLines: 1,
          softWrap: false,
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
    this.alignment = Alignment.centerLeft,
    this.isLast = false,
  });

  final int flex;
  final Widget child;
  final Alignment alignment;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        alignment: alignment,
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
    final (label, color, bg, border) = switch (status) {
      MaterialRequestStatus.pending => (
        'Pending',
        const Color(0xFFD97706),
        const Color(0xFFFFFBEB),
        const Color(0xFFFEF3C7),
      ),
      MaterialRequestStatus.approved => (
        'Approved',
        const Color(0xFF16A34A),
        const Color(0xFFF0FDF4),
        const Color(0xFFDCFCE7),
      ),
      MaterialRequestStatus.rejected => (
        'Rejected',
        const Color(0xFFEF4444),
        const Color(0xFFFEF2F2),
        const Color(0xFFFEE2E2),
      ),
      MaterialRequestStatus.cancelled => (
        'Cancelled',
        const Color(0xFF6B7280),
        const Color(0xFFF9FAFB),
        const Color(0xFFE5E7EB),
      ),
      MaterialRequestStatus.fulfilled => (
        'Fulfilled',
        const Color(0xFF2563EB),
        const Color(0xFFEFF6FF),
        const Color(0xFFDBEAFE),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: (MediaQuery.sizeOf(context).width * 0.0075).clamp(10.0, 11.0),
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
    Color bg = const Color(0xFFF3F4F6);
    Color fg = const Color(0xFF4B5563);
    Color border = const Color(0xFFE5E7EB);

    final lower = priority.toLowerCase();
    if (lower.contains('low')) {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF2563EB);
      border = const Color(0xFFDBEAFE);
    } else if (lower.contains('medium')) {
      bg = const Color(0xFFFEFCE8);
      fg = const Color(0xFFCA8A04);
      border = const Color(0xFFFEF08A);
    } else if (lower.contains('high')) {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFEF4444);
      border = const Color(0xFFFEE2E2);
    } else if (lower.contains('critical') || lower.contains('urgent')) {
      bg = const Color(0xFFFFF1F2);
      fg = const Color(0xFFBE123C);
      border = const Color(0xFFFECDD3);
    }

    final displayText = priority.isNotEmpty
        ? priority[0].toUpperCase() + priority.substring(1)
        : priority;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        displayText,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: (MediaQuery.sizeOf(context).width * 0.0075).clamp(10.0, 11.0),
        ),
      ),
    );
  }
}
