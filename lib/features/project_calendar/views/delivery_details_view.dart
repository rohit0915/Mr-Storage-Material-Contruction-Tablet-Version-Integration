import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';

class DeliveryDetailsView extends StatelessWidget {
  const DeliveryDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?) ?? {};
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = size.height * 0.014;

    final id = (args['id'] as String?) ?? 'DEL-2001';
    final title = (args['title'] as String?) ?? 'Primary Frame Steel';
    final location =
        (args['location'] as String?) ?? 'ABC Logistics Warehouse';
    final quantity = (args['quantity'] as String?) ?? '45,000 lbs';
    final staging = (args['stagingArea'] as String?) ?? 'Yard-A';
    final arrival =
        (args['arrival'] as String?) ?? 'Tuesday, March 24, 2020 at 10:00 AM';
    final departure =
        (args['departure'] as String?) ?? 'Tuesday, March 24, 2020 at 03:00 PM';
    final fromProject = args['fromProject'] == true;

    return AppScaffold(
      menuTitle: 'Project & Calendar',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.accentBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    fromProject
                        ? Icons.apartment_rounded
                        : Icons.local_shipping_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                SizedBox(width: size.width * 0.01),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fromProject ? 'Project Details' : 'Delivery Details',
                        style: TextStyle(
                          fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentBlue,
                        ),
                      ),
                      Text(
                        id,
                        style: TextStyle(
                          fontSize: (size.width * 0.011).clamp(12.0, 14.0),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'High Priority',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            if (!fromProject) ...[
              _StatusBanner(staging: staging),
              SizedBox(height: gap),
              const _DeliveryFlow(),
              SizedBox(height: gap),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  AppAssets.project1,
                  height: size.height * 0.22,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: gap),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final colW = (constraints.maxWidth - 32) / 3;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: colW,
                      child: _InfoColumn(
                        title: fromProject
                            ? 'Project Information'
                            : 'Material Information',
                        rows: [
                          _InfoLine(
                            icon: Icons.inventory_2_outlined,
                            color: AppColors.chartPurple,
                            label: fromProject ? 'Project' : 'Material',
                            value: title,
                          ),
                          _InfoLine(
                            icon: Icons.apartment_outlined,
                            color: AppColors.accentBlue,
                            label: fromProject ? 'Location' : 'Project',
                            value: location,
                          ),
                          if (!fromProject)
                            _InfoLine(
                              icon: Icons.scale_outlined,
                              color: AppColors.orange,
                              label: 'Quantity',
                              value: quantity,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: size.width * 0.012),
                    SizedBox(
                      width: colW,
                      child: _InfoColumn(
                        title: fromProject ? 'Schedule' : 'Plant Schedule',
                        rows: [
                          _InfoLine(
                            icon: Icons.calendar_today_outlined,
                            color: AppColors.success,
                            label: 'Arrival at Plant',
                            value: arrival,
                          ),
                          _InfoLine(
                            icon: Icons.calendar_today_outlined,
                            color: AppColors.orange,
                            label: 'Departure from Plant',
                            value: departure,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: size.width * 0.012),
                    SizedBox(
                      width: colW,
                      child: _InfoColumn(
                        title:
                            fromProject ? 'Site & Status' : 'Carrier & Route',
                        rows: [
                          _InfoLine(
                            icon: Icons.local_shipping_outlined,
                            color: AppColors.accentBlue,
                            label: fromProject ? 'Contractor' : 'Carrier',
                            value: 'FactFreight Logistics',
                          ),
                          _InfoLine(
                            icon: Icons.place_outlined,
                            color: AppColors.danger,
                            label: 'Final Destination',
                            value: 'Construction Site A',
                          ),
                          if (!fromProject) ...[
                            const _InfoLine(
                              icon: Icons.directions_car_outlined,
                              color: AppColors.accentBlue,
                              label: 'Truck',
                              value: 'TX-4582',
                            ),
                            const _InfoLine(
                              icon: Icons.person_outline,
                              color: AppColors.accentBlue,
                              label: 'Driver',
                              value: 'John Miller · +1 555-012-9921',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: gap),
            if (!fromProject) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8EF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weight Units + Material Type',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: (size.width * 0.011).clamp(12.0, 14.0),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Quantity: $quantity'),
                          const Text('Material Type: Structural Steel'),
                          const Text('Packaging: Bundled Frame Components'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.012),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Documents',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: (size.width * 0.011).clamp(12.0, 14.0),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _DocumentChip(label: 'Packing list'),
                            ),
                            SizedBox(width: size.width * 0.008),
                            Expanded(
                              child: _DocumentChip(label: 'Bill of loading'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Requires forklift for unloading',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: gap),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: Get.back,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.cardBorder),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentChip extends StatelessWidget {
  const _DocumentChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.download_outlined,
            size: 18,
            color: AppColors.accentBlue,
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.staging});

  final String staging;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentBlue, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Current Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.accentBlue,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'ETA 10:45 AM',
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'In Transit to Plant',
                      style: TextStyle(
                        fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Staging Area',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    staging,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: size.height * 0.014),
          const _ProgressChecklist(),
        ],
      ),
    );
  }
}

class _ProgressChecklist extends StatelessWidget {
  const _ProgressChecklist();

  @override
  Widget build(BuildContext context) {
    const done = ['Scheduled', 'Material Prepared', 'Loaded', 'Picked Up'];
    const active = 'In Transit';
    const pending = [
      'Arrived at Plant',
      'Staged',
      'Dispatched to Site',
      'Delivered',
    ];

    return Wrap(
      spacing: 14,
      runSpacing: 10,
      children: [
        ...done.map((e) => _StepChip(label: e, state: _StepState.done)),
        const _StepChip(label: active, state: _StepState.active),
        ...pending.map((e) => _StepChip(label: e, state: _StepState.pending)),
      ],
    );
  }
}

enum _StepState { done, active, pending }

class _StepChip extends StatelessWidget {
  const _StepChip({required this.label, required this.state});

  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    late final Widget leading;
    switch (state) {
      case _StepState.done:
        leading = const Icon(
          Icons.check_circle,
          size: 16,
          color: AppColors.accentBlue,
        );
      case _StepState.active:
        leading = Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.chartYellow,
            shape: BoxShape.circle,
          ),
        );
      case _StepState.pending:
        leading = Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accentBlue),
            shape: BoxShape.circle,
          ),
        );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight:
                state == _StepState.active ? FontWeight.w800 : FontWeight.w600,
            color: state == _StepState.pending
                ? AppColors.textSecondary
                : AppColors.textPrimary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DeliveryFlow extends StatelessWidget {
  const _DeliveryFlow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Flow',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _FlowNode(
                icon: Icons.local_shipping,
                color: AppColors.accentBlue,
                label: 'Origin',
                value: 'FactFreight Logistics',
              ),
            ),
            Icon(Icons.arrow_forward, color: AppColors.textSecondary),
            Expanded(
              child: _FlowNode(
                icon: Icons.warehouse_outlined,
                color: AppColors.success,
                label: 'Plant Staging',
                value: 'Yard-A',
              ),
            ),
            Icon(Icons.arrow_forward, color: AppColors.textSecondary),
            Expanded(
              child: _FlowNode(
                icon: Icons.place,
                color: AppColors.orange,
                label: 'Destination',
                value: 'Construction Site A',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FlowNode extends StatelessWidget {
  const _FlowNode({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.title, required this.rows});

  final String title;
  final List<_InfoLine> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...rows.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: r,
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
