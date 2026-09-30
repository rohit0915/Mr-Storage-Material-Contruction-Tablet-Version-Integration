import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../controllers/project_details_controller.dart';
import '../models/project_calendar_models.dart';

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
            // Top Navigation & Action Buttons Row
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
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.01),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project & Calendar',
                        style: TextStyle(
                          fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Construction Department Performance',
                        style: TextStyle(
                          fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ActionButton(
                      icon: Icons.print_outlined,
                      label: 'View BOM File',
                      onTap: () {
                        if (controller.bomFiles.isEmpty) {
                          Get.snackbar(
                            'BOM unavailable',
                            'This project has no BOM file URL in the API response.',
                          );
                          return;
                        }
                        Get.toNamed(
                          AppRoutes.bomFileDetails,
                          arguments: {
                            'leadId': controller.leadId.value,
                            'projectName': controller.title.value,
                            'jobId': controller.projectId.value,
                            'customerName': controller.customerName.value,
                            'buildingType': controller.buildingType.value,
                            'location': controller.location.value,
                            'status': controller.lifecycleStatus.value,
                            'files': controller.bomFiles.toList(),
                          },
                        );
                      },
                    ),
                    _ActionButton(
                      icon: Icons.indeterminate_check_box_outlined,
                      label: 'View Drawings & Photos',
                      onTap: () => Get.toNamed(
                        AppRoutes.drawings,
                        arguments: {'leadId': controller.leadId.value},
                      ),
                    ),
                    _ActionButton(
                      icon: Icons.assignment_turned_in_outlined,
                      label: 'Material Delivery',
                      onTap: () => Get.toNamed(
                        AppRoutes.deliveryTracking,
                        arguments: {
                          'leadId': controller.leadId.value,
                          'project': controller.title.value,
                          'jobId': controller.projectId.value,
                          'fromProject': true,
                        },
                      ),
                    ),
                    _ActionButton(
                      icon: Icons.inventory_2_outlined,
                      label: 'Bundle Scan',
                      onTap: () => Get.toNamed(
                        AppRoutes.bundleScan,
                        arguments: {
                          'leadId': controller.leadId.value,
                          'project': controller.title.value,
                          'jobId': controller.projectId.value,
                          'fromProject': true,
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: gap),

            // Project Overview Header Card
            Obx(
              () => Container(
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
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: AppColors.primaryBlue,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: size.width * 0.01),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.title.value.isEmpty
                                    ? '—'
                                    : controller.title.value,
                                style: TextStyle(
                                  fontSize: (size.width * 0.016).clamp(
                                    18.0,
                                    22.0,
                                  ),
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                controller.location.value.isEmpty
                                    ? '—'
                                    : controller.location.value,
                                style: TextStyle(
                                  fontSize: (size.width * 0.011).clamp(
                                    12.0,
                                    14.0,
                                  ),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (controller.projectId.value.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              controller.projectId.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.014),
                    Row(
                      children: [
                        _MetaItem(
                          icon: Icons.location_on_outlined,
                          text: controller.location.value.isEmpty
                              ? '—'
                              : controller.location.value,
                        ),
                        if (controller.customerName.value.isNotEmpty) ...[
                          SizedBox(width: size.width * 0.02),
                          _MetaItem(
                            icon: Icons.person_outline,
                            text: 'Customer: ${controller.customerName.value}',
                          ),
                        ],
                        const Spacer(),
                        if (controller.lifecycleStatus.value.isNotEmpty)
                          _BadgePill(
                            text: controller.lifecycleStatus.value,
                            color: AppColors.primaryBlue,
                            bgColor: AppColors.softBlueBg,
                          ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.008),
                    _MetaItem(
                      icon: Icons.domain_outlined,
                      text:
                          'Type: ${controller.buildingType.value.isNotEmpty ? controller.buildingType.value : '—'}',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: gap),

            // Two Column Content: Deliveries (Left) & Media Grid (Right)
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 900;
                if (isNarrow) {
                  return Column(
                    children: [
                      _UpcomingDeliveriesSection(controller: controller),
                      SizedBox(height: gap),
                      _PhotosVideosSection(controller: controller),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _UpcomingDeliveriesSection(controller: controller),
                    ),
                    SizedBox(width: size.width * 0.014),
                    Expanded(
                      flex: 4,
                      child: _PhotosVideosSection(controller: controller),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.text,
    required this.color,
    required this.bgColor,
  });

  final String text;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingDeliveriesSection extends StatelessWidget {
  const _UpcomingDeliveriesSection({required this.controller});

  final ProjectDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Obx(() {
      final list = controller.deliveries;
      if (controller.isLoading.value) {
        return const AppShimmerTable(rowCount: 4);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Material Delivery (${list.length})',
            style: TextStyle(
              fontSize: (size.width * 0.014).clamp(15.0, 18.0),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          if (list.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Text(
                'No deliveries found for this project.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            )
          else
            ...list.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DeliveryDetailCard(
                  item: d,
                  projectTitle: controller.title.value,
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _DeliveryDetailCard extends StatelessWidget {
  const _DeliveryDetailCard({required this.item, required this.projectTitle});

  final DeliveryItem item;
  final String projectTitle;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.code,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          color: item.statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.description.isNotEmpty ? item.description : projectTitle,
                  style: TextStyle(
                    fontSize: (size.width * 0.013).clamp(14.0, 16.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  item.location.isNotEmpty ? item.location : item.projectName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Material Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _DetailRow(
                            icon: Icons.inventory_2_outlined,
                            iconBg: AppColors.softBlueBg,
                            iconColor: AppColors.primaryBlue,
                            label: 'Delivery Date',
                            value: item.date.isNotEmpty
                                ? item.date.split('T')[0]
                                : 'N/A',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            iconBg: AppColors.softBlueBg,
                            iconColor: AppColors.primaryBlue,
                            label: 'Delivery Status',
                            value: item.status,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Center(
              child: SizedBox(
                width: 160,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(
                    AppRoutes.deliveryDetails,
                    arguments: {
                      'id': item.id,
                      'title': item.projectName,
                      'location': item.location,
                    },
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhotosVideosSection extends StatelessWidget {
  const _PhotosVideosSection({required this.controller});

  final ProjectDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Photos & Videos (Latest)',
              style: TextStyle(
                fontSize: (size.width * 0.013).clamp(14.0, 16.0),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            if (controller.isLoading.value)
              const AppShimmerTable(rowCount: 3)
            else if (controller.media.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No photos or videos returned by the API.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.media.length > 6
                    ? 6
                    : controller.media.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.4,
                ),
                itemBuilder: (context, index) {
                  final item = controller.media[index];
                  final url = item['url'] ?? '';
                  final isVideo =
                      (item['type'] ?? '').toLowerCase().contains('video') ||
                      RegExp(
                        r'\.(mp4|mov)(\?|$)',
                        caseSensitive: false,
                      ).hasMatch(url);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isVideo
                        ? Container(
                            color: AppColors.softBlueBg,
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                size: 42,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          )
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                          ),
                  );
                },
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed(
                  AppRoutes.drawings,
                  arguments: {'leadId': controller.leadId.value},
                ),
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('View All Media'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
