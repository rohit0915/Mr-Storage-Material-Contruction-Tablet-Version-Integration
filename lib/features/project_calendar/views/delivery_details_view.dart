import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../../delivery_tracking/controllers/delivery_details_controller.dart';

class DeliveryDetailsView extends GetView<DeliveryDetailsController> {
  const DeliveryDetailsView({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    menuTitle: 'Delivery Details',
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: AppShimmer(
            width: double.infinity,
            height: 620,
            borderRadius: 14,
          ),
        );
      }
      if (controller.delivery.isEmpty) {
        return _Empty(onRetry: controller.fetchDetails);
      }
      final project = controller.mapValue(['project']);
      final schedule = controller.mapValue(['schedule']);
      final carrier = controller.mapValue(['carrier']);
      final contact = controller.mapValue(['siteContact']);
      String v(List<String> keys, {String fallback = '—'}) =>
          controller.value(keys, fallback: fallback);
      String n(
        Map<String, dynamic> map,
        List<String> keys, {
        String fallback = '—',
      }) => controller.nestedValue(map, keys, fallback: fallback);
      final projectName = v([
        'projectName',
        'jobName',
      ], fallback: n(project, ['projectName', 'name', 'jobId']));
      final location = v([
        'deliveryLocation',
        'siteLocation',
        'location',
        'destination',
      ], fallback: n(project, ['location', 'siteLocation']));
      final material = v(['materialType', 'materialName', 'description']);
      final quantity = _withUnit(
        v(['loadWeight', 'weight', 'quantity', 'totalWeight']),
        v(['weightUnit', 'unit'], fallback: ''),
      );
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Actions(controller: controller, project: projectName),
            const SizedBox(height: 16),
            _Panel(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projectName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          location,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Meta(
                    'DELIVERY ID',
                    v(['deliveryNumber', 'code', 'deliveryId', '_id']),
                  ),
                  _Meta(
                    'CURRENT STATUS',
                    _title(v(['status', 'deliveryStatus'])),
                  ),
                  _Meta('PRIORITY', _title(v(['priority', 'priorityLevel']))),
                  _Meta(
                    'ETA',
                    _date(v(['eta', 'expectedArrival', 'deliveryTime'])),
                  ),
                  _Meta('STAGING AREA', v(['stagingArea', 'plant'])),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Grid(
              children: [
                _InfoCard('Material Information', [
                  _Row(Icons.inventory_2_outlined, 'Material', material),
                  _Row(Icons.domain_outlined, 'Project', projectName),
                  _Row(Icons.scale_outlined, 'Quantity', quantity),
                ]),
                _InfoCard('Plant Schedule', [
                  _Row(
                    Icons.calendar_today_outlined,
                    'Arrival at Plant',
                    _date(
                      v(
                        ['arrivalAtPlant', 'arrivalTime', 'expectedArrival'],
                        fallback: n(schedule, [
                          'arrivalAtPlant',
                          'arrivalDate',
                          'deliveryDate',
                        ]),
                      ),
                    ),
                  ),
                  _Row(
                    Icons.calendar_month_outlined,
                    'Departure from Plant',
                    _date(
                      v(
                        ['departureFromPlant', 'departureTime', 'pickupDate'],
                        fallback: n(schedule, [
                          'departureFromPlant',
                          'departureDate',
                          'pickupDate',
                        ]),
                      ),
                    ),
                  ),
                ]),
                _InfoCard('Site Contact', [
                  _Row(
                    Icons.person_outline,
                    'Name',
                    n(contact, ['contactName', 'name']),
                  ),
                  _Row(
                    Icons.phone_outlined,
                    'Phone',
                    n(contact, ['phone', 'contactPhone']),
                  ),
                  _Row(Icons.email_outlined, 'Email', n(contact, ['email'])),
                ]),
              ],
            ),
            const SizedBox(height: 16),
            _Grid(
              children: [
                _InfoCard('Carrier & Route', [
                  _Row(
                    Icons.local_shipping_outlined,
                    'Carrier',
                    v(
                      ['carrierName'],
                      fallback: n(carrier, ['name', 'carrierName', 'company']),
                    ),
                  ),
                  _Row(
                    Icons.badge_outlined,
                    'Driver',
                    v([
                      'driverName',
                      'driver',
                    ], fallback: n(carrier, ['driverName'])),
                  ),
                  _Row(
                    Icons.fire_truck_outlined,
                    'Truck',
                    v(['truck', 'vehicle', 'truckNumber']),
                  ),
                  _Row(Icons.location_on_outlined, 'Destination', location),
                ]),
                _InfoCard('Weight Units + Material Type', [
                  _Row(Icons.scale_outlined, 'Quantity', quantity),
                  _Row(Icons.category_outlined, 'Material Type', material),
                  _Row(
                    Icons.inventory_outlined,
                    'Packaging',
                    v(['packaging', 'packageSummary', 'packagingType']),
                  ),
                  _Row(
                    Icons.notes_outlined,
                    'Instructions',
                    v(['notes', 'specialInstructions', 'instructions']),
                  ),
                ]),
                _Documents(controller: controller),
              ],
            ),
            const SizedBox(height: 16),
            _Timeline(controller: controller),
          ],
        ),
      );
    }),
  );
}

