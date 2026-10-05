import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../tasks/widgets/task_calendar_dialog.dart';
import '../../tasks/widgets/task_success_dialog.dart';
import '../controllers/material_requests_controller.dart';
import '../models/material_request_models.dart';

class AddMaterialRequestDialog extends StatefulWidget {
  const AddMaterialRequestDialog({super.key});

  @override
  State<AddMaterialRequestDialog> createState() =>
      _AddMaterialRequestDialogState();
}

class _AddMaterialRequestDialogState extends State<AddMaterialRequestDialog> {
  final _materialCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final _requestedDate = DateTime.now();
  late String _project;
  String _site = 'Site A';
  String _priority = 'High';
  String _department = 'Framing';
  String _unit = 'pcs';
  DateTime? _requiredBy;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<MaterialRequestsController>();
    final projects = controller.projects;
    _project =
        projects.firstWhereOrNull((name) => name != 'All Projects') ?? '';
        
    final departments = controller.departments;
    _department = 
        departments.firstWhereOrNull((name) => name != 'All Departments') ?? 'Framing';
  }

  @override
  void dispose() {
    _materialCtrl.dispose();
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickRequiredBy() async {
    final picked = await pickTaskDate(
      context,
      initialDate: _requiredBy ?? DateTime.now(),
      title: 'Calendar',
      confirmLabel: 'Done',
    );
    if (picked == null) return;
    setState(() => _requiredBy = picked);
  }

  Future<void> _create() async {
    if (_requiredBy == null) return;
    final name = _materialCtrl.text.trim();
    final qty = num.tryParse(_qtyCtrl.text.trim());
    if (name.isEmpty || qty == null) return;

    final controller = Get.find<MaterialRequestsController>();
    final now = DateTime.now();
    final id =
        'MR-${now.year}-${(now.millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';

    final newReq = MaterialRequestBoardItem(
      id: id,
      project: _project,
      site: _site,
      department: _department,
      requestedBy: 'John Smith',
      requestDate: now,
      requiredBy: _requiredBy!,
      requestedItemsCount: 1,
      itemsPreview: '$name...',
      status: MaterialRequestStatus.pending,
      priority: _priority,
      statusColor: const Color(0xFFFFC107),
      priorityColor: _priority == 'High'
          ? const Color(0xFFBE185D)
          : _priority == 'Medium'
          ? const Color(0xFFD97706)
          : const Color(0xFF2563EB),
      items: [
        MaterialRequestItemRow(
          name: name,
          unit: _unit,
          quantity: qty,
          remarks: _notesCtrl.text.trim(),
        ),
      ],
    );

    await controller.addRequest(newReq);
    if (!mounted) return;

    Navigator.of(context).pop();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const TaskSuccessDialog(title: 'Request Added Successfully'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width * 0.55).clamp(560.0, 680.0);
    final labelSize = (size.width * 0.010).clamp(12.0, 13.0);
    final reqDateStr = DateFormat('dd-MM-yyyy').format(_requestedDate);

    final controller = Get.find<MaterialRequestsController>();

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Request Material',
                style: TextStyle(
                  fontSize: (size.width * 0.014).clamp(16.0, 18.0),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Requested Date (Auto-fill)', labelSize),
                        const SizedBox(height: 6),
                        _readOnlyField(reqDateStr),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Required By', labelSize),
                        const SizedBox(height: 6),
                        _dateTapField(
                          value: _requiredBy == null
                              ? 'DD-MM-YYYY'
                              : DateFormat('dd-MM-yyyy').format(_requiredBy!),
                          onTap: _pickRequiredBy,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Project', labelSize),
                        const SizedBox(height: 6),
                        _dropdown(
                          value: _project,
                          items: controller.projects
                              .where((name) => name != 'All Projects')
                              .toList(),
                          onChanged: (v) => setState(() => _project = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Select Priority', labelSize),
                        const SizedBox(height: 6),
                        _dropdown(
                          value: _priority,
                          items: const ['High', 'Medium', 'Low'],
                          onChanged: (v) => setState(() => _priority = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Site Location', labelSize),
                        const SizedBox(height: 6),
                        _dropdown(
                          value: _site,
                          items: const ['Construction Site A', 'Site B', 'Site C'],
                          onChanged: (v) => setState(() => _site = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Department', labelSize),
                        const SizedBox(height: 6),
                        _textField(
                          controller: TextEditingController(text: _department),
                          hint: 'e.g., Framing',
                          onChanged: (v) => _department = v,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Material Name', labelSize),
                        const SizedBox(height: 6),
                        _textField(
                          controller: _materialCtrl,
                          hint: 'e.g., Steel Studs',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Quantity', labelSize),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _textField(
                                controller: _qtyCtrl,
                                hint: '100',
                                keyboard: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: _dropdown(
                                value: _unit,
                                items: const ['pcs', 'tons', 'kg', 'units'],
                                onChanged: (v) => setState(() => _unit = v),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _label('Notes', labelSize),
              const SizedBox(height: 6),
              _textField(
                controller: _notesCtrl,
                hint: 'Optional notes...',
                maxLines: 3,
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: const Color(0xFFF3F4F6),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: (size.width * 0.010).clamp(12.0, 14.0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _create,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Create',
                      style: TextStyle(
                        fontSize: (size.width * 0.010).clamp(12.0, 14.0),
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
    );
  }

  Widget _label(String text, double size) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _readOnlyField(String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        val,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _dateTapField({
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: value.startsWith('DD')
                    ? const Color(0xFF9CA3AF)
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    // If the list is empty or the selected value is not in the list, fallback gracefully.
    final safeItems = items.isEmpty ? [''] : items;
    final safeValue = safeItems.contains(value) ? value : safeItems.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF6B7280),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: safeItems.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item.isEmpty ? 'Select...' : item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
