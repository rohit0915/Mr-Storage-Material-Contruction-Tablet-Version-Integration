import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/bundle_scan_controller.dart';
import '../models/bundle_scan_models.dart';
import '../widgets/bundle_scan_dialogs.dart';

class BundleScanView extends GetView<BundleScanController> {
  const BundleScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final gap = size.height * 0.014;
    final titleSize = (size.width * 0.018).clamp(20.0, 26.0);
    final subSize = (size.width * 0.010).clamp(11.0, 13.0);
    final btnSize = (size.width * 0.009).clamp(11.0, 13.0);

    return AppScaffold(
      menuTitle: 'Bundle Scan',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, size.height * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bundle Scan',
                          style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      SizedBox(height: size.height * 0.004),
                      Text(
                          'Scan bundle QR codes to verify staging, loading, and dispatch readiness.',
                          style: TextStyle(
                              fontSize: subSize,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 14),
                  label: Text('Export',
                      style: TextStyle(
                          fontSize: btnSize, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.010,
                        vertical: size.height * 0.010),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(width: size.width * 0.007),
                ElevatedButton.icon(
                  onPressed: () => BundleScanQrDialog.show(
                    context,
                    onScanned: (bundleId) => Get.toNamed(
                      AppRoutes.bundleScanDetail,
                      arguments: controller.pageBundles.firstOrNull,
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 14),
                  label: Text('Scan QR Code',
                      style: TextStyle(
                          fontSize: btnSize, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.012,
                        vertical: size.height * 0.010),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(width: size.width * 0.007),
                ElevatedButton.icon(
                  onPressed: () => BundleScanQrDialog.show(
                    context,
                    onScanned: (bundleId) => Get.toNamed(
                      AppRoutes.bundleScanDetail,
                      arguments: controller.pageBundles.firstOrNull,
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: Text('Manual Entry',
                      style: TextStyle(
                          fontSize: btnSize, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.012,
                        vertical: size.height * 0.010),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            // Summary cards
            Row(children: [
              _SummaryCard(
                label: 'Bundles Scanned',
                value: '${controller.bundlesScanned}',
                subtitle: '↑ 5.62% from last month',
                subtitleColor: AppColors.success,
                dotColor: AppColors.brandPrimary,
              ),
              SizedBox(width: size.width * 0.010),
              _SummaryCard(
                label: 'Bundles Remaining',
                value: '${controller.bundlesRemaining}',
                subtitle: '↓ 1.4% from last month',
                subtitleColor: AppColors.success,
                dotColor: const Color(0xFF22C55E),
              ),
              SizedBox(width: size.width * 0.010),
              _SummaryCard(
                label: 'Bundles Loaded',
                value: '${controller.bundlesLoaded}',
                subtitle: '↑ 0.52% from last month',
                subtitleColor: AppColors.success,
                dotColor: const Color(0xFFF59E0B),
              ),
            ]),
            SizedBox(height: gap),
            // Search + Filter + Sort
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearch,
                    style: TextStyle(
                        fontSize: subSize, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                          fontSize: subSize, color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search,
                          size: 18, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded, size: 14),
                label: Text('Filter',
                    style: TextStyle(
                        fontSize: btnSize, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.cardBorder),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const Spacer(),
              Row(children: [
                Text('Sort by : Latest',
                    style: TextStyle(
                        fontSize: subSize, color: AppColors.textSecondary)),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: AppColors.textSecondary),
              ]),
            ]),
            SizedBox(height: gap),
            // Table
            Text('Bundle scan History',
                style: TextStyle(
                    fontSize: (size.width * 0.013).clamp(15.0, 18.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            SizedBox(height: size.height * 0.010),
            Obx(() {
              final rows = controller.pageBundles;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(children: [
                  // Header row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.tableHeader,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                    ),
                    child: Row(children: [
                      const SizedBox(width: 32),
                      headCell('Project / Site', 4, subSize),
                      headCell('Bundle ID', 2, subSize),
                      headCell('Parts', 2, subSize),
                      headCell('Total Weight', 2, subSize),
                      headCell('Time', 2, subSize),
                      headCell('Status', 2, subSize),
                      headCell('Action', 2, subSize),
                    ]),
                  ),
                  ...rows.map((item) => _BundleRow(
                        item: item,
                        fontSize: subSize,
                        onView: () => Get.toNamed(
                          AppRoutes.bundleScanDetail,
                          arguments: item,
                        ),
                      )),
                  if (rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text('No bundles found.',
                            style: TextStyle(
                                fontSize: subSize,
                                color: AppColors.textSecondary)),
                      ),
                    ),
                  // Pagination
                  _PaginationBar(controller: controller, fontSize: subSize),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
    required this.dotColor,
  });
  final String label, value, subtitle;
  final Color subtitleColor, dotColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(10.0, 12.0);
    final valueSize = (size.width * 0.018).clamp(22.0, 28.0);

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.014, vertical: size.height * 0.016),
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
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      fontSize: labelSize,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      fontSize: valueSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: labelSize - 1,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: dotColor,
            child: const Icon(Icons.qr_code_rounded,
                color: Colors.white, size: 22),
          ),
        ]),
      ),
    );
  }
}

// ─── Table helpers ─────────────────────────────────────────────────────────────

Widget headCell(String text, int flex, double size) => Expanded(
    flex: flex,
    child: Text(text,
        style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary)));

class _BundleRow extends StatefulWidget {
  const _BundleRow(
      {required this.item, required this.fontSize, required this.onView});
  final BundleScanItem item;
  final double fontSize;
  final VoidCallback onView;

  @override
  State<_BundleRow> createState() => _BundleRowState();
}

class _BundleRowState extends State<_BundleRow> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppColors.cardBorder))),
      child: Row(children: [
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
          flex: 4,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.item.project,
                style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text(widget.item.site,
                style: TextStyle(
                    fontSize: widget.fontSize - 1,
                    color: AppColors.textSecondary)),
          ]),
        ),
        Expanded(
            flex: 2,
            child: Text(widget.item.bundleId,
                style: TextStyle(
                    fontSize: widget.fontSize, color: AppColors.textPrimary))),
        Expanded(
            flex: 2,
            child: Text(widget.item.parts,
                style: TextStyle(
                    fontSize: widget.fontSize, color: AppColors.textSecondary))),
        Expanded(
            flex: 2,
            child: Text(widget.item.totalWeight,
                style: TextStyle(
                    fontSize: widget.fontSize, color: AppColors.textSecondary))),
        Expanded(
            flex: 2,
            child: Text(widget.item.time,
                style: TextStyle(
                    fontSize: widget.fontSize, color: AppColors.textSecondary))),
        Expanded(flex: 2, child: _StatusBadge(widget.item.status)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: Text('View',
                style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);
  final BundleScanStatus status;
  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      BundleScanStatus.staging => ('Staging S', const Color(0xFFFEF3C7), const Color(0xFFF59E0B)),
      BundleScanStatus.ready => ('Ready R', const Color(0xFFDCFCE7), AppColors.success),
      BundleScanStatus.pending => ('Pending', const Color(0xFFEFF6FF), AppColors.primaryBlue),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ─── Pagination ───────────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  const _PaginationBar(
      {required this.controller, required this.fontSize});
  final BundleScanController controller;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.filteredBundles.length;
      final page = controller.pageIndex.value;
      final size = controller.pageSize;
      final from = total == 0 ? 0 : page * size + 1;
      final to = ((page + 1) * size).clamp(0, total);
      final pages = controller.totalPages;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Text('Showing $from – $to  Results',
              style: TextStyle(
                  fontSize: fontSize, color: AppColors.textSecondary)),
          const Spacer(),
          _PageBtn(
            icon: Icons.chevron_left_rounded,
            enabled: page > 0,
            onTap: controller.prevPage,
          ),
          const SizedBox(width: 4),
          ...List.generate(pages.clamp(0, 5), (i) {
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
                  child: Text('${i + 1}',
                      style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          color: i == page
                              ? Colors.white
                              : AppColors.textPrimary)),
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
                onTap: () => controller.goToPage(pages - 1),
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('$pages',
                      style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
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
        ]),
      );
    });
  }
}

class _PageBtn extends StatelessWidget {
  const _PageBtn(
      {required this.icon, required this.enabled, required this.onTap});
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
          child: Icon(icon,
              size: 18,
              color: enabled
                  ? AppColors.textPrimary
                  : AppColors.textSecondary),
        ),
      );
}
