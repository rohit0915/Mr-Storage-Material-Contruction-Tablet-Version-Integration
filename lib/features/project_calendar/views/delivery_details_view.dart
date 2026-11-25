import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../../delivery_tracking/controllers/delivery_details_controller.dart';
import '../../delivery_tracking/models/delivery_tracking_models.dart';
import '../../delivery_tracking/widgets/delivery_dialogs.dart';
import '../../dispatch_verification/controllers/dispatch_verification_controller.dart';

class DeliveryDetailsView extends GetView<DeliveryDetailsController> {
  const DeliveryDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<DeliveryDetailsController>()
        ? Get.find<DeliveryDetailsController>()
        : Get.put(DeliveryDetailsController());

    final size = MediaQuery.sizeOf(context);
    final padH = (size.width * 0.02).clamp(16.0, 24.0);

    return AppScaffold(
      menuTitle: 'Projects & Calendar',
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const _DeliveryDetailsShimmer();
        }

        if (ctrl.fromProject && ctrl.delivery.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFD97706),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Material Delivery Found',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'There are no material deliveries scheduled or assigned for this project yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text(
                        'Back to Project',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final deliveryNumber = ctrl.value(['deliveryNumber', 'code', 'deliveryId'], fallback: '-');
        final description = ctrl.value(['description', 'title', 'materialType'], fallback: '-');
        final rawStatus = ctrl.value(['status', 'deliveryStatus'], fallback: 'SCHEDULED');
        final statusUpper = rawStatus.toUpperCase();
        final isConfirmed = statusUpper.contains('CONFIRM') || statusUpper.contains('STAGED');
        final statusDisplay = isConfirmed ? 'Confirmed' : _formatTitle(rawStatus);

        final projectMap = ctrl.mapValue(['project']);
        String projectName = '-';
        if (projectMap.isNotEmpty) {
          projectName = ctrl.nestedValue(projectMap, ['projectName', 'name', 'jobId'], fallback: '-');
        }
        if (projectName == '-' || projectName.isEmpty) {
          final pVal = ctrl.value(['projectName', 'jobName']);
          if (pVal != '-' && pVal != '—' && pVal.isNotEmpty) {
            projectName = pVal;
          } else if (ctrl.projectNameArg.isNotEmpty) {
            projectName = ctrl.projectNameArg;
          }
        }

        final receivingPoc = ctrl.value(['receivingPoc', 'pocName'], fallback: ctrl.nestedValue(ctrl.mapValue(['siteContact']), ['contactName', 'name'], fallback: '-'));

        final scheduleMap = ctrl.mapValue(['schedule']);
        final rawDeliveryDate = ctrl.nestedValue(scheduleMap, ['deliveryDate', 'departureFromPlant'], fallback: ctrl.value(['deliveryDate', 'expectedArrival'], fallback: ''));
        final deliveryDate = _formatDate(rawDeliveryDate, fallback: '-');

        final timeWindow = ctrl.nestedValue(scheduleMap, ['deliveryTime', 'timings'], fallback: ctrl.value(['timeWindow', 'eta', 'timeWindowEta', 'deliveryTime'], fallback: '-'));
        final siteAddress = ctrl.value(['siteDeliveryAddress', 'deliveryLocation', 'destination', 'location'], fallback: ctrl.nestedValue(projectMap, ['location', 'siteLocation'], fallback: ctrl.locationArg.isNotEmpty ? ctrl.locationArg : '-'));

        final materialType = ctrl.value(['materialType'], fallback: '-');
        final pickupDate = _formatDate(ctrl.nestedValue(scheduleMap, ['pickupDate', 'arrivalAtPlant'], fallback: ctrl.value(['pickupDate'], fallback: '')), fallback: '-');
        final pickupTime = ctrl.nestedValue(scheduleMap, ['pickupTime'], fallback: ctrl.value(['pickupTime'], fallback: '-'));

        final carrierMap = ctrl.mapValue(['carrier']);
        final rawCarrier = ctrl.nestedValue(carrierMap, ['driverName', 'name', 'carrierName', 'company'], fallback: ctrl.value(['carrierName', 'carrier'], fallback: '-'));
        final carrierName = (rawCarrier.isNotEmpty && rawCarrier != '—' && rawCarrier != '-' && rawCarrier.toLowerCase() != 'null') ? rawCarrier : 'Assigned Carrier';
        final carrierPhone = ctrl.nestedValue(carrierMap, ['driverPhone', 'phone'], fallback: ctrl.value(['carrierPhone', 'phone'], fallback: '-'));

        final rawWeight = ctrl.value(['loadWeight', 'weight', 'quantity', 'totalWeight'], fallback: '-');
        final loadWeight = (rawWeight != '-' && rawWeight != '—' && double.tryParse(rawWeight.replaceAll(RegExp(r'[^0-9.]'), '')) != null)
            ? (rawWeight.contains('lbs') ? rawWeight : '$rawWeight lbs')
            : (rawWeight != '—' ? rawWeight : '-');
        final rawPackages = ctrl.value(['packageCount', 'bundleCount'], fallback: '-');
        final packageCount = (rawPackages != '-' && rawPackages != '—')
            ? (rawPackages.toLowerCase().contains('package') ? rawPackages : '$rawPackages Packages')
            : '-';
        final stagingArea = ctrl.value(['stagingArea', 'plant'], fallback: '-');

        final reqEquipment = ctrl.value(['requiredLoadingEquipment', 'equipment', 'loadingEquipment'], fallback: '-');
        final instructions = ctrl.value(['specialInstructions', 'notes', 'instructions'], fallback: 'No special instructions provided.');

        final contactMap = ctrl.mapValue(['siteContact']);
        final contactName = ctrl.nestedValue(contactMap, ['contactName', 'name'], fallback: ctrl.value(['contactName'], fallback: '-'));
        final contactRole = ctrl.nestedValue(contactMap, ['role', 'contactTitle', 'title'], fallback: 'Site Receiving Lead');
        final contactPhone = ctrl.nestedValue(contactMap, ['phone', 'contactPhone'], fallback: ctrl.value(['contactPhone', 'pickupContactPhone', 'pocPhone'], fallback: '-'));

        final origin = ctrl.value(['origin', 'pickupLocation'], fallback: '-');
        final destination = ctrl.value(['destination', 'finalDestination', 'deliveryLocation', 'location'], fallback: siteAddress != '-' ? siteAddress : '-');

        final isDelivered = statusUpper.contains('DELIVER') || statusUpper.contains('RECEIV');

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header: Back Button, Title, Badge, Subtitle & Download Buttons ───
              _buildTopHeader(context, ctrl, deliveryNumber, description, statusUpper),
              const SizedBox(height: 20),

              // ─── Responsive 2-Column Grid (Left ~68%, Right ~32%) ───
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 960;

                  final leftColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card 1: DELIVERY FLOW
                      _buildDeliveryFlowCard(origin, destination),
                      const SizedBox(height: 16),

                      // Card 2: Delivery Overview
                      _buildDeliveryOverviewCard(statusUpper, projectName, receivingPoc, deliveryDate, timeWindow, siteAddress),
                      const SizedBox(height: 16),

                      // Card 3: Delivery Information
                      _buildDeliveryInformationCard(description, materialType, pickupDate, pickupTime),
                      const SizedBox(height: 16),

                      // Card 4: Carrier & Driver and Load & Quantity (Side by side)
                      _buildCarrierAndLoadRow(carrierName, carrierPhone, loadWeight, packageCount, stagingArea),
                      const SizedBox(height: 16),

                      // Card 5: Site Coordination & Instructions
                      _buildSiteCoordinationCard(reqEquipment, instructions),
                    ],
                  );

                  final rightColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card 1: DELIVERY STATUS
                      _buildDeliveryStatusCard(statusDisplay, statusUpper),
                      const SizedBox(height: 16),

                      // Card 2: RECEIVING POINT OF CONTACT
                      _buildReceivingPocCard(contactName, contactRole, contactPhone),
                      const SizedBox(height: 16),

                      // Card 3: DOCUMENTS & DOWNLOADS
                      _buildDocumentsCard(ctrl),
                      const SizedBox(height: 16),

                      // Card 4: STATUS HISTORY
                      _buildStatusHistoryCard(statusDisplay),
                    ],
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 68, child: leftColumn),
                        const SizedBox(width: 20),
                        Expanded(flex: 32, child: rightColumn),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      leftColumn,
                      const SizedBox(height: 20),
                      rightColumn,
                    ],
                  );
                },
              ),

              // ─── Operational Actions (Bottom bar if not completed) ───
              if (!isDelivered && !ctrl.fromProject) ...[
                const SizedBox(height: 24),
                _buildWarehouseActions(context, ctrl, projectName),
              ],
            ],
          ),
        );
      }),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTopHeader(
    BuildContext context,
    DeliveryDetailsController ctrl,
    String deliveryNumber,
    String description,
    String statusUpper,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        final subText = (description.isNotEmpty && description != '-' && description != '—')
            ? '$deliveryNumber • $description'
            : deliveryNumber;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _backButton(),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Delivery Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _buildStatusPill(statusUpper),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _packingListButton(ctrl)),
                  const SizedBox(width: 10),
                  Expanded(child: _billOfLadingButton(ctrl)),
                ],
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _backButton(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      const Text(
                        'Delivery Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      _buildStatusPill(statusUpper),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _packingListButton(ctrl),
            const SizedBox(width: 10),
            _billOfLadingButton(ctrl),
          ],
        );
      },
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: Get.back,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              'Back',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _packingListButton(DeliveryDetailsController ctrl) {
    return OutlinedButton.icon(
      onPressed: ctrl.isActionLoading.value
          ? null
          : () => ctrl.downloadDocument('packing-list'),
      icon: const Icon(Icons.download_outlined, size: 16, color: Color(0xFF1E293B)),
      label: const Text(
        'Packing List',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Color(0xFF1E293B),
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _billOfLadingButton(DeliveryDetailsController ctrl) {
    return ElevatedButton.icon(
      onPressed: ctrl.isActionLoading.value
          ? null
          : () => ctrl.downloadDocument('bill-of-lading'),
      icon: const Icon(Icons.assignment_outlined, size: 16, color: Colors.white),
      label: const Text(
        'Bill of Lading',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LEFT COLUMN CARDS
  // ──────────────────────────────────────────────────────────────────────────

  // Card 1: DELIVERY FLOW
  Widget _buildDeliveryFlowCard(String origin, String destination) {
    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DELIVERY FLOW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 620;

              if (isNarrow) {
                return Column(
                  children: [
                    _flowLocationItem(
                      icon: Icons.local_shipping,
                      iconBg: const Color(0xFF2563EB),
                      label: 'ORIGIN',
                      address: origin,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const SizedBox(width: 18),
                          Container(
                            width: 2,
                            height: 22,
                            color: const Color(0xFFBFDBFE),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.arrow_downward,
                            size: 14,
                            color: Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ),
                    _flowLocationItem(
                      icon: Icons.location_on,
                      iconBg: const Color(0xFFEA580C),
                      label: 'DESTINATION',
                      address: destination,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Origin
                  Expanded(
                    flex: 5,
                    child: _flowLocationItem(
                      icon: Icons.local_shipping,
                      iconBg: const Color(0xFF2563EB),
                      label: 'ORIGIN',
                      address: origin,
                    ),
                  ),

                  // Dotted Line with Centered Arrow
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomPaint(
                              size: const Size(double.infinity, 2),
                              painter: _DottedLinePainter(),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          Expanded(
                            child: CustomPaint(
                              size: const Size(double.infinity, 2),
                              painter: _DottedLinePainter(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Destination
                  Expanded(
                    flex: 5,
                    child: _flowLocationItem(
                      icon: Icons.location_on,
                      iconBg: const Color(0xFFEA580C),
                      label: 'DESTINATION',
                      address: destination,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _flowLocationItem({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String address,
  }) {
    final cleanAddress = address.trim().isNotEmpty ? address : '—';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Tooltip(
                message: cleanAddress,
                child: Text(
                  cleanAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Card 2: Delivery Overview
  Widget _buildDeliveryOverviewCard(
    String statusUpper,
    String projectName,
    String receivingPoc,
    String deliveryDate,
    String timeWindow,
    String siteAddress,
  ) {
    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              _buildStatusPill(statusUpper),
            ],
          ),
          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 480;

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iconDataField(icon: Icons.domain, label: 'PROJECT', value: projectName),
                    const SizedBox(height: 14),
                    _iconDataField(icon: Icons.person_outline, label: 'RECEIVING POC', value: receivingPoc),
                    const SizedBox(height: 14),
                    _iconDataField(icon: Icons.calendar_today_outlined, label: 'DELIVERY DATE', value: deliveryDate),
                    const SizedBox(height: 14),
                    _iconDataField(icon: Icons.access_time_outlined, label: 'TIME WINDOW / ETA', value: timeWindow),
                    const SizedBox(height: 14),
                    _iconDataField(icon: Icons.location_on_outlined, label: 'SITE DELIVERY ADDRESS', value: siteAddress),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _iconDataField(
                          icon: Icons.domain,
                          label: 'PROJECT',
                          value: projectName,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _iconDataField(
                          icon: Icons.person_outline,
                          label: 'RECEIVING POC',
                          value: receivingPoc,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _iconDataField(
                          icon: Icons.calendar_today_outlined,
                          label: 'DELIVERY DATE',
                          value: deliveryDate,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _iconDataField(
                          icon: Icons.access_time_outlined,
                          label: 'TIME WINDOW / ETA',
                          value: timeWindow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _iconDataField(
                    icon: Icons.location_on_outlined,
                    label: 'SITE DELIVERY ADDRESS',
                    value: siteAddress,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Card 3: Delivery Information
  Widget _buildDeliveryInformationCard(
    String description,
    String materialType,
    String pickupDate,
    String pickupTime,
  ) {
    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 18),

          _iconDataField(
            icon: Icons.layers_outlined,
            label: 'DESCRIPTION',
            value: description,
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _textDataField('MATERIAL TYPE', materialType),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textDataField('PICKUP DATE', pickupDate),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textDataField('PICKUP TIME', pickupTime),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 4: Carrier & Driver and Load & Quantity (Side by side)
  Widget _buildCarrierAndLoadRow(
    String carrierName,
    String carrierPhone,
    String loadWeight,
    String packageCount,
    String stagingArea,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 540;

        final cardCarrier = _CardBox(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Text(
                    'Carrier & Driver',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                carrierName.isNotEmpty && carrierName != '—' && carrierName != '-'
                    ? carrierName
                    : 'Assigned Carrier',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    carrierPhone.isNotEmpty && carrierPhone != '—' ? carrierPhone : '-',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        final cardLoad = _CardBox(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.view_in_ar_outlined, size: 16, color: Color(0xFF7C3AED)),
                  SizedBox(width: 8),
                  Text(
                    'Load & Quantity',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _kvRow('LOAD WEIGHT:', loadWeight),
              const SizedBox(height: 8),
              _kvRow('PACKAGE COUNT:', packageCount),
              const SizedBox(height: 8),
              _kvRow('STAGING AREA:', stagingArea),
            ],
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cardCarrier,
              const SizedBox(height: 14),
              cardLoad,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cardCarrier),
            const SizedBox(width: 16),
            Expanded(child: cardLoad),
          ],
        );
      },
    );
  }

  // Card 5: Site Coordination & Instructions
  Widget _buildSiteCoordinationCard(String reqEquipment, String instructions) {
    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Site Coordination & Instructions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 540;

              final col1 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.build_outlined, size: 14, color: Color(0xFF64748B)),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'REQUIRED LOADING EQUIPMENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reqEquipment.isNotEmpty ? reqEquipment : '—',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              );

              final col2 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SPECIAL INSTRUCTIONS / NOTES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    instructions.isNotEmpty ? instructions : 'No special instructions provided.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    col1,
                    const SizedBox(height: 14),
                    col2,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: col1),
                  const SizedBox(width: 20),
                  Expanded(flex: 6, child: col2),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // RIGHT COLUMN CARDS
  // ──────────────────────────────────────────────────────────────────────────

  // Card 1: DELIVERY STATUS
  Widget _buildDeliveryStatusCard(String statusDisplay, String statusUpper) {
    Color dotColor = const Color(0xFF155DFC);
    if (statusUpper.contains('CONFIRM') ||
        statusUpper.contains('RECEIV') ||
        statusUpper.contains('DELIVER')) {
      dotColor = const Color(0xFF00C853);
    } else if (statusUpper.contains('STAGE')) {
      dotColor = const Color(0xFFCA8A04);
    } else if (statusUpper.contains('TRANSIT')) {
      dotColor = const Color(0xFF2563EB);
    }

    return _CardBox(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DELIVERY STATUS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusDisplay,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusPill(statusUpper),
            ],
          ),
        ],
      ),
    );
  }

  // Card 2: RECEIVING POINT OF CONTACT
  Widget _buildReceivingPocCard(String contactName, String contactRole, String contactPhone) {
    return _CardBox(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECEIVING POINT OF CONTACT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'POC',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contactName.isNotEmpty ? contactName : '—',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contactRole.isNotEmpty ? contactRole : 'Site Receiving Lead',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                contactPhone.isNotEmpty && contactPhone != '—' && contactPhone != 'gh' ? contactPhone : '-',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 3: DOCUMENTS & DOWNLOADS
  Widget _buildDocumentsCard(DeliveryDetailsController ctrl) {
    return _CardBox(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DOCUMENTS & DOWNLOADS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),

          // Download Packing List
          InkWell(
            onTap: ctrl.isActionLoading.value
                ? null
                : () => ctrl.downloadDocument('packing-list'),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: const Row(
                children: [
                  Icon(Icons.download_outlined, color: Color(0xFF2563EB), size: 16),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Download Packing List',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Download Bill of Lading (BOL)
          InkWell(
            onTap: ctrl.isActionLoading.value
                ? null
                : () => ctrl.downloadDocument('bill-of-lading'),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: const Row(
                children: [
                  Icon(Icons.description_outlined, color: Color(0xFF64748B), size: 16),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Download Bill of Lading (BOL)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
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

  // Card 4: STATUS HISTORY
  Widget _buildStatusHistoryCard(String statusDisplay) {
    return _CardBox(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STATUS HISTORY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusDisplay,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'CURRENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // OPERATIONAL ACTION BUTTONS (BOTTOM)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWarehouseActions(
    BuildContext context,
    DeliveryDetailsController ctrl,
    String project,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: ctrl.isActionLoading.value
                ? null
                : () => _confirmReceived(context, ctrl),
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('Mark as Received'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(
              AppRoutes.bundleScan,
              arguments: {
                'deliveryId': ctrl.requestId,
                'project': project,
              },
            ),
            icon: const Icon(Icons.qr_code_scanner, size: 16),
            label: const Text('Scan QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: ctrl.isActionLoading.value
                ? null
                : () => _partialReceived(context, ctrl),
            icon: const Icon(Icons.inventory_2_outlined, size: 16),
            label: const Text('Partial Received'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          OutlinedButton.icon(
            onPressed: ctrl.isActionLoading.value
                ? null
                : () => _updateContact(context, ctrl),
            icon: const Icon(Icons.person_outline, size: 16),
            label: const Text('Update Site Contact'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E293B),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPER WIDGETS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildStatusPill(String statusUpper) {
    Color bg = const Color(0xFFE6F0FF);
    Color fg = const Color(0xFF155DFC);

    if (statusUpper.contains('CONFIRM') ||
        statusUpper.contains('RECEIV') ||
        statusUpper.contains('DELIVER')) {
      bg = const Color(0xFFE6FFEF);
      fg = const Color(0xFF00C853);
    } else if (statusUpper.contains('SCHEDUL')) {
      bg = const Color(0xFFE6F0FF);
      fg = const Color(0xFF155DFC);
    } else if (statusUpper.contains('TRANSIT')) {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF2563EB);
    } else if (statusUpper.contains('STAGE')) {
      bg = const Color(0xFFFEFCE8);
      fg = const Color(0xFFCA8A04);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusUpper.isNotEmpty ? statusUpper : 'SCHEDULED',
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _iconDataField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF2563EB)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value.isNotEmpty ? value : '—',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _textDataField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value.isNotEmpty ? value : '—',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _kvRow(String key, String value, {bool isBold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            key,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Text(
          value.isNotEmpty ? value : '—',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// REUSABLE CARD CONTAINER
// ──────────────────────────────────────────────────────────────────────────
class _CardBox extends StatelessWidget {
  const _CardBox({required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// DOTTED LINE PAINTER
// ──────────────────────────────────────────────────────────────────────────
class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────────────────────────────────
// DIALOG HELPERS
// ──────────────────────────────────────────────────────────────────────────
Future<void> _confirmReceived(BuildContext context, DeliveryDetailsController c) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Mark as received?'),
      content: const Text('This will mark the delivery as received through the API.'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Confirm')),
      ],
    ),
  );
  if (ok == true) await c.markReceived();
}

Future<void> _partialReceived(BuildContext context, DeliveryDetailsController c) async {
  final item = DeliveryItem.fromJson(c.delivery);
  final leadId = item.leadId.isNotEmpty ? item.leadId : item.projectMongoId;
  final args = {
    'leadId': leadId,
    'projectId': item.jobId,
    'projectName': item.project,
    'location': item.location,
    'deliveryId': item.id,
    'deliveryMongoId': item.realMongoId,
    'initialStep': 2,
    'fromDeliveryTracking': true,
  };
  if (Get.isRegistered<DispatchVerificationController>()) {
    Get.find<DispatchVerificationController>().applyNavigationArguments(args);
  }
  Get.toNamed(AppRoutes.dispatchVerification, arguments: args);
}

Future<void> _updateContact(BuildContext context, DeliveryDetailsController c) async {
  final old = c.mapValue(['siteContact']);
  String val(List<String> k) => c.nestedValue(old, k, fallback: '');
  final name = TextEditingController(text: val(['contactName', 'name']));
  final title = TextEditingController(text: val(['contactTitle', 'title']));
  final phone = TextEditingController(text: val(['phone']));
  final email = TextEditingController(text: val(['email']));

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Update Site Contact'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Contact name')),
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Contact title')),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
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

String _formatDate(String raw, {String fallback = '-'}) {
  if (raw == '—' || raw == '-' || raw.isEmpty) return fallback;
  final parsed = DateTime.tryParse(raw);
  if (parsed != null) {
    return DateFormat('MMM d, yyyy').format(parsed.toLocal());
  }
  return raw;
}

String _formatTitle(String raw) {
  if (raw == '—' || raw.isEmpty) return '—';
  return raw
      .replaceAll('_', ' ')
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
      .join(' ');
}

class _DeliveryDetailsShimmer extends StatelessWidget {
  const _DeliveryDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = (size.width * 0.02).clamp(16.0, 24.0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Shimmer
          Row(
            children: const [
              AppShimmer(width: 80, height: 36, borderRadius: 8),
              SizedBox(width: 14),
              AppShimmer(width: 160, height: 26, borderRadius: 6),
              SizedBox(width: 10),
              AppShimmer(width: 90, height: 22, borderRadius: 12),
              Spacer(),
              AppShimmer(width: 120, height: 36, borderRadius: 8),
              SizedBox(width: 10),
              AppShimmer(width: 120, height: 36, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 20),

          // 2-Column Responsive Layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;

              const left = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DeliveryCardSkeleton(height: 100),
                  SizedBox(height: 16),
                  _DeliveryCardSkeleton(height: 220),
                  SizedBox(height: 16),
                  _DeliveryCardSkeleton(height: 180),
                  SizedBox(height: 16),
                  _DeliveryCardSkeleton(height: 190),
                ],
              );

              const right = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DeliveryCardSkeleton(height: 110),
                  SizedBox(height: 16),
                  _DeliveryCardSkeleton(height: 140),
                  SizedBox(height: 16),
                  _DeliveryCardSkeleton(height: 150),
                  SizedBox(height: 16),
                  _DeliveryCardSkeleton(height: 120),
                ],
              );

              if (!isWide) {
                return const Column(
                  children: [
                    left,
                    SizedBox(height: 16),
                    right,
                  ],
                );
              }

              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 68, child: left),
                  SizedBox(width: 16),
                  Expanded(flex: 32, child: right),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DeliveryCardSkeleton extends StatelessWidget {
  const _DeliveryCardSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppShimmer(width: 110, height: 14, borderRadius: 4),
              Spacer(),
              AppShimmer(width: 60, height: 16, borderRadius: 6),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: AppShimmer(
              width: double.infinity,
              borderRadius: 8,
            ),
          ),
        ],
      ),
    );
  }
}
