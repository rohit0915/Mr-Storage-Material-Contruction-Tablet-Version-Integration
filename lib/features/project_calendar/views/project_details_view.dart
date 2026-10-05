import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/project_details_controller.dart';

class ProjectDetailsView extends StatelessWidget {
  const ProjectDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = size.height * 0.014;

    final controller = Get.put(ProjectDetailsController());

    return AppScaffold(
      menuTitle: 'Project & Calendar',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Navigation Row
            Row(
              children: [
                InkWell(
                  onTap: Get.back,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Back',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.01),
                Expanded(
                  child: Obx(() => Text(
                        'Project Details- ${controller.title.value}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      )),
                ),
              ],
            ),
            SizedBox(height: gap * 1.5),

            // Action Buttons Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 1050;
                final buttons = [
                  _ActionButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'View BOM',
                    onTap: () {
                      Get.toNamed(AppRoutes.bomFileDetails, arguments: {
                        'leadId': controller.leadId.value,
                        'projectName': controller.title.value,
                        'jobId': controller.projectId.value,
                        'customerName': controller.customerName.value,
                        'buildingType': controller.buildingType.value,
                        'location': controller.location.value,
                        'status': controller.lifecycleStatus.value,
                        'files': controller.bomFiles.toList(),
                      });
                    },
                  ),
                  _ActionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'View Drawings & Photos',
                    onTap: () => Get.toNamed(AppRoutes.drawings, arguments: {'leadId': controller.leadId.value}),
                  ),
                  _ActionButton(
                    icon: Icons.local_shipping_outlined,
                    label: 'Material Delivery',
                    onTap: () => Get.toNamed(AppRoutes.deliveryTracking, arguments: {
                      'leadId': controller.leadId.value,
                      'project': controller.title.value,
                      'jobId': controller.projectId.value,
                      'fromProject': true,
                    }),
                  ),
                  _ActionButton(
                    icon: Icons.edit_note_outlined,
                    label: 'Daily Work Logs',
                    onTap: () {},
                  ),
                  _ActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Bundle Scan',
                    onTap: () => Get.toNamed(AppRoutes.bundleScan, arguments: {
                      'leadId': controller.leadId.value,
                      'project': controller.title.value,
                      'jobId': controller.projectId.value,
                      'fromProject': true,
                    }),
                  ),
                ];

                if (!isCompact) {
                  return Row(
                    children: [
                      for (int i = 0; i < buttons.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(child: buttons[i]),
                      ],
                    ],
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      for (int i = 0; i < buttons.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        buttons[i],
                      ],
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: gap * 1.5),

            // Project Overview Header Card
            Obx(() => Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.account_balance, color: AppColors.primaryBlue, size: 28),
                          ),
                          SizedBox(width: size.width * 0.015),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      controller.title.value.isEmpty ? '—' : controller.title.value,
                                      style: TextStyle(
                                        fontSize: (size.width * 0.015).clamp(18.0, 20.0),
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const _BadgePill(text: 'Material Check', color: Color(0xFFD97706), bgColor: Color(0xFFFEF3C7)),
                                    const _BadgePill(text: 'Medium Priority', color: Color(0xFF4B5563), bgColor: Color(0xFFF3F4F6)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  controller.projectId.value.isEmpty ? '—' : controller.projectId.value,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(color: Color(0xFFE0E7FF), shape: BoxShape.circle),
                                  child: const Icon(Icons.person_outline, size: 16, color: AppColors.primaryBlue),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.customerName.value.isEmpty ? '—' : controller.customerName.value,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                    ),
                                    Text(
                                      controller.customerEmail.value.isEmpty ? '—' : controller.customerEmail.value,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 14,
                        spacing: 16,
                        children: [
                          _BottomMeta(icon: Icons.domain, label: 'Building Type', value: controller.buildingType.value.isEmpty ? '—' : controller.buildingType.value),
                          _BottomMeta(icon: Icons.business, label: 'No. of Building', value: '2'),
                          const _BottomMeta(icon: Icons.calendar_today_outlined, label: 'Created On', value: '-'),
                          _BottomMeta(icon: Icons.location_on_outlined, label: 'Location', value: controller.location.value.isEmpty ? '—' : controller.location.value),
                        ],
                      ),
                    ],
                  ),
                )),
            SizedBox(height: gap * 1.5),

            // Upcoming Material Delivery Data Table
            const Text(
              'Upcoming Material Delivery',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final minWidth = constraints.maxWidth < 900 ? 900.0 : constraints.maxWidth;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: minWidth,
                      child: Obx(
                        () => Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E5E9E), // dark blue header
                                borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                              ),
                              child: Row(
                                children: [
                                  _tblHeader('ID', flex: 2, sort: true),
                                  _tblHeader('Status', flex: 2, sort: true),
                                  _tblHeader('Date & Time', flex: 2, sort: true),
                                  _tblHeader('Item', flex: 3, sort: true),
                                  _tblHeader('Vendor', flex: 1),
                                  _tblHeader('Carrier', flex: 1),
                                  _tblHeader('POC', flex: 1),
                                ],
                              ),
                            ),
                            if (controller.isLoading.value)
                              const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
                            else if (controller.deliveries.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text('No material deliveries found for this project.', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              )
                            else
                              ...controller.deliveries.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text(item.code, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryBlue))),
                                    Expanded(flex: 2, child: Text(item.status, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: item.statusColor))),
                                    Expanded(flex: 2, child: Text(item.date, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                                    Expanded(flex: 3, child: Text(item.description.isNotEmpty ? item.description : 'Material', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                                    const Expanded(flex: 1, child: Text('-', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                                    const Expanded(flex: 1, child: Text('-', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                                    const Expanded(flex: 1, child: Text('-', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                                  ],
                                ),
                              )),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: gap * 1.5),

            // Project Tasks
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Tasks (${controller.tasks.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: controller.isLoading.value
                      ? const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
                      : controller.tasks.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child: Text('No tasks found.', style: TextStyle(color: AppColors.textSecondary)),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: controller.tasks.map((task) {
                                final isLast = controller.tasks.last == task;
                                final name = task['name']?.toString() ?? task['title']?.toString() ?? 'Task';
                                final dueDate = task['dueDate']?.toString() ?? task['endDate']?.toString() ?? '-';
                                final prio = task['priority']?.toString().toLowerCase() ?? 'low';
                                final stat = task['status']?.toString().toLowerCase() ?? 'todo';
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.cardBorder)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                                              const SizedBox(width: 6),
                                              Text('Due: $dueDate', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          _TaskBadge(type: prio, isPriority: true),
                                          const SizedBox(width: 8),
                                          _TaskBadge(type: stat, isPriority: false),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _tblHeader(String label, {required int flex, bool sort = false}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          if (sort) ...[
            const SizedBox(width: 4),
            const Icon(Icons.unfold_more, color: Colors.white70, size: 14),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E5E9E), // dark blue to match screenshot
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomMeta extends StatelessWidget {
  const _BottomMeta({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.text, required this.color, required this.bgColor});

  final String text;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
        ],
      ),
    );
  }
}

class _TaskBadge extends StatelessWidget {
  const _TaskBadge({required this.type, required this.isPriority});

  final String type;
  final bool isPriority;

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFF3F4F6);
    Color fg = const Color(0xFF4B5563);
    String label = type.toUpperCase();
    IconData? icon;

    if (isPriority) {
      if (type.contains('high')) {
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        icon = Icons.error_outline;
      } else if (type.contains('low')) {
        bg = AppColors.softBlueBg;
        fg = AppColors.primaryBlue;
      }
    } else {
      if (type.contains('progress')) {
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        icon = Icons.access_time;
      } else if (type.contains('todo')) {
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF4B5563);
        icon = Icons.access_time;
      }
    }

    if (label.contains('PROGRESS')) label = 'In Progress';
    if (label.contains('TODO')) label = 'Todo';
    if (label.contains('HIGH')) label = 'High';
    if (label.contains('LOW')) label = 'Low';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: fg), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
