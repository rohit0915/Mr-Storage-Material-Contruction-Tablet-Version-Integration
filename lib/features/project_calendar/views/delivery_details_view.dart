import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';

class DeliveryDetailsView extends StatelessWidget {
  const DeliveryDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = size.height * 0.014;

    final args = (Get.arguments as Map?) ?? {};
    final id = (args['id'] as String?) ?? 'DEL-2001';
    final title = (args['title'] as String?) ?? 'Downtown Office Complex';
    final location = (args['location'] as String?) ?? 'Construction Site A';

    return AppScaffold(
      menuTitle: 'Delivery Details',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sub Header Navigation & Action Buttons Row
            Row(
              children: [
                InkWell(
                  onTap: Get.back,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: size.width * 0.01),
                Text(
                  'Delivery Details',
                  style: TextStyle(
                    fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TopActionButton(label: 'Mark as Received', onTap: () {}),
                    _TopActionButton(
                      label: 'Scan QR Code',
                      onTap: () => Get.toNamed(AppRoutes.bundleScanDetail),
                    ),
                    _TopActionButton(label: 'Mark as Partial Received', onTap: () {}),
                    _TopActionButton(label: 'Update Site Contact', onTap: () {}),
                  ],
                ),
              ],
            ),
            SizedBox(height: gap),

            // Top Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _MetaSummaryBox(label: 'DELIVERY ID', value: id),
                  SizedBox(width: size.width * 0.015),
                  const _MetaSummaryPillBox(
                    label: 'CURRENT STATUS',
                    pillText: 'In Transit to Plant',
                    pillColor: AppColors.badgeGreen,
                    bgColor: AppColors.softGreenBg,
                  ),
                  SizedBox(width: size.width * 0.015),
                  const _MetaSummaryPillBox(
                    label: 'PRIORITY',
                    pillText: 'High',
                    pillColor: AppColors.badgeRed,
                    bgColor: AppColors.softPinkBg,
                  ),
                  SizedBox(width: size.width * 0.015),
                  const _MetaSummaryBox(label: 'ETA', value: '10:45 AM'),
                  SizedBox(width: size.width * 0.015),
                  const _MetaSummaryBox(label: 'STAGING AREA', value: 'Yard-A'),
                ],
              ),
            ),
            SizedBox(height: gap),

            // 3-Column Grid Row 1 (Material Info, Plant Schedule, Live Map Preview)
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 900;
                if (isNarrow) {
                  return Column(
                    children: [
                      const _MaterialInfoCard(),
                      SizedBox(height: gap),
                      const _PlantScheduleCard(),
                      SizedBox(height: gap),
                      const _LiveMapPreviewCard(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _MaterialInfoCard()),
                    SizedBox(width: size.width * 0.014),
                    const Expanded(child: _PlantScheduleCard()),
                    SizedBox(width: size.width * 0.014),
                    const Expanded(child: _LiveMapPreviewCard()),
                  ],
                );
              },
            ),
            SizedBox(height: gap),

            // 3-Column Grid Row 2 (Carrier & Route, Weight & Specs, Documents & Special Instruction)
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 900;
                if (isNarrow) {
                  return Column(
                    children: [
                      const _CarrierRouteCard(),
                      SizedBox(height: gap),
                      const _WeightTypeCard(),
                      SizedBox(height: gap),
                      const _DocumentsInstructionCard(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _CarrierRouteCard()),
                    SizedBox(width: size.width * 0.014),
                    const Expanded(child: _WeightTypeCard()),
                    SizedBox(width: size.width * 0.014),
                    const Expanded(child: _DocumentsInstructionCard()),
                  ],
                );
              },
            ),
            SizedBox(height: gap),

            // Delivery Timeline & Flow Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Timeline & Flow',
                    style: TextStyle(
                      fontSize: (size.width * 0.014).clamp(15.0, 18.0),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vertical Steps List
                  const _TimelineStepItem(
                    title: 'Scheduled',
                    date: '14/01/2024',
                    isDone: true,
                    statusText: 'COMPLETED',
                  ),
                  const _TimelineStepItem(
                    title: 'Material Prepared',
                    date: '14/01/2024',
                    isDone: true,
                    statusText: 'COMPLETED',
                  ),
                  const _TimelineStepItem(
                    title: 'Loaded',
                    date: '14/01/2024',
                    isDone: true,
                    statusText: 'COMPLETED',
                  ),
                  const _TimelineStepItem(
                    title: 'Picked Up',
                    date: '14/01/2024',
                    isDone: true,
                    statusText: 'COMPLETED',
                  ),
                  const _TimelineStepItem(
                    title: 'In Transit',
                    date: '14/01/2024',
                    isInProgress: true,
                    statusText: 'IN PROGRESS',
                  ),
                  const _TimelineStepItem(
                    title: 'Arrived at Plant',
                    date: '14/01/2024',
                    isUpcoming: true,
                    statusText: 'UPCOMING',
                  ),
                  const _TimelineStepItem(
                    title: 'Staged',
                    date: '14/01/2024',
                    isUpcoming: true,
                    statusText: 'UPCOMING',
                  ),
                  const _TimelineStepItem(
                    title: 'Dispatched to site',
                    date: '14/01/2024',
                    isUpcoming: true,
                    statusText: 'UPCOMING',
                  ),
                  const _TimelineStepItem(
                    title: 'Delivered',
                    date: '14/01/2024',
                    isUpcoming: true,
                    statusText: 'UPCOMING',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _MetaSummaryBox extends StatelessWidget {
  const _MetaSummaryBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.tableHeader,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _MetaSummaryPillBox extends StatelessWidget {
  const _MetaSummaryPillBox({
    required this.label,
    required this.pillText,
    required this.pillColor,
    required this.bgColor,
  });

  final String label;
  final String pillText;
  final Color pillColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.tableHeader,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 5, height: 5, decoration: BoxDecoration(color: pillColor, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(
                  pillText,
                  style: TextStyle(color: pillColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialInfoCard extends StatelessWidget {
  const _MaterialInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Material Information',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          SizedBox(height: 16),
          _InfoRow(icon: Icons.inventory_2_outlined, label: 'Material', value: 'Primary Frame Steel'),
          SizedBox(height: 12),
          _InfoRow(icon: Icons.domain_outlined, label: 'Project', value: 'ABC Logistics Warehouse'),
          SizedBox(height: 12),
          _InfoRow(icon: Icons.scale_outlined, label: 'Quantity', value: '45,000 lbs'),
        ],
      ),
    );
  }
}

class _PlantScheduleCard extends StatelessWidget {
  const _PlantScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Plant Schedule',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          SizedBox(height: 16),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Arrival at Plant',
            value: 'Tuesday, March 24, 2026\nat 10:00 AM',
          ),
          SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            label: 'Departure from Plant',
            value: 'Tuesday, March 24, 2026\nat 02:00 PM',
          ),
        ],
      ),
    );
  }
}

