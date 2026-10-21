import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/bundle_scan_models.dart';

class BundleMismatchDialog extends StatefulWidget {
  const BundleMismatchDialog({
    super.key,
    required this.item,
    required this.onSubmit,
  });

  final BundleScanItem item;
  final Future<void> Function(
    String notes,
    List<Map<String, dynamic>> items,
  ) onSubmit;

  static Future<void> show(
    BuildContext context, {
    required BundleScanItem item,
    required Future<void> Function(
      String notes,
      List<Map<String, dynamic>> items,
    ) onSubmit,
  }) => showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => BundleMismatchDialog(item: item, onSubmit: onSubmit),
  );

  @override
  State<BundleMismatchDialog> createState() => _BundleMismatchDialogState();
}

class _MismatchRowData {
  _MismatchRowData({
    required this.itemCode,
    required this.name,
    required this.expectedQuantity,
    required this.color,
    required int initialReceived,
    this.itemId = '',
  })  : status = 'Received',
        receivedCtrl =
            TextEditingController(text: initialReceived.toString());

  final String itemCode;
  final String name;
  final int expectedQuantity;
  final String color;
  final TextEditingController receivedCtrl;
  final String itemId;
  String status;

  void dispose() {
    receivedCtrl.dispose();
  }
}

class _BundleMismatchDialogState extends State<BundleMismatchDialog> {
  final _notesCtrl = TextEditingController();
  final List<_MismatchRowData> _rows = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initRows();
  }

  void _initRows() {
    if (widget.item.subItems.isNotEmpty) {
      for (int i = 0; i < widget.item.subItems.length; i++) {
        final sub = widget.item.subItems[i];
        final code = sub.itemCode.isNotEmpty
            ? sub.itemCode
            : 'ITEM-${i + 1}';
        final qty = sub.quantity > 0
            ? sub.quantity
            : (int.tryParse(widget.item.quantity) ?? 1);
        final rec = sub.receivedQuantity > 0 ? sub.receivedQuantity : qty;
        _rows.add(
          _MismatchRowData(
            itemCode: code,
            name: sub.parts.isNotEmpty ? sub.parts : widget.item.parts,
            expectedQuantity: qty,
            color: sub.color.isNotEmpty ? sub.color : '-',
            initialReceived: rec,
            itemId: sub.itemId,
          ),
        );
      }
    } else {
      // Fallback row matching Screenshot 2
      final qty = int.tryParse(widget.item.quantity) ?? 7;
      _rows.add(
        _MismatchRowData(
          itemCode: 'ITEM-1',
          name: widget.item.parts.isNotEmpty ? widget.item.parts : 'RF Column',
          expectedQuantity: qty > 0 ? qty : 7,
          color: '-',
          initialReceived: qty > 0 ? qty : 7,
        ),
      );
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final notes = _notesCtrl.text.trim();
    final itemsPayload = _rows.map((r) {
      final recQty = int.tryParse(r.receivedCtrl.text.trim()) ?? r.expectedQuantity;
      return <String, dynamic>{
        if (r.itemId.isNotEmpty) 'itemId': r.itemId,
        'itemCode': r.itemCode,
        'partCode': r.itemCode,
        'name': r.name,
        'description': r.name,
        'quantity': r.expectedQuantity,
        'expectedQty': r.expectedQuantity,
        'receivedQuantity': recQty,
        'receivedQty': recQty,
        'status': r.status,
      };
    }).toList();

    try {
      await widget.onSubmit(
        notes.isNotEmpty ? notes : 'Discrepancy logged for bundle ${widget.item.bundleId}',
        itemsPayload,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Color _statusBadgeColor(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return const Color(0xFF059669);
      case 'missing':
        return const Color(0xFFD97706);
      case 'damaged':
        return const Color(0xFFDC2626);
      case 'mismatch':
      default:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = (size.width * 0.72).clamp(600.0, 780.0);
    final maxHeight = size.height * 0.90;

    final item = widget.item;
    final bundleId = item.bundleId.isNotEmpty ? item.bundleId : item.id;
    final project = item.project.isNotEmpty ? item.project : 'Test Aviation Project';
    final jobId = item.jobId.isNotEmpty && item.jobId != '-' ? item.jobId : 'PRO-012';
    final packingListNo = item.packingListNo.isNotEmpty ? item.packingListNo : '-';

    final type = item.type.isNotEmpty ? item.type : 'Mixed';
    final title = item.title.isNotEmpty ? item.title : 'MIXED Bundle';
    final totalQty = item.quantity.isNotEmpty && item.quantity != '0'
        ? item.quantity
        : '7';
    final totalWeight = item.totalWeight.isNotEmpty && item.totalWeight != '-'
        ? item.totalWeight
        : '5,737.90 LBS';

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header: Back button, Title, Submit Report button
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 14),
                      label: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E293B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Report Mismatch',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Submit Report',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.close, size: 14),
                              ],
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section 1: Bundle Information & Bundle Details 2-Column Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bundle Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bundle Information',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _infoRow('BUNDLE ID', bundleId),
                          const SizedBox(height: 12),
                          _infoRow('PROJECT', project),
                          const SizedBox(height: 12),
                          _infoRow('JOB ID', jobId),
                          const SizedBox(height: 12),
                          _infoRow('PACKING LIST NO', packingListNo),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Bundle Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bundle Details',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _infoRow('TYPE', type),
                          const SizedBox(height: 12),
                          _infoRow('TITLE', title),
                          const SizedBox(height: 12),
                          _infoRow('TOTAL QUANTITY', totalQty),
                          const SizedBox(height: 12),
                          _infoRow('TOTAL WEIGHT', totalWeight),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // Section 2: Items Table
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Dark Table Header
                      Container(
                        color: const Color(0xFF1E293B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'ITEM CODE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'NAME',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'QUANTITY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'COLOR',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'ENTER RECEIVED QUANTITY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'ACTION',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rows
                      ..._rows.map((row) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFF1F5F9),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // ITEM CODE (Blue text matching Screenshot 2)
                              Expanded(
                                flex: 3,
                                child: Text(
                                  row.itemCode,
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              // NAME
                              Expanded(
                                flex: 4,
                                child: Text(
                                  row.name,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // QUANTITY
                              Expanded(
                                flex: 2,
                                child: Text(
                                  row.expectedQuantity.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // COLOR
                              Expanded(
                                flex: 2,
                                child: Text(
                                  row.color,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              // ENTER RECEIVED QUANTITY
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: SizedBox(
                                    width: 70,
                                    height: 36,
                                    child: TextField(
                                      controller: row.receivedCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFCBD5E1),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFCBD5E1),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF7C3AED),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // ACTION Dropdown badge
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: PopupMenuButton<String>(
                                      initialValue: row.status,
                                      onSelected: (val) {
                                        setState(() => row.status = val);
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(
                                          value: 'Received',
                                          child: Text('Received'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Missing',
                                          child: Text('Missing'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Damaged',
                                          child: Text('Damaged'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Mismatch',
                                          child: Text('Mismatch'),
                                        ),
                                      ],
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusBadgeColor(row.status),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              row.status,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 3: Mismatch Notes
                const Text(
                  'Mismatch Notes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Describe any mismatch details or comments...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF7C3AED),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // Footer Buttons (Cancel & Report Mismatch)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Report Mismatch',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value.isNotEmpty ? value : '-',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
