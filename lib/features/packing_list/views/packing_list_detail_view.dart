import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_toast.dart';
import '../models/packing_list_models.dart';
import '../controllers/packing_list_controller.dart';
import '../widgets/packing_list_dialogs.dart';

class PackingListDetailView extends StatefulWidget {
  const PackingListDetailView({super.key});

  @override
  State<PackingListDetailView> createState() => _PackingListDetailViewState();
}

class _PackingListDetailViewState extends State<PackingListDetailView> {
  final _bundleListItems = <(String, String, String, String, String, String, String)>[];
  bool _isLoading = true;
  int _totalItems = 0;
  int _totalBundles = 0;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final item = Get.arguments as PackingListItem?;
    if (item == null) {
      setState(() => _isLoading = false);
      return;
    }
    final controller = Get.find<PackingListController>();
    final data = await controller.getPackingListDetail(item.id);
    if (data != null && mounted) {
      setState(() {
        
        List<dynamic> rawBundles = [];
        final Map target = data.containsKey('packingList') ? data['packingList'] : data;
        
        if (target['bundles'] is List) {
          rawBundles = target['bundles'] as List;
        } else if (target['items'] is List) {
          rawBundles = target['items'] as List;
        } else if (target['bundleItems'] is List) {
          rawBundles = target['bundleItems'] as List;
        } else if (data['bundles'] is List) {
          rawBundles = data['bundles'] as List;
        } else if (data['items'] is List) {
          rawBundles = data['items'] as List;
        }

        _totalItems = (data['totalItems'] ?? data['itemsCount'] ?? rawBundles.length) is num
            ? ((data['totalItems'] ?? data['itemsCount'] ?? rawBundles.length) as num).toInt()
            : rawBundles.length;
            
        _totalBundles = (data['totalBundles'] ?? rawBundles.length) is num
            ? ((data['totalBundles'] ?? rawBundles.length) as num).toInt()
            : rawBundles.length;

        _bundleListItems.clear();
        for (int i = 0; i < rawBundles.length; i++) {
          if (rawBundles[i] is! Map) continue;
          final b = rawBundles[i] as Map;
          
          final idx = (i + 1).toString();
          final bundleId = (b['bundleId'] ?? b['tag'] ?? b['code'] ?? 'B-${idx.padLeft(3, '0')}').toString();
          
          final partCode = (b['partCode'] ?? b['partNumber'] ?? '').toString();
          final desc = (b['description'] ?? b['part'] ?? b['name'] ?? '').toString();
          final partStr = [partCode, desc].where((s) => s.isNotEmpty).join(' - ');
          
          final qty = (b['quantity'] ?? b['qty'] ?? 1).toString();
          
          String length = (b['length'] ?? b['len'] ?? '-').toString();
          if (length != '-' && !length.toLowerCase().contains('ft')) length += ' ft';
          
          String weight = (b['weight'] ?? b['totalWeight'] ?? b['totalWeightLbs'] ?? '-').toString();
          if (weight != '-' && !weight.toLowerCase().contains('lbs')) weight += ' LBS';
          
          final markIds = (b['markIds'] ?? b['status'] ?? b['markId'] ?? '-').toString();
          
          _bundleListItems.add((idx, bundleId, partStr.isEmpty ? '-' : partStr, qty, length, weight, markIds));
        }
        
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as PackingListItem?;
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;

    final controller = Get.find<PackingListController>();

    final pklId = item?.packingListId ?? '—';
    final jobId = item?.jobId.isNotEmpty == true ? item!.jobId : '—';
    final project = item?.project.isNotEmpty == true ? item!.project : '—';
    final truck = item?.truck.isNotEmpty == true ? item!.truck : '—';
    final destination = item?.destination.isNotEmpty == true
        ? item!.destination
        : '—';
    final statusStr = item?.statusText.isNotEmpty == true
        ? item!.statusText
        : '—';
    final weightStr = item?.totalWeight.isNotEmpty == true
        ? item!.totalWeight
        : '—';

    return AppScaffold(
      menuTitle: 'Packing List',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          padH,
          size.height * 0.014,
          padH,
          size.height * 0.02,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Bar
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.end,
                      children: [
                        _ActionBtn(
                          label: 'DOWNLOAD PDF',
                          onTap: item == null
                              ? null
                              : () async {
                                  final url = await controller.downloadPdf(
                                    item.realMongoId.isNotEmpty ? item.realMongoId : item.id,
                                  );
                                  if (url != null) {
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  }
                                  if (context.mounted) {
                                    await PackingListSuccessDialog.show(
                                      context,
                                      'Packing List\nDownloaded',
                                    );
                                  }
                                },
                        ),
                        _ActionBtn(
                          label: 'PRINT PACKING LIST',
                          onTap: item == null
                              ? null
                              : () async {
                                  final url = await controller.downloadPdf(
                                    item.realMongoId.isNotEmpty ? item.realMongoId : item.id,
                                  );
                                  if (url != null) {
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  }
                                  if (context.mounted) {
                                    AppToast.showSuccess(
                                      title: 'Printed',
                                      description: 'Packing List sent to printer',
                                    );
                                  }
                                },
                        ),
                        _ActionBtn(
                          label: 'EXPORT EXCEL',
                          onTap: () async {
                            final url = await controller.exportExcel();
                            if (url != null) {
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            }
                            if (context.mounted) {
                              await PackingListSuccessDialog.show(
                                context,
                                'Exported Excel\nsuccessfully',
                              );
                            }
                          },
                        ),
                        _ActionBtn(
                          label: 'MARK READY',
                          onTap: item == null
                              ? null
                              : () async {
                                  final success = await controller
                                      .markReadyForDispatch(item.id);
                                  if (success && context.mounted) {
                                    await PackingListSuccessDialog.show(
                                      context,
                                      'Marked Ready\nsuccessfully',
                                    );
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Load Information & Packing Summary / Loading Verification Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Load Information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Load Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _infoRow('PACKING LIST ID', pklId),
                        _infoRow('JOB ID', jobId),
                        _infoRow('PROJECT', project),
                        _infoRow('TRUCK', truck),
                        _infoRow('DESTINATION', destination),
                        _infoRow('STATUS', statusStr),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),

                  // Right Column: Packing Summary & Loading Verification
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Packing Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _summaryRow('TOTAL BUNDLES', '$_totalBundles'),
                        _summaryRow('TOTAL ITEMS', '$_totalItems'),
                        _summaryRow('TOTAL WEIGHT', weightStr),
                        const SizedBox(height: 20),
                        const Text(
                          'Loading Verification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _CheckRow(label: 'All Bundles Present'),
                        const _CheckRow(label: 'QR Labels Verified'),
                        const _CheckRow(label: 'Packing List Matches Load'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Bundle List Table Section
              const Text(
                'Bundle List',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_bundleListItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No bundles found for this packing list.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                    // Dark Header
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A1A2E),
                        border: Border(bottom: BorderSide(color: Color(0xFF334155), width: 1.5)),
                      ),
                      child: Row(
                        children: [
                          _buildTh('#', 1),
                          _buildTh('BUNDLE ID', 3),
                          _buildTh('PART CODE / DESCRIPTION', 4),
                          _buildTh('QUANTITY', 2),
                          _buildTh('LENGTH', 2),
                          _buildTh('WEIGHT', 3),
                          _buildTh('MARK IDS / STATUS', 3, isLast: true),
                        ],
                      ),
                    ),
                    // Data Rows
                    ..._bundleListItems.map(
                      (r) => Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.cardBorder),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildTd(
                              Text(
                                r.$1,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              1,
                            ),
                            _buildTd(
                              Text(
                                r.$2,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              3,
                            ),
                            _buildTd(
                              Text(
                                r.$3,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              4,
                            ),
                            _buildTd(
                              Text(
                                r.$4,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              2,
                            ),
                            _buildTd(
                              Text(
                                r.$5,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              2,
                            ),
                            _buildTd(
                              Text(
                                r.$6,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              3,
                            ),
                            _buildTd(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  r.$7,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                              3,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTh(String text, int flex, {bool isLast = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  right: BorderSide(
                    color: Color(0xFF334155),
                    width: 1.0,
                  ),
                ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static Widget _buildTd(Widget child, int flex, {bool isLast = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  right: BorderSide(
                    color: AppColors.cardBorder,
                    width: 1.0,
                  ),
                ),
        ),
        child: child,
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
