import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../controllers/dispatch_verification_controller.dart';
import '../models/dispatch_verification_models.dart';
import '../widgets/dispatch_verification_dialogs.dart';

class DispatchVerificationView extends GetView<DispatchVerificationController> {
  const DispatchVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final gap = size.height * 0.014;
    final titleSize = (size.width * 0.018).clamp(20.0, 26.0);
    final subSize = (size.width * 0.010).clamp(11.0, 13.0);
    final btnSize = (size.width * 0.009).clamp(11.0, 13.0);

    void showSuccess(String title) =>
        DispatchVerificationSuccessDialog.show(context, title);

    return AppScaffold(
      menuTitle: 'Dispatch Verification',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, size.height * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row matching Image 1
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
                        'Dispatch Verification',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.004),
                      Text(
                        'Verify bundles and truckload details before confirming dispatch from the plant.',
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
                SizedBox(width: size.width * 0.007),
                ElevatedButton(
                  onPressed: () =>
                      showSuccess('Dispatch Confirmed\nsuccessfully'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED), // Vibrant purple
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.012,
                      vertical: size.height * 0.010,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirm Dispatch',
                    style: TextStyle(
                      fontSize: btnSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.007),
                ElevatedButton(
                  onPressed: () =>
                      showSuccess('Load Marked Verified\nsuccessfully'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED), // Vibrant purple
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.012,
                      vertical: size.height * 0.010,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Verify Load',
                    style: TextStyle(
                      fontSize: btnSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),

            // Summary cards section with Wave Background matching Web Panel
            Obx(() {
              final card1 = _StatCard(
                label: 'Loads Ready for Dispatch',
                value: '${controller.loadsReadyCount.value}',
                subtitle: '↑ 5.62% from last month',
                subtitleColor: AppColors.success,
                bgColor: const Color(0xFF7C3AED),
                icon: Icons.qr_code_rounded,
              );
              final card2 = _StatCard(
                label: 'Bundles Verified',
                value: '${controller.bundlesVerifiedCount.value}',
                subtitle: '↑ 11.4% from last month',
                subtitleColor: AppColors.success,
                bgColor: const Color(0xFF22C55E),
                icon: Icons.check_circle_outline_rounded,
              );
              final card3 = _StatCard(
                label: 'Bundles Missing',
                value: '${controller.bundlesMissingCount.value}',
                subtitle: '↑ 8.52% from last month',
                subtitleColor: AppColors.success,
                bgColor: const Color(0xFFEAB308),
                icon: Icons.hourglass_empty_rounded,
              );
              final card4 = _StatCard(
                label: 'Leads Dispatched Today',
                value: '${controller.dispatchedTodayCount.value}',
                subtitle: '↓ 7.45% from last month',
                subtitleColor: const Color(0xFFEF4444),
                bgColor: const Color(0xFFEF4444),
                icon: Icons.speed_rounded,
              );

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = constraints.maxWidth > 700;
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
                },
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
                            value: 'verified',
                            child: Text('VERIFIED'),
                          ),
                          DropdownMenuItem(
                            value: 'pending',
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

            // Data Table Container matching Image 1
            Obx(() {
              if (controller.isLoading.value) {
                return const AppShimmerTable(rowCount: 6);
              }
              final rows = controller.pageItems;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final minTableWidth = constraints.maxWidth.clamp(
                      720.0,
                      2000.0,
                    );
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
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: false,
                                      onChanged: null,
                                      activeColor: AppColors.primaryBlue,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _headCell('LOAD ID', 4, subSize),
                                  _headCell('TRUCK', 3, subSize),
                                  _headCell('DRIVER', 2, subSize),
                                  _headCell('BUNDLES ⇅', 2, subSize),
                                  _headCell('TOTAL WEIGHT ⇅', 3, subSize),
                                  _headCell('DESTINATION', 3, subSize),
                                  _headCell('STATUS', 2, subSize),
                                  _headCell(
                                    'ACTION',
                                    2,
                                    subSize,
                                    align: TextAlign.end,
                                  ),
                                ],
                              ),
                            ),
                            // Table Rows
                            ...rows.map(
                              (item) => _DispatchRow(
                                item: item,
                                fontSize: subSize,
                                onView: () => Get.toNamed(
                                  AppRoutes.dispatchVerificationDetail,
                                  arguments: item,
                                ),
                              ),
                            ),
                            if (rows.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'No loads found.',
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

  static Widget _headCell(
    String text,
    int flex,
    double size, {
    TextAlign align = TextAlign.start,
  }) => Expanded(
    flex: flex,
    child: Text(
      text,
      textAlign: align,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
    required this.bgColor,
    required this.icon,
  });

  final String label, value, subtitle;
  final Color subtitleColor, bgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.0085).clamp(9.5, 11.5);
    final valueSize = (size.width * 0.016).clamp(18.0, 24.0);
    final circleSize = (size.width * 0.032).clamp(34.0, 40.0);

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
              horizontal: size.width * 0.010,
              vertical: size.height * 0.014,
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
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: valueSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: (labelSize - 1.2).clamp(8.5, 10.5),
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
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
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

class _DispatchRow extends StatefulWidget {
  const _DispatchRow({
    required this.item,
    required this.fontSize,
    required this.onView,
  });

  final DispatchItem item;
  final double fontSize;
  final VoidCallback onView;

  @override
  State<_DispatchRow> createState() => _DispatchRowState();
}

class _DispatchRowState extends State<_DispatchRow> {
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
            width: 20,
            height: 20,
            child: Checkbox(
              value: _checked,
              onChanged: (v) => setState(() => _checked = v ?? false),
              activeColor: AppColors.primaryBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.loadId,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'PACKING LIST: ${widget.item.packingListNo}',
                  style: TextStyle(
                    fontSize: (widget.fontSize - 2).clamp(10.0, 12.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              widget.item.truck,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              widget.item.driver,
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
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.destination,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.item.project.toUpperCase()} (${widget.item.jobId})',
                  style: TextStyle(
                    fontSize: (widget.fontSize - 2).clamp(10.0, 12.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(status: widget.item.status),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: widget.onView,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF4F46E5,
                  ), // Purple matching Web Panel Image 1
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'VIEW LOAD',
                  style: TextStyle(
                    fontSize: (widget.fontSize - 1).clamp(11.0, 13.0),
                    fontWeight: FontWeight.w700,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final DispatchStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      DispatchStatus.pending => (
        'Pending ⌛',
        const Color(0xFFFEF3C7),
        const Color(0xFF92400E),
      ),
      DispatchStatus.verified => (
        'Verified ⊙',
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.controller, required this.fontSize});
  final DispatchVerificationController controller;
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
                        color: i == page ? Colors.white : AppColors.textPrimary,
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
