import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';

class BomFileDetailsView extends StatelessWidget {
  const BomFileDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = size.height * 0.014;

    return AppScaffold(
      menuTitle: 'BOM File Details',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Navigation & Action Button
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
                  'BOM File Details',
                  style: TextStyle(
                    fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Download BOM'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),

            // Top Overview Cards Row
            Row(
              children: [
                // Project Overview Card
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROJECT OVERVIEW',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ABC Construction',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '# BOM-001',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Text(
                              '01.09.26',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.014),

                // BOM Summary Card
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BOM SUMMARY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatBox(
                                label: 'Total Items',
                                value: '125',
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _StatBox(
                                label: 'Total Weight',
                                value: '32,000',
                                unit: 'lbs',
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _StatBox(
                                label: 'Total Panels Area',
                                value: '3,300',
                                unit: 'sqm',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),

            // Main Storage Materials Table Card
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
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: AppColors.primaryBlue, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'STORAGE MATERIALS',
                        style: TextStyle(
                          fontSize: (size.width * 0.014).clamp(15.0, 18.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'BLDG-D',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Studs & Top Channels',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Customer:   John Doe',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Table
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          color: AppColors.tableHeader,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          child: const Row(
                            children: [
                              Expanded(flex: 2, child: _TableHeaderCell(text: 'QTY ⇅')),
                              Expanded(flex: 3, child: _TableHeaderCell(text: 'Mark ⇅')),
                              Expanded(flex: 5, child: _TableHeaderCell(text: 'Description')),
                              Expanded(flex: 4, child: _TableHeaderCell(text: 'Part')),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.cardBorder),

                        // Table Rows
                        const _TableRowItem(qty: '5', mark: 'S-1', desc: 'STUD', part: 'C42516'),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        const _TableRowItem(qty: '8', mark: 'S-2', desc: 'STUD', part: 'C42516'),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        const _TableRowItem(qty: '6', mark: 'S-3', desc: 'STUD', part: 'C42516'),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        const _TableRowItem(qty: '5', mark: 'S-4', desc: 'STUD', part: 'C42516'),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        const _TableRowItem(qty: '8', mark: 'S-5', desc: 'STUD', part: 'C42516'),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        const _TableRowItem(qty: '6', mark: 'S-6', desc: 'STUD', part: 'C42516'),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        const _TableRowItem(qty: '3', mark: 'S-7', desc: 'STUD', part: 'C42516'),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        const _TableRowItem(qty: '4', mark: 'S-8', desc: 'STUD', part: 'C42516'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Table Summary Footer
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('QTY Total', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('199', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(width: 32),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Tons', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('1.71', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Text('Received By: ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          Container(
                            width: 200,
                            height: 1,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ],
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

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softBlueBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  const _TableHeaderCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _TableRowItem extends StatelessWidget {
  const _TableRowItem({
    required this.qty,
    required this.mark,
    required this.desc,
    required this.part,
  });

  final String qty;
  final String mark;
  final String desc;
  final String part;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              qty,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              mark,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              desc,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              part,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
