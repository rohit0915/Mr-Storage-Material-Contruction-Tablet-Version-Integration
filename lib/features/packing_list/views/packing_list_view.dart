import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
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
                if (Navigator.of(context).canPop()) ...[
                  InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
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
                Obx(
                  () => OutlinedButton.icon(
                    onPressed: controller.isExporting.value
                        ? null
                        : () => controller.exportReport(),
                    icon: controller.isExporting.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryBlue,
                            ),
                          )
                        : const Icon(Icons.download_rounded, size: 14),
                    label: Text(
                      controller.isExporting.value ? 'Exporting...' : 'Export',
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
                ),
              ],
            ),
            SizedBox(height: gap),

            // Summary cards section (Adaptive for Landscape and Portrait modes)
            Obx(() {
              final isLandscape = MediaQuery.sizeOf(context).width > 700;
              
              final t1Up = controller.apiTotalTrendType.value == 'up';
              final card1 = _StatCard(
                label: 'Total Packing List',
                value: '${controller.totalPackingList}',
                subtitle: '${t1Up ? '↑' : '↓'} ${controller.apiTotalTrend.value}% from last month',
                subtitleColor: t1Up ? AppColors.success : const Color(0xFFEF4444),
                bgColor: const Color(0xFF7C3AED),
              );
              
              final t2Up = controller.apiReadyTrendType.value == 'up';
              final card2 = _StatCard(
                label: 'Loads Ready For Dispatch',
                value: '${controller.loadsReadyForDispatch}',
                subtitle: '${t2Up ? '↑' : '↓'} ${controller.apiReadyTrend.value}% from last month',
                subtitleColor: t2Up ? AppColors.success : const Color(0xFFEF4444),
                bgColor: const Color(0xFF22C55E),
              );
              
              final t3Up = controller.apiBundlesAssignedTrendType.value == 'up';
              final card3 = _StatCard(
                label: 'Bundles Assigned',
                value: '${controller.bundlesAssigned}',
                subtitle: '${t3Up ? '↑' : '↓'} ${controller.apiBundlesAssignedTrend.value}% from last month',
                subtitleColor: t3Up ? AppColors.success : const Color(0xFFEF4444),
                bgColor: const Color(0xFFEAB308),
              );
              
              final t4Up = controller.apiDispatchTodayTrendType.value == 'up';
              final card4 = _StatCard(
                label: 'Loads Dispatch Today',
                value: '${controller.loadsDispatchToday}',
                subtitle: '${t4Up ? '↑' : '↓'} ${controller.apiDispatchTodayTrend.value}% from last month',
                subtitleColor: t4Up ? AppColors.success : const Color(0xFFEF4444),
                bgColor: const Color(0xFFEF4444),
              );

              if (isLandscape) {
                return Row(
                  children: [
                    Expanded(child: card1),
                    const SizedBox(width: 8),
                    Expanded(child: card2),
                    const SizedBox(width: 8),
                    Expanded(child: card3),
                    const SizedBox(width: 8),
                    Expanded(child: card4),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: card1),
                      const SizedBox(width: 8),
                      Expanded(child: card2),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: card3),
                      const SizedBox(width: 8),
                      Expanded(child: card4),
                    ],
                  ),
                ],
              );
            }),
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
                Obx(
                  () => Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedStatus.value,
                        icon: const Icon(
                          Icons.filter_list_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        style: TextStyle(
                          fontSize: subSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All Statuses',
                            child: Text('All Statuses'),
                          ),
                          DropdownMenuItem(
                            value: 'CONFIRMED',
                            child: Text('CONFIRMED'),
                          ),
                          DropdownMenuItem(
                            value: 'READY',
                            child: Text('READY'),
                          ),
                          DropdownMenuItem(
                            value: 'LOADING',
                            child: Text('LOADING'),
                          ),
                          DropdownMenuItem(
                            value: 'PENDING',
                            child: Text('PENDING'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) controller.setStatusFilter(val);
                        },
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedSort.value,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        style: TextStyle(
                          fontSize: subSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Latest',
                            child: Text('Sort by : Latest'),
                          ),
                          DropdownMenuItem(
                            value: 'Oldest',
                            child: Text('Sort by : Oldest'),
                          ),
                          DropdownMenuItem(
                            value: 'Weight High to Low',
                            child: Text('Sort by : Weight High'),
                          ),
                          DropdownMenuItem(
                            value: 'Weight Low to High',
                            child: Text('Sort by : Weight Low'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) controller.setSort(val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),

            // Packing List Table Container (Overflow-proof with horizontal scroll if needed)
            Obx(() {
              if (controller.isLoading.value) {
                return const AppShimmerTable(rowCount: 6);
              }
              final rows = controller.pageLists;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final minTableWidth = constraints.maxWidth < 1180.0
                        ? 1180.0
                        : constraints.maxWidth;
                    return Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: minTableWidth,
                          child: Column(
                            children: [
                              // Header row
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
                                    Container(
                                      width: 48,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: AppColors.cardBorder,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    _headCell('Packing List', 12, subSize),
                                    _headCell('Project / Job', 16, subSize),
                                    _headCell('Truck', 13, subSize),
                                    _headCell('Bundles', 9, subSize),
                                    _headCell('Total Weight', 13, subSize),
                                    _headCell('Destination', 13, subSize),
                                    _headCell('Status', 13, subSize),
                                    _headCell('Action', 11, subSize, isLast: true),
                                  ],
                                ),
                              ),
                              // Table Rows
                              ...rows.map(
                                (item) => _PackingListRow(
                                  item: item,
                                  fontSize: subSize,
                                  onView: () => Get.toNamed(
                                    AppRoutes.packingListDetail,
                                    arguments: item,
                                  ),
                                ),
                              ),
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

  static Widget _headCell(String text, int flex, double size, {bool isLast = false}) => Expanded(
    flex: flex,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                right: BorderSide(
                  color: AppColors.cardBorder,
                  width: 1.0,
                ),
              ),
      ),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
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

  final String label;
  final String value;
  final String subtitle;
  final Color subtitleColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(10.0, 12.0);
    final valueSize = (size.width * 0.018).clamp(22.0, 28.0);
    final circleSize = (size.width * 0.038).clamp(38.0, 44.0);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _CardWavePainter(color: bgColor)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.014,
              vertical: size.height * 0.016,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: valueSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: labelSize - 1,
                          color: subtitleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: circleSize,
                  height: circleSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: bgColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: Colors.white,
                    size: circleSize * 0.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardWavePainter extends CustomPainter {
  const _CardWavePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.3, size.height)
      ..cubicTo(
        size.width * 0.5,
        size.height * 0.95,
        size.width * 0.7,
        size.height * 0.6,
        size.width,
        size.height * 0.68,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.5, size.height)
      ..cubicTo(
        size.width * 0.7,
        size.height * 0.8,
        size.width * 0.85,
        size.height * 0.4,
        size.width,
        size.height * 0.45,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _CardWavePainter oldDelegate) =>
      oldDelegate.color != color;
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
  bool _checked = false;

  Widget _cell({required int flex, required Widget child, bool isLast = false, Alignment alignment = Alignment.centerLeft}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(right: BorderSide(color: AppColors.cardBorder, width: 1.0)),
        ),
        alignment: alignment,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.cardBorder, width: 1.0)),
            ),
            alignment: Alignment.center,
            child: Checkbox(
              value: _checked,
              onChanged: (v) => setState(() => _checked = v ?? false),
              activeColor: AppColors.primaryBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          _cell(
            flex: 12,
            child: Text(
              widget.item.packingListId,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _cell(
            flex: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.item.project,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  widget.item.jobId,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: widget.fontSize - 1,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _cell(
            flex: 13,
            child: Text(
              widget.item.truck,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _cell(
            flex: 9,
            child: Text(
              '${widget.item.bundles}',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _cell(
            flex: 13,
            child: Text(
              widget.item.totalWeight,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _cell(
            flex: 13,
            child: Text(
              widget.item.destination,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _cell(
            flex: 13,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(item: widget.item),
            ),
          ),
          _cell(
            flex: 11,
            isLast: true,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: widget.onView,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(60, 30),
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
                maxLines: 1,
                softWrap: false,
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
  const _StatusBadge({required this.item});
  final PackingListItem item;

  @override
  Widget build(BuildContext context) {
    final text = item.statusText.isNotEmpty
        ? item.statusText
        : (item.status == PackingListStatus.confirmed ||
                  item.status == PackingListStatus.ready
              ? 'CONFIRMED'
              : 'LOADING');

    Color textColor = const Color(0xFF166534);
    Color bg = const Color(0xFFDCFCE7);

    if (text.contains('CONFIRM') || text.contains('READY')) {
      textColor = const Color(0xFF166534);
      bg = const Color(0xFFDCFCE7);
    } else if (text.contains('LOAD') || text.contains('PEND')) {
      textColor = const Color(0xFF92400E);
      bg = const Color(0xFFFEF3C7);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: (MediaQuery.sizeOf(context).width * 0.008).clamp(
            10.0,
            11.0,
          ),
          fontWeight: FontWeight.w800,
          color: textColor,
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
      final total = controller.totalPackingList;
      final page = controller.pageIndex.value + 1;
      final limit = controller.pageSize.value;
      final from = total == 0 ? 0 : (page - 1) * limit + 1;
      final to = (page * limit).clamp(0, total);
      final pages = controller.totalPages;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: SHOWING [ 10 v ] RESULTS (Showing 1 - 10 of 13 Results)
            Row(
              children: [
                const Text(
                  'SHOWING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: [10, 20, 50].contains(limit) ? limit : 10,
                      isDense: true,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(value: 10, child: Text('10')),
                        DropdownMenuItem(value: 20, child: Text('20')),
                        DropdownMenuItem(value: 50, child: Text('50')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          controller.changeLimit(val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'RESULTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Showing $from – $to of $total Results',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Right side: < 1 2 3 ... >
            Row(
              children: [
                _PageBtn(
                  icon: Icons.chevron_left_rounded,
                  enabled: page > 1,
                  onTap: controller.prevPage,
                ),
                const SizedBox(width: 4),
                ...List.generate(pages.clamp(0, 5), (i) {
                  final pNum = i + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => controller.changePage(pNum),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: pNum == page
                              ? AppColors.primaryBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: pNum == page
                              ? null
                              : Border.all(color: AppColors.cardBorder),
                        ),
                        child: Text(
                          '$pNum',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: pNum == page
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (pages > 5) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('...'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => controller.changePage(pages),
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: page == pages
                              ? AppColors.primaryBlue
                              : Colors.transparent,
                          border: page == pages
                              ? null
                              : Border.all(color: AppColors.cardBorder),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$pages',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: page == pages
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                _PageBtn(
                  icon: Icons.chevron_right_rounded,
                  enabled: page < pages,
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