class _LiveMapPreviewCard extends StatelessWidget {
  const _LiveMapPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: const Color(0xFFE5E7EB),
                child: const Center(
                  child: Icon(Icons.map_outlined, size: 48, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.map, size: 14),
              label: const Text('View Live Map', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarrierRouteCard extends StatelessWidget {
  const _CarrierRouteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Carrier & Route',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          const _InfoRow(icon: Icons.local_shipping_outlined, label: 'Carrier', value: 'FastFreight Logistics'),
          const SizedBox(height: 10),
          const _InfoRow(icon: Icons.location_on_outlined, label: 'Final Destination', value: 'Construction Site A'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tableHeader,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Column(
              children: [
                _SmallMetaRow(label: 'Truck:', value: 'TX-4582'),
                SizedBox(height: 4),
                _SmallMetaRow(label: 'Driver:', value: 'John Miller'),
                SizedBox(height: 4),
                _SmallMetaRow(label: 'Phone:', value: '+1555-812-9921'),
                SizedBox(height: 4),
                _SmallMetaRow(label: 'Destination:', value: 'Construction Site A'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightTypeCard extends StatelessWidget {
  const _WeightTypeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weight Units + Material Type',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softGreenBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.badgeGreen.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity: 45,000 lbs', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                SizedBox(height: 6),
                Text('Material Type: Structural Steel', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                SizedBox(height: 6),
                Text('Packaging: Bundled Frame Components', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsInstructionCard extends StatelessWidget {
  const _DocumentsInstructionCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Documents', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              const _DocItemTile(title: 'Packing List', size: '5.3MB'),
              const SizedBox(height: 8),
              const _DocItemTile(title: 'Bill of Lading', size: '5.3MB'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Requires forklift for unloading',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.softBlueBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallMetaRow extends StatelessWidget {
  const _SmallMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _DocItemTile extends StatelessWidget {
  const _DocItemTile({required this.title, required this.size});

  final String title;
  final String size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.softPinkBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: AppColors.badgeRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
                Text(size, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.download_outlined, color: AppColors.textSecondary, size: 16),
        ],
      ),
    );
  }
}

class _TimelineStepItem extends StatelessWidget {
  const _TimelineStepItem({
    required this.title,
    required this.date,
    this.isDone = false,
    this.isInProgress = false,
    this.isUpcoming = false,
    required this.statusText,
    this.isLast = false,
  });

  final String title;
  final String date;
  final bool isDone;
  final bool isInProgress;
  final bool isUpcoming;
  final String statusText;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    Color badgeColor = AppColors.badgeGreen;
    Color badgeBg = AppColors.softGreenBg;
    if (isInProgress) {
      badgeColor = AppColors.primaryBlue;
      badgeBg = AppColors.softBlueBg;
    } else if (isUpcoming) {
      badgeColor = AppColors.textSecondary;
      badgeBg = AppColors.tableHeader;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isInProgress ? AppColors.softBlueBg.withValues(alpha: 0.4) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isInProgress ? AppColors.primaryBlue : AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : (isInProgress ? Icons.radio_button_checked : Icons.radio_button_unchecked),
            color: isDone ? AppColors.badgeGreen : (isInProgress ? AppColors.primaryBlue : AppColors.textSecondary),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isUpcoming ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Text(date, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusText,
              style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
