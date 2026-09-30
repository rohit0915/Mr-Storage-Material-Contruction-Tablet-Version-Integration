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

  final _requestedDate = DateTime.now();
  late String _project;
  String _site = 'Site A';
  String _priority = 'High';
  DateTime? _requiredBy;

  @override
  void initState() {
    super.initState();
    final projects = Get.find<MaterialRequestsController>().projects;
    _project =
        projects.firstWhereOrNull((name) => name != 'All Projects') ?? '';
  }

  @override
  void dispose() {
    _materialCtrl.dispose();
    _qtyCtrl.dispose();
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
      department: 'Construction',
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
          unit: 'units',
          quantity: qty,
          remarks: '-',
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

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: size.height * 0.82,
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
              _label('Requested Date (Auto-fill)', labelSize),
              const SizedBox(height: 6),
              _readOnlyField(reqDateStr),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Required By', labelSize),
                        const SizedBox(height: 6),
                        _dateTapField(
                          value: _requiredBy == null
                              ? 'dd - mm - yyyy'
                              : DateFormat(
                                  'dd - MM - yyyy',
                                ).format(_requiredBy!),
                          onTap: _pickRequiredBy,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Project', labelSize),
                        const SizedBox(height: 6),
                        _dropdown(
                          value: _project,
                          items: Get.find<MaterialRequestsController>().projects
                              .where((name) => name != 'All Projects')
                              .toList(),
                          onChanged: (v) => setState(() => _project = v),
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
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Site', labelSize),
                        const SizedBox(height: 6),
                        _dropdown(
                          value: _site,
                          items: const ['Site A', 'Site B', 'Site C'],
                          onChanged: (v) => setState(() => _site = v),
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
                          hint: 'e.g., Steel Beams',
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
                        _textField(
                          controller: _qtyCtrl,
                          hint: 'e.g., 50 units',
                          keyboard: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
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
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _create,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Create',
                      style: TextStyle(fontWeight: FontWeight.w700),
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

  Widget _label(String text, double size) => Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      fontSize: size,
    ),
  );

  Widget _readOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _dateTapField({required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: value.contains('dd')
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        onChanged(v);
      },
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
    );
  }
}
