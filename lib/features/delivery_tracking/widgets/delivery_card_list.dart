import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/delivery_tracking_controller.dart';
import '../models/delivery_tracking_models.dart';
import 'delivery_dialogs.dart';

import '../../../app/widgets/app_shimmer.dart';

class DeliveryCardList extends GetView<DeliveryTrackingController> {
  const DeliveryCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const AppShimmerTable(rowCount: 4);
      }
      final items = controller.filteredDeliveries;
      if (items.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              controller.isProjectScoped
                  ? 'No deliveries found for project ${controller.scopedJobId.isNotEmpty ? controller.scopedJobId : controller.scopedProject}.'
                  : 'No deliveries found.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        );
      }
      return Column(
        children: items.map((item) => _DeliveryCard(item: item)).toList(),
      );
    });
  }
}

class _DeliveryCard extends GetView<DeliveryTrackingController> {
  const _DeliveryCard({required this.item});

  final DeliveryItem item;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(10.0, 12.0);
    final titleSize = (size.width * 0.012).clamp(14.0, 16.0);
    final btnSize = (size.width * 0.009).clamp(11.0, 13.0);

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.014),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.014,
              size.height * 0.012,
              size.width * 0.014,
              size.height * 0.008,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B6FD8),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: item.status),
                          if (item.priority != null) ...[
                            const SizedBox(width: 6),
                            _PriorityBadge(priority: item.priority!),
                          ],
                          if (item.bundleCount > 0) ...[
                            const SizedBox(width: 6),
                            _EtaBadge(
                              text: '${item.bundleCount} Bundles',
                              color: const Color(0xFF7539FF),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '@ ${item.location}',
                        style: TextStyle(
                          fontSize: labelSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Delivery ID: ${item.id}',
                  style: TextStyle(
                    fontSize: labelSize,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => ViewDetailsDialog.show(context, item),
                  child: Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 14,
                        color: AppColors.link,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: labelSize,
                          color: AppColors.link,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          // Info columns
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.014,
              vertical: size.height * 0.012,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _InfoBlock(
                    title: 'Material Details',
                    rows: [
                      (Icons.scale_outlined, 'Quantity', item.quantity),
                      (
                        Icons.warehouse_outlined,
                        'Staging Area',
                        item.stagingArea,
                      ),
                    ],
                    iconBackgrounds: const {
                      0: Color(0xFFF3E8FF),
                      1: Color(0xFFEFF6FF),
                    },
                    iconColors: const {
                      0: Color(0xFF9333EA),
                      1: Color(0xFF2563EB),
                    },
                    labelSize: labelSize,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _InfoBlock(
                    title: 'Schedule',
                    rows: [
                      (
                        Icons.calendar_today_outlined,
                        'Arrival at Plant',
                        item.arrivalAtPlant,
                      ),
                      (
                        Icons.calendar_month_outlined,
                        'Departure from Plant',
                        item.departureFromPlant,
                      ),
                    ],
                    iconBackgrounds: const {
                      0: Color(0xFFECFDF3),
                      1: Color(0xFFFFF7ED),
                    },
                    iconColors: const {
                      0: Color(0xFF22C55E),
                      1: Color(0xFFF97316),
                    },
                    labelSize: labelSize,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: _CarrierRouteBlock(item: item, labelSize: labelSize),
                ),
                SizedBox(
                  width: size.width * 0.13,
                  child: _NotesBox(notes: item.notes, labelSize: labelSize),
                ),
              ],
            ),
          ),
          // Action buttons — row 1: three equal filled buttons (only shown when status != delivered, matching web panel)
          if (item.status != DeliveryStatus.delivered)
            Padding(
              padding: EdgeInsets.fromLTRB(
                size.width * 0.014,
                0,
                size.width * 0.014,
                size.height * 0.006,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      label: 'Mark as Received',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF10B981),
                      fontSize: btnSize,
                      onTap: () => MarkReceivedDialog.show(
                        context,
                        item,
                        () => controller.markReceived(item.id),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Scan QR Code',
                      icon: Icons.qr_code_scanner_rounded,
                      color: const Color(0xFFF97316),
                      fontSize: btnSize,
                      onTap: () => ScanQrDialog.show(context, item),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Partial Received',
                      icon: Icons.download_outlined,
                      color: const Color(0xFF1D51A4),
                      fontSize: btnSize,
                      onTap: () => MarkPartialDialog.show(
                        context,
                        item,
                        () => controller.markPartialReceived(item.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Action buttons — row 2: Update Site Contact (outlined, left-aligned)
          Padding(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.014,
              size.height * 0.004,
              size.width * 0.014,
              size.height * 0.012,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    label: 'Update Site Contact',
                    icon: Icons.person_outline,
                    color: const Color(0xFF475569),
                    fontSize: btnSize,
                    outlined: true,
                    onTap: () => UpdateSiteContactDialog.show(context, item),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(child: SizedBox.shrink()),
                const SizedBox(width: 10),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final DeliveryStatus status;
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      DeliveryStatus.inTransit => (
        'In Transit to Plant',
        const Color(0xFF2563EB),
      ),
      DeliveryStatus.staged => ('Staged at Plant', const Color(0xFF22C55E)),
      DeliveryStatus.ready => ('Ready', const Color(0xFFF97316)),
      DeliveryStatus.delivered => ('Delivered', const Color(0xFF6B7280)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final DeliveryPriority priority;
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      DeliveryPriority.high => ('High Priority', const Color(0xFFEF4444)),
      DeliveryPriority.medium => ('Medium Priority', const Color(0xFFF59E0B)),
      DeliveryPriority.low => ('Low Priority', const Color(0xFF22C55E)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _EtaBadge extends StatelessWidget {
  const _EtaBadge({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.title,
    required this.rows,
    required this.labelSize,
    this.iconBackgrounds = const {},
    this.iconColors = const {},
  });

  final String title;
  final List<(IconData, String, String)> rows;
  final double labelSize;
  final Map<int, Color> iconBackgrounds;
  final Map<int, Color> iconColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...rows.asMap().entries.map((entry) {
          final idx = entry.key;
          final r = entry.value;
          final bgColor = iconBackgrounds[idx] ?? AppColors.inputFill;
          final iconColor = iconColors[idx] ?? AppColors.textSecondary;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(r.$1, size: 12, color: iconColor),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.$2,
                        style: TextStyle(
                          fontSize: labelSize - 1,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        r.$3,
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _NotesBox extends StatelessWidget {
  const _NotesBox({required this.notes, required this.labelSize});
  final String notes;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEFCE8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Text(
            notes,
            style: TextStyle(
              fontSize: labelSize - 1,
              color: const Color(0xFF92400E),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CarrierRouteBlock extends StatelessWidget {
  const _CarrierRouteBlock({required this.item, required this.labelSize});
  final DeliveryItem item;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carrier & Route',
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Carrier',
                    value: item.carrier,
                    bgColor: const Color(0xFFECFDF3),
                    iconColor: const Color(0xFF22C55E),
                    labelSize: labelSize,
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Final Destination',
                    value: item.finalDestination,
                    bgColor: const Color(0xFFFFF1F2),
                    iconColor: const Color(0xFFEF4444),
                    labelSize: labelSize,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.local_taxi_outlined,
                    label: 'Truck',
                    value: item.truck,
                    bgColor: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                    labelSize: labelSize,
                  ),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Driver',
                    value: item.driver,
                    bgColor: const Color(0xFFF8FAFC),
                    iconColor: const Color(0xFF64748B),
                    labelSize: labelSize,
                  ),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: item.phone,
                    bgColor: const Color(0xFFF8FAFC),
                    iconColor: const Color(0xFF64748B),
                    labelSize: labelSize,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.bgColor,
    required this.iconColor,
    required this.labelSize,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color bgColor;
  final Color iconColor;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 12, color: iconColor),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelSize - 1,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.fontSize,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double fontSize;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14, color: color),
        label: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          minimumSize: const Size(double.infinity, 42),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 42),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