class _Actions extends StatelessWidget {
  const _Actions({required this.controller, required this.project});
  final DeliveryDetailsController controller;
  final String project;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton.filled(
        onPressed: Get.back,
        icon: const Icon(Icons.arrow_back),
        style: IconButton.styleFrom(backgroundColor: AppColors.primaryBlue),
      ),
      const SizedBox(width: 10),
      const Text(
        'Delivery Details',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      const Spacer(),
      Obx(() {
        final status = controller.value(['status']).toLowerCase();
        final isDelivered = status == 'delivered' || status == 'received';
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (!isDelivered) ...[
              _Button(
                'Mark as Received',
                controller.isActionLoading.value
                    ? null
                    : () => _confirm(context, controller),
              ),
              _Button(
                'Scan QR Code',
                () => Get.toNamed(
                  AppRoutes.bundleScan,
                  arguments: {
                    'deliveryId': controller.requestId,
                    'project': project,
                  },
                ),
              ),
              _Button(
                'Partial Received',
                controller.isActionLoading.value
                    ? null
                    : () => _partial(context, controller),
              ),
            ],
            _Button(
              'Update Site Contact',
              controller.isActionLoading.value
                  ? null
                  : () => _contact(context, controller),
            ),
          ],
        );
      }),
    ],
  );
}

class _Button extends StatelessWidget {
  const _Button(this.text, this.onPressed);
  final String text;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: child,
  );
}

class _Meta extends StatelessWidget {
  const _Meta(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 12),
    padding: const EdgeInsets.all(11),
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
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => c.maxWidth < 900
        ? Column(
            children: children
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: e,
                  ),
                )
                .toList(),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                Expanded(child: children[i]),
                if (i < children.length - 1) const SizedBox(width: 16),
              ],
            ],
          ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(this.title, this.rows);
  final String title;
  final List<Widget> rows;
  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        for (int i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i < rows.length - 1) const SizedBox(height: 10),
        ],
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Documents extends StatelessWidget {
  const _Documents({required this.controller});
  final DeliveryDetailsController controller;
  @override
  Widget build(BuildContext context) {
    final docs = controller.listValue(['documents', 'attachments', 'files']);
    return _InfoCard(
      'Documents',
      docs.isEmpty
          ? [
              const Text(
                'No documents available',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ]
          : docs.whereType<Map>().map((raw) {
              final doc = Map<String, dynamic>.from(raw);
              final name = controller.nestedValue(doc, [
                'name',
                'fileName',
                'title',
              ]);
              final lower = '${doc['type'] ?? ''} $name'.toLowerCase();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.badgeRed,
                ),
                title: Text(name),
                subtitle: Text(
                  controller.nestedValue(doc, [
                    'size',
                    'fileSize',
                  ], fallback: ''),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () => controller.downloadDocument(
                    lower.contains('bill') ? 'bill-of-lading' : 'packing-list',
                  ),
                ),
              );
            }).toList(),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.controller});
  final DeliveryDetailsController controller;
  @override
  Widget build(BuildContext context) {
    final items = controller.listValue([
      'timeline',
      'statusHistory',
      'deliveryTimeline',
    ]);
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Timeline & Flow',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text(
              'No timeline data available',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            for (final raw in items.whereType<Map>())
              _TimelineRow(controller, Map<String, dynamic>.from(raw)),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow(this.controller, this.data);
  final DeliveryDetailsController controller;
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    final state = controller.nestedValue(data, [
      'state',
      'status',
    ], fallback: '').toLowerCase();
    final done = state.contains('complete') || state.contains('done');
    final active =
        state.contains('progress') ||
        state.contains('current') ||
        state.contains('transit');
    final color = done
        ? AppColors.badgeGreen
        : active
        ? AppColors.primaryBlue
        : AppColors.textSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: active ? AppColors.primaryBlue : AppColors.cardBorder,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle
                : active
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.nestedValue(data, ['title', 'label', 'name', 'event']),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            _date(
              controller.nestedValue(data, [
                'date',
                'timestamp',
                'completedAt',
                'targetDate',
              ]),
            ),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Text(
            _title(state),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 48),
        const SizedBox(height: 12),
        const Text('Delivery data is not available'),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

Future<void> _confirm(BuildContext context, DeliveryDetailsController c) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Mark as received?'),
      content: const Text('This updates the delivery through the API.'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
  if (ok == true) await c.markReceived();
}

Future<void> _partial(BuildContext context, DeliveryDetailsController c) async {
  final ctrl = TextEditingController();
  final notes = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Mark as Partial Received'),
      content: TextField(
        controller: ctrl,
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'Notes'),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Get.back(result: ctrl.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  ctrl.dispose();
  if (notes?.isNotEmpty == true) await c.markPartial(notes!);
}

Future<void> _contact(BuildContext context, DeliveryDetailsController c) async {
  final old = c.mapValue(['siteContact']);
  String val(List<String> k) => c.nestedValue(old, k, fallback: '');
  final name = TextEditingController(text: val(['contactName', 'name'])),
      title = TextEditingController(text: val(['contactTitle', 'title'])),
      phone = TextEditingController(text: val(['phone'])),
      email = TextEditingController(text: val(['email']));
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Update Site Contact'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Contact name'),
            ),
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Contact title'),
            ),
            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Get.back(
            result: {
              'contactName': name.text.trim(),
              'contactTitle': title.text.trim(),
              'phone': phone.text.trim(),
              'email': email.text.trim(),
            },
          ),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  name.dispose();
  title.dispose();
  phone.dispose();
  email.dispose();
  if (result != null) await c.updateSiteContact(result);
}

String _date(String raw) {
  if (raw == '—' || raw.isEmpty) return '—';
  final parsed = DateTime.tryParse(raw);
  return parsed == null
      ? raw
      : DateFormat('EEE, MMM d, yyyy • h:mm a').format(parsed.toLocal());
}

String _title(String raw) {
  if (raw == '—' || raw.isEmpty) return '—';
  return raw
      .replaceAll('_', ' ')
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');
}

String _withUnit(String value, String unit) =>
    value == '—' ||
        unit.isEmpty ||
        value.toLowerCase().contains(unit.toLowerCase())
    ? value
    : '$value $unit';
