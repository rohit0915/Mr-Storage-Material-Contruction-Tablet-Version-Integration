import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_logger.dart';
import '../models/project_calendar_models.dart';
import '../services/project_calendar_service.dart';

class DeliveryDetailsDialog extends StatefulWidget {
  const DeliveryDetailsDialog({
    super.key,
    required this.item,
  });

  final DeliveryItem item;

  @override
  State<DeliveryDetailsDialog> createState() => _DeliveryDetailsDialogState();
}

class _DeliveryDetailsDialogState extends State<DeliveryDetailsDialog> {
  final _service = Get.find<ProjectCalendarService>();
  bool _isLoading = true;
  Map<String, dynamic>? _deliveryData;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final res = await _service.getDeliveryDetails(widget.item.id);
      if (res != null) {
        if (res['delivery'] is Map) {
          _deliveryData = Map<String, dynamic>.from(res['delivery'] as Map);
        } else {
          _deliveryData = res;
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('DeliveryDetailsDialog fetch error', error: e, stackTrace: stackTrace, tag: 'DELIVERY_DIALOG');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width * 0.65).clamp(650.0, 780.0);

    final dMap = _deliveryData ?? {};
    final deliveryNum = dMap['deliveryNumber']?.toString().isNotEmpty == true
        ? dMap['deliveryNumber'].toString()
        : widget.item.code;

    final statusRaw = (dMap['status'] ?? widget.item.status ?? 'scheduled').toString().toLowerCase();

    String statusDisplay = statusRaw.replaceAll('_', ' ');
    if (statusDisplay.isNotEmpty) {
      statusDisplay = statusDisplay
          .split(' ')
          .map((w) => w.isNotEmpty ? (w[0].toUpperCase() + w.substring(1)) : '')
          .join(' ');
    }

    int activeIndex = 0;
    if (statusRaw.contains('transit')) {
      activeIndex = 4;
    } else if (statusRaw.contains('staged')) {
      activeIndex = 6;
    } else if (statusRaw.contains('delivered') || statusRaw.contains('received')) {
      activeIndex = 8;
    } else if (statusRaw.contains('dispatched')) {
      activeIndex = 7;
    } else if (statusRaw.contains('arrived')) {
      activeIndex = 5;
    } else if (statusRaw.contains('picked')) {
      activeIndex = 3;
    } else if (statusRaw.contains('loaded')) {
      activeIndex = 2;
    } else if (statusRaw.contains('confirmed') || statusRaw.contains('prepared') || statusRaw.contains('bidding')) {
      activeIndex = 1;
    } else {
      activeIndex = 0;
    }

    final schedule = (dMap['schedule'] is Map) ? (dMap['schedule'] as Map) : {};
    final pickupDateStr = schedule['pickupDate']?.toString() ?? '';
    final pickupTimeStr = schedule['pickupTime']?.toString() ?? '';
    final delivDateStr = schedule['deliveryDate']?.toString() ?? widget.item.date;
    final delivTimeStr = schedule['deliveryTime']?.toString() ?? '';

    final matType = (dMap['materialType']?.toString().isNotEmpty == true)
        ? dMap['materialType'].toString()
        : 'framing, panels, mixed, accessories';
    final loadWeight = dMap['loadWeight'] != null ? '${dMap['loadWeight']} lbs' : '45,000 lbs';
    final pkgCount = dMap['packageCount'] != null ? '${dMap['packageCount']}' : 'N/A';

    final equipmentList = (dMap['loadingEquipment'] is List && (dMap['loadingEquipment'] as List).isNotEmpty)
        ? (dMap['loadingEquipment'] as List).join(', ')
        : 'Crane';
    final notesRaw = dMap['notes']?.toString() ?? '';
    final notesStr = notesRaw.isNotEmpty ? notesRaw : 'No special instructions provided.';

    String origin = dMap['pickupLocation']?.toString() ?? 'Texas';
    if (origin.contains(',')) {
      origin = origin.split(',')[0];
    }
    if (origin.isEmpty) {
      origin = 'Texas';
    }

    String dest = dMap['deliveryLocation']?.toString() ?? 'California craft beer';
    if (dest.contains(',')) {
      dest = dest.split(',')[0];
    }
    if (dest.isEmpty) {
      dest = 'California craft beer';
    }

    final staging = dMap['stagingArea']?.toString().isNotEmpty == true ? dMap['stagingArea'].toString() : 'Yard-A';
    final pocName = dMap['receivingPoc']?.toString().isNotEmpty == true ? dMap['receivingPoc'].toString() : 'N/A';
    final pocPhone = dMap['pickupContactPhone']?.toString().isNotEmpty == true ? dMap['pickupContactPhone'].toString() : 'N/A';

    String carrierEmail = 'Not Assigned';
    if (dMap['carrier'] is Map) {
      final em = dMap['carrier']['email']?.toString() ?? '';
      final dn = dMap['carrier']['driverName']?.toString() ?? '';
      final ph = dMap['carrier']['phone']?.toString() ?? '';
      if (em.isNotEmpty) {
        carrierEmail = em;
      } else if (dn.isNotEmpty) {
        carrierEmail = dn;
      } else if (ph.isNotEmpty) {
        carrierEmail = ph;
      }
    }

    String projName = '';
    if (dMap['project'] is Map) {
      projName = (dMap['project']['projectName'] ?? dMap['project']['jobId'] ?? '').toString();
    }
    if (projName.isEmpty && widget.item.projectName.isNotEmpty && widget.item.projectName != 'No Project' && widget.item.projectName != 'Project') {
      projName = widget.item.projectName;
    }
    if (projName.isEmpty) projName = 'N/A';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: size.height * 0.9),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dialog Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Delivery Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusDisplay.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          deliveryNum,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                // Top Status Banner Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Current Status',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEAB308),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ETA ${delivTimeStr.isNotEmpty ? delivTimeStr : "13:26"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            statusDisplay,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Staging Area',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            staging,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stepper / Status Badges Row
                _buildStepper(activeIndex),
                const SizedBox(height: 18),

