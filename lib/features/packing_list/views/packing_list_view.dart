import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/packing_list_controller.dart';
import '../models/packing_list_models.dart';

class PackingListView extends GetView<PackingListController> {
  const PackingListView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final gap = size.height * 0.014;
    final titleSize = (size.width * 0.018).clamp(20.0, 26.0);
    final subSize = (size.width * 0.010).clamp(11.0, 13.0);
    final btnSize = (size.width * 0.009).clamp(11.0, 13.0);

    return AppScaffold(
      menuTitle: 'Packing List',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, size.height * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Subtitle + Export button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Packing List',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.004),
                      Text(
                        'View and manage packing lists for truckloads to verify bundles before loading and dispatch.',
                        style: TextStyle(
                          fontSize: subSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 14),
                  label: Text(
                    'Export',
                    style: TextStyle(
                      fontSize: btnSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.012,
                      vertical: size.height * 0.010,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),

            // Summary cards section (Adaptive for Landscape and Portrait modes)
            LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > 700;
                const card1 = _StatCard(
                  label: 'Total Packing List',
                  value: '24',
                  subtitle: '↑ 5.62% from last month',
                  subtitleColor: AppColors.success,
                  bgColor: Color(0xFF7C3AED),
                );
                const card2 = _StatCard(
                  label: 'Loads Ready For Dispatch',
                  value: '15',
                  subtitle: '↑ 11.4% from last month',
                  subtitleColor: AppColors.success,
                  bgColor: Color(0xFF22C55E),
                );
                const card3 = _StatCard(
                  label: 'Bundles Assigned',
                  value: '58',
                  subtitle: '↑ 8.52% from last month',
                  subtitleColor: AppColors.success,
                  bgColor: Color(0xFFEAB308),
                );
                const card4 = _StatCard(
                  label: 'Loads Dispatch Today',
                  value: '3',
                  subtitle: '↓ 7.45% from last month',
                  subtitleColor: Color(0xFFEF4444),
                  bgColor: Color(0xFFEF4444),
                );

                if (isLandscape) {
                  return Row(
                    children: const [
                      Expanded(child: card1),
                      SizedBox(width: 8),
                      Expanded(child: card2),
                      SizedBox(width: 8),
                      Expanded(child: card3),
                      SizedBox(width: 8),
                      Expanded(child: card4),
                    ],
                  );
                }

                return Column(
                  children: const [
                    Row(
                      children: [
                        Expanded(child: card1),
                        SizedBox(width: 8),
                        Expanded(child: card2),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: card3),
                        SizedBox(width: 8),
                        Expanded(child: card4),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: gap),

            // Search + Filter + Sort Row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearch,
                      style: TextStyle(
                        fontSize: subSize,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          fontSize: subSize,
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list_rounded, size: 14),
                  label: Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: btnSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'Sort by : Latest',
                      style: TextStyle(
                        fontSize: subSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: gap),

            // Packing List Table Container (Overflow-proof with horizontal scroll if needed)
            Obx(() {
              final rows = controller.pageLists;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final minTableWidth = constraints.maxWidth.clamp(720.0, 2000.0);
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: minTableWidth,
                        child: Column(
                          children: [
                            // Header row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.tableHeader,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 32),
                                  _headCell('Packing List', 3, subSize),
                                  _headCell('Load', 3, subSize),
                                  _headCell('Truck', 3, subSize),
                                  _headCell('Bundles ↑↓', 2, subSize),
                                  _headCell('Total Weight ↑↓', 3, subSize),
                                  _headCell('Destination', 3, subSize),
                                  _headCell('Status', 3, subSize),
                                  _headCell('Action', 2, subSize),
                                ],
                              ),
                            ),
                            // Table Rows
                            ...rows.map((item) => _PackingListRow(
                                  item: item,
                                  fontSize: subSize,
                                  onView: () => Get.toNamed(
                                    AppRoutes.packingListDetail,
                                    arguments: item,
                                  ),
                                )),
                            if (rows.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'No packing lists found.',
                                    style: TextStyle(
                                      fontSize: subSize,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            // Pagination Bar
                            _PaginationBar(
                              controller: controller,
                              fontSize: subSize,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static Widget _headCell(String text, int flex, double size) => Expanded(
        flex: flex,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      );
}

// ─── Stat Card Component ──────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
    required this.bgColor,
  });

  final String label, value, subtitle;
  final Color subtitleColor, bgColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.0085).clamp(9.5, 11.5);
    final valueSize = (size.width * 0.016).clamp(18.0, 24.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.008,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: labelSize,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: (labelSize - 1.5).clamp(8.0, 10.0),
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: bgColor,
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Table Row Component ──────────────────────────────────────────────────────

class _PackingListRow extends StatefulWidget {
  const _PackingListRow({
    required this.item,
    required this.fontSize,
    required this.onView,
  });

  final PackingListItem item;
  final double fontSize;
  final VoidCallback onView;

  @override
  State<_PackingListRow> createState() => _PackingListRowState();
}

class _PackingListRowState extends State<_PackingListRow> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.item.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Checkbox(
              value: _checked,
              onChanged: (v) => setState(() => _checked = v ?? false),
              activeColor: AppColors.primaryBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              widget.item.packingListId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              widget.item.loadId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              widget.item.truck,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${widget.item.bundles}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              widget.item.totalWeight,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              widget.item.destination,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(status: widget.item.status),
            ),
          ),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: widget.onView,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'View',
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Badge Component ───────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final PackingListStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      PackingListStatus.loading => (
          'Loading ⌛',
          const Color(0xFFFEF3C7),
          const Color(0xFFF59E0B),
        ),
      PackingListStatus.ready => (
          'Ready ⊙',
          const Color(0xFFDCFCE7),
          const Color(0xFF10B981),
        ),
      PackingListStatus.pending => (
          'Loading ⌛',
          const Color(0xFFFEF3C7),
          const Color(0xFFF59E0B),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ─── Pagination Bar Component ─────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.controller, required this.fontSize});
  final PackingListController controller;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final page = controller.pageIndex.value;
      final pages = controller.totalPages;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              'Showing 10 Results',
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _PageBtn(
              icon: Icons.chevron_left_rounded,
              enabled: page > 0,
              onTap: controller.prevPage,
            ),
            const SizedBox(width: 4),
            ...List.generate(pages.clamp(0, 3), (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => controller.goToPage(i),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == page
                          ? AppColors.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: i == page
                          ? null
                          : Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: i == page
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (pages > 3) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('...'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => controller.goToPage(14),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '15',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            _PageBtn(
              icon: Icons.chevron_right_rounded,
              enabled: page < pages - 1,
              onTap: controller.nextPage,
            ),
          ],
        ),
      );
    });
  }
}

class _PageBtn extends StatelessWidget {
  const _PageBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(6),
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
