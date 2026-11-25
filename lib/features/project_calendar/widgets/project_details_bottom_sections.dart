import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../../drawings/widgets/upload_media_dialog.dart';
import '../controllers/project_details_controller.dart';
import '../models/project_calendar_models.dart';

class ProjectDetailsBottomSections extends StatelessWidget {
  const ProjectDetailsBottomSections({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        if (isNarrow) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _UpcomingDeliverySection(),
              SizedBox(height: 20),
              _ProjectMediaLatestSection(),
            ],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _UpcomingDeliverySection(),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _ProjectMediaLatestSection(),
            ),
          ],
        );
      },
    );
  }
}

class _UpcomingDeliverySection extends StatelessWidget {
  const _UpcomingDeliverySection();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectDetailsController>();

    return Obx(() {
      final deliveries = controller.deliveries;
      final count = deliveries.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Material Delivery ($count)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          if (controller.isLoading.value && deliveries.isEmpty)
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer(width: 140, height: 16, borderRadius: 4),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: AppShimmer(height: 36, borderRadius: 6)),
                      SizedBox(width: 12),
                      Expanded(child: AppShimmer(height: 36, borderRadius: 6)),
                    ],
                  ),
                  Spacer(),
                  AppShimmer(width: double.infinity, height: 34, borderRadius: 8),
                ],
              ),
            )
          else if (deliveries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 36,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No upcoming material deliveries',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Deliveries scheduled for this project will appear here.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            for (final d in deliveries.take(3)) ...[
              _DeliveryCardView(
                code: d.code.isNotEmpty
                    ? d.code
                    : (d.id.isNotEmpty ? d.id : 'Delivery'),
                title: d.title.isNotEmpty
                    ? d.title
                    : (d.description.isNotEmpty
                        ? d.description
                        : 'Material Delivery'),
                warehouse: d.warehouse.isNotEmpty
                    ? d.warehouse
                    : (d.projectName.isNotEmpty
                        ? d.projectName
                        : (controller.title.value.isNotEmpty
                            ? controller.title.value
                            : '—')),
                quantity: d.quantity.isNotEmpty ? d.quantity : '—',
                stagingArea: d.stagingArea.isNotEmpty ? d.stagingArea : '—',
                arrivalDate: d.arrivalDate.isNotEmpty
                    ? d.arrivalDate
                    : (d.date.isNotEmpty ? d.date : '—'),
                departureDate:
                    d.departureDate.isNotEmpty ? d.departureDate : '—',
                onTap: () => _goToDeliveryItem(controller, d),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      );
    });
  }

  void _goToDeliveryItem(ProjectDetailsController controller, DeliveryItem item) {
    Get.toNamed(AppRoutes.deliveryDetails, arguments: {
      'leadId': controller.leadId.value,
      'id': item.id,
      'deliveryId': item.id,
      'deliveryNumber': item.code,
      'project': controller.title.value,
      'projectName': controller.title.value,
      'jobId': controller.projectId.value,
      'location': controller.location.value,
      'item': {
        'deliveryNumber': item.code,
        'deliveryId': item.id,
        'title': item.title,
        'description': item.description.isNotEmpty ? item.description : item.title,
        'status': item.status,
        'deliveryDate': item.date,
        'quantity': item.quantity,
        'loadWeight': item.quantity,
        'stagingArea': item.stagingArea,
        'warehouse': item.warehouse,
        'location': item.location,
        'destination': item.location,
        'project': {
          'projectName': item.projectName.isNotEmpty ? item.projectName : controller.title.value,
          'jobId': controller.projectId.value,
          'location': item.location.isNotEmpty ? item.location : controller.location.value,
        },
        'schedule': {
          'arrivalAtPlant': item.arrivalDate,
          'departureFromPlant': item.departureDate,
          'deliveryDate': item.date,
        },
      },
      'fromProject': true,
    });
  }
}

class _DeliveryCardView extends StatelessWidget {
  const _DeliveryCardView({
    required this.code,
    required this.title,
    required this.warehouse,
    required this.quantity,
    required this.stagingArea,
    required this.arrivalDate,
    required this.departureDate,
    required this.onTap,
  });

  final String code;
  final String title;
  final String warehouse;
  final String quantity;
  final String stagingArea;
  final String arrivalDate;
  final String departureDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Text(
            code,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            warehouse,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Details Row (Material Details & Schedule)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Material Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Material Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _iconDetailRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Quantity',
                      value: quantity,
                    ),
                    const SizedBox(height: 6),
                    _iconDetailRow(
                      icon: Icons.warehouse_outlined,
                      label: 'Staging Area',
                      value: stagingArea,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Schedule
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _iconDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Arrival at Plant',
                      value: arrivalDate,
                    ),
                    const SizedBox(height: 6),
                    _iconDetailRow(
                      icon: Icons.access_time_outlined,
                      label: 'Departure from Plant',
                      value: departureDate,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // View Details Button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: const Color(0xFF2563EB)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectMediaLatestSection extends StatelessWidget {
  const _ProjectMediaLatestSection();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectDetailsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Photos & Videos (Latest)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Obx(() {
                final mediaItems = controller.media;
                if (controller.isLoading.value && mediaItems.isEmpty) {
                  return const SizedBox(
                    height: 140,
                    child: Row(
                      children: [
                        Expanded(child: AppShimmer(height: double.infinity, borderRadius: 10)),
                        SizedBox(width: 12),
                        Expanded(child: AppShimmer(height: double.infinity, borderRadius: 10)),
                      ],
                    ),
                  );
                }
                if (mediaItems.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          size: 40,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No photos or videos uploaded yet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Photos uploaded via Drawings or Tasks will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final uploaded = await showDialog<bool>(
                              context: context,
                              builder: (context) => UploadMediaDialog(
                                initialProjectId: controller.leadId.value,
                              ),
                            );
                            if (uploaded == true) {
                              controller.fetchDetails(controller.leadId.value);
                            }
                          },
                          icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                          label: const Text('Upload Photo / Video'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final int count = mediaItems.length > 6 ? 6 : mediaItems.length;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: count,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.4,
                  ),
                  itemBuilder: (context, index) {
                    final item = mediaItems[index];
                    final url = item['url'] ?? '';
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: const Color(0xFFF1F5F9),
                        child: url.startsWith('http')
                            ? Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFFE2E8F0),
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Color(0xFF94A3B8),
                                      size: 24,
                                    ),
                                  ),
                                ),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFFE2E8F0),
                                  child: const Icon(
                                    Icons.image_outlined,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 16),
              // View All Media Outlined Button
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton(
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.drawings,
                      arguments: {'leadId': controller.leadId.value},
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 16,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'View All Media',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