                // Delivery Flow Banner (Origin -> Plant -> Destination)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    children: [
                      _FlowNode(
                        icon: Icons.local_shipping_rounded,
                        iconBg: AppColors.primaryBlue,
                        label: 'ORIGIN',
                        value: origin,
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 18),
                      const Spacer(),
                      _FlowNode(
                        icon: Icons.storefront_rounded,
                        iconBg: const Color(0xFF22C55E),
                        label: 'PLANT',
                        value: staging,
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 18),
                      const Spacer(),
                      _FlowNode(
                        icon: Icons.location_on_rounded,
                        iconBg: const Color(0xFFF97316),
                        label: 'DESTINATION',
                        value: dest,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3-Column Info Cards Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Material Information
                    Expanded(
                      child: _InfoSectionCard(
                        title: 'Material Information',
                        children: [
                          _DetailTile(
                            icon: Icons.inventory_2_outlined,
                            iconBg: const Color(0xFFF3E8FF),
                            iconColor: const Color(0xFF9333EA),
                            label: 'MATERIAL',
                            value: matType,
                          ),
                          const SizedBox(height: 10),
                          _DetailTile(
                            icon: Icons.location_on_outlined,
                            iconBg: const Color(0xFFEFF6FF),
                            iconColor: AppColors.primaryBlue,
                            label: 'PROJECT',
                            value: projName,
                          ),
                          const SizedBox(height: 10),
                          _DetailTile(
                            icon: Icons.scale_outlined,
                            iconBg: const Color(0xFFFEF3C7),
                            iconColor: const Color(0xFFD97706),
                            label: 'QUANTITY',
                            value: loadWeight,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Plant Schedule
                    Expanded(
                      child: _InfoSectionCard(
                        title: 'Plant Schedule',
                        children: [
                          _DetailTile(
                            icon: Icons.calendar_today_outlined,
                            iconBg: const Color(0xFFDCFCE7),
                            iconColor: const Color(0xFF166534),
                            label: 'ARRIVAL',
                            value: _formatDateStr(delivDateStr, delivTimeStr),
                          ),
                          const SizedBox(height: 10),
                          _DetailTile(
                            icon: Icons.calendar_month_outlined,
                            iconBg: const Color(0xFFFEF3C7),
                            iconColor: const Color(0xFFD97706),
                            label: 'DEPARTURE',
                            value: _formatDateStr(pickupDateStr, pickupTimeStr),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Carrier & Route
                    Expanded(
                      child: _InfoSectionCard(
                        title: 'Carrier & Route',
                        children: [
                          _DetailTile(
                            icon: Icons.local_shipping_outlined,
                            iconBg: const Color(0xFFEFF6FF),
                            iconColor: AppColors.primaryBlue,
                            label: 'CARRIER',
                            value: carrierEmail,
                          ),
                          const SizedBox(height: 10),
                          _DetailTile(
                            icon: Icons.person_outline_rounded,
                            iconBg: const Color(0xFFEFF6FF),
                            iconColor: AppColors.primaryBlue,
                            label: 'POC',
                            value: pocName,
                          ),
                          const SizedBox(height: 10),
                          _DetailTile(
                            icon: Icons.phone_outlined,
                            iconBg: const Color(0xFFEFF6FF),
                            iconColor: AppColors.primaryBlue,
                            label: 'Ph',
                            value: pocPhone,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Material Info Box & Documents Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Material Info Box
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Material Info',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$loadWeight • $matType',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$pkgCount PACKAGES + EQUIPMENT: ${equipmentList.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Documents
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Documents',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: _DocDownloadButton(
                                  title: 'Packing list',
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _DocDownloadButton(
                                  title: 'Bill of lading',
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Special Instructions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Special Instructions',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        notesStr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(int activeIdx) {
    final titles = [
      'Scheduled',
      'Material Prepared',
      'Loaded',
      'Picked Up',
      'In Transit',
      'Arrived at Plant',
      'Staged',
      'Dispatched to Site',
      'Delivered',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(titles.length, (idx) {
          final isChecked = idx < activeIdx;
          final isActive = idx == activeIdx;
          final isLast = idx == titles.length - 1;
          return _StepBadge(
            title: titles[idx],
            isChecked: isChecked,
            isActive: isActive,
            isLast: isLast,
          );
        }),
      ),
    );
  }

  String _formatDateStr(String dateRaw, String timeRaw) {
    if (dateRaw.isEmpty || dateRaw == 'null') return timeRaw.isNotEmpty ? timeRaw : 'N/A';
    try {
      final dt = DateTime.parse(dateRaw);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final mName = months[dt.month - 1];
      if (timeRaw.isNotEmpty) {
        return '$mName ${dt.day}, $timeRaw';
      }
      return '$mName ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateRaw;
    }
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.title,
    this.isChecked = false,
    this.isActive = false,
    this.isLast = false,
  });

  final String title;
  final bool isChecked;
  final bool isActive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isChecked)
              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primaryBlue)
            else if (isActive)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAB308),
                  shape: BoxShape.circle,
                ),
              )
            else
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textSecondary, width: 1.5),
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: (isChecked || isActive) ? FontWeight.w700 : FontWeight.w500,
                color: (isChecked || isActive) ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('•', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
      ],
    );
  }
}

class _FlowNode extends StatelessWidget {
  const _FlowNode({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
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
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DocDownloadButton extends StatelessWidget {
  const _DocDownloadButton({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const Icon(Icons.download_rounded, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
