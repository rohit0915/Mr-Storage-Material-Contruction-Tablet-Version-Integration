import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_toast.dart';
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
  late final TextEditingController _departmentCtrl;

  final _requestedDate = DateTime.now();
  late String _project;
  String _site = 'Site A';
  String _priority = 'High';
  String _department = 'Framing';
  String _unit = 'pcs';
  DateTime? _requiredBy;

  // Validation Error States
  String? _requiredByError;
  String? _projectError;
  String? _materialNameError;
  String? _qtyError;

  // Submitting / Loading State
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<MaterialRequestsController>();
    final projects = controller.projects;
    _project =
        projects.firstWhereOrNull((name) => name != 'All Projects') ?? '';

    final departments = controller.departments;
    _department =
        departments.firstWhereOrNull((name) => name != 'All Departments') ??
        'Framing';

    _departmentCtrl = TextEditingController(text: _department);
  }

  @override
  void dispose() {
    _materialCtrl.dispose();
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    _departmentCtrl.dispose();
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
    setState(() {
      _requiredBy = picked;
      _requiredByError = null;
    });
  }

  bool _validate() {
    bool valid = true;
    String? reqError;
    String? projError;
    String? matError;
    String? qtyError;

    if (_requiredBy == null) {
      reqError = 'Please select a required by date';
      valid = false;
    }

    if (_project.trim().isEmpty || _project == 'All Projects') {
      projError = 'Please select a project';
      valid = false;
    }

    final name = _materialCtrl.text.trim();
    if (name.isEmpty) {
      matError = 'Please enter material name';
      valid = false;
    }

    final qtyStr = _qtyCtrl.text.trim();
    final qty = num.tryParse(qtyStr);
    if (qtyStr.isEmpty) {
      qtyError = 'Please enter quantity';
      valid = false;
    } else if (qty == null || qty <= 0) {
      qtyError = 'Quantity must be greater than 0';
      valid = false;
    }

    setState(() {
      _requiredByError = reqError;
      _projectError = projError;
      _materialNameError = matError;
      _qtyError = qtyError;
    });

    if (!valid) {
      AppToast.showError(
        title: 'Validation Error',
        description: 'Please fill in all required fields marked with *',
      );
    }

    return valid;
  }

  Future<void> _create() async {
    // Prevent multi-click while request is processing
    if (_isSubmitting) return;

    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final name = _materialCtrl.text.trim();
      final qty = num.parse(_qtyCtrl.text.trim());

      final controller = Get.find<MaterialRequestsController>();
      final now = DateTime.now();
      final id =
          'MR-${now.year}-${(now.millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';

      final deptText = _departmentCtrl.text.trim();

      final newReq = MaterialRequestBoardItem(
        id: id,
        project: _project,
        site: _site,
        department: deptText.isNotEmpty ? deptText : _department,
        requestedBy: 'Construction User',
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

      final success = await controller.addRequest(newReq);
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              const TaskSuccessDialog(title: 'Request Added Successfully'),
        );
      }
    } catch (e) {
      AppToast.showError(
        title: 'Error',
        description: 'Failed to create material request: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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

              // Row 1: Requested Date & Required By
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        _label('Required By', labelSize, isRequired: true),
                        const SizedBox(height: 6),
                        _dateTapField(
                          value: _requiredBy == null
                              ? 'DD-MM-YYYY'
                              : DateFormat('dd-MM-yyyy').format(_requiredBy!),
                          onTap: _pickRequiredBy,
                          errorText: _requiredByError,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Row 2: Project & Priority
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Project', labelSize, isRequired: true),
                        const SizedBox(height: 6),
                        _dropdown(
                          value: _project,
                          items: controller.projects
                              .where((name) => name != 'All Projects')
                              .toList(),
                          onChanged: (v) => setState(() {
                            _project = v;
                            _projectError = null;
                          }),
                          errorText: _projectError,
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

              // Row 3: Site Location & Department
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          controller: _departmentCtrl,
                          hint: 'e.g., Construction',
                          onChanged: (v) => _department = v,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Row 4: Material Name & Quantity
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Material Name', labelSize, isRequired: true),
                        const SizedBox(height: 6),
                        _textField(
                          controller: _materialCtrl,
                          hint: 'e.g., Steel Studs',
                          errorText: _materialNameError,
                          onChanged: (v) {
                            if (_materialNameError != null && v.trim().isNotEmpty) {
                              setState(() => _materialNameError = null);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Quantity', labelSize, isRequired: true),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _textField(
                                controller: _qtyCtrl,
                                hint: '100',
                                keyboard: TextInputType.number,
                                errorText: _qtyError,
                                onChanged: (v) {
                                  if (_qtyError != null &&
                                      (num.tryParse(v.trim()) ?? 0) > 0) {
                                    setState(() => _qtyError = null);
                                  }
                                },
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

              // Row 5: Notes
              _label('Notes', labelSize),
              const SizedBox(height: 6),
              _textField(
                controller: _notesCtrl,
                hint: 'Optional notes...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Actions: Cancel & Create (with loading spinner & debouncing)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
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
                    onPressed: _isSubmitting ? null : _create,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primaryBlue.withValues(alpha: 0.65),
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Creating...',
                                style: TextStyle(
                                  fontSize:
                                      (size.width * 0.010).clamp(12.0, 14.0),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Create',
                            style: TextStyle(
                              fontSize:
                                  (size.width * 0.010).clamp(12.0, 14.0),
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

  Widget _label(String text, double size, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  Widget _fieldError(String? error) {
    if (error == null || error.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 2),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 13,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(String val) {
    return Container(
      width: double.infinity,
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
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFD1D5DB),
                width: hasError ? 1.5 : 1.0,
              ),
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
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
        if (hasError) _fieldError(errorText),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFD1D5DB),
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFD1D5DB),
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFDC2626)
                    : AppColors.primaryBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError) _fieldError(errorText),
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    final safeItems = items.isEmpty ? [''] : items;
    final safeValue = safeItems.contains(value) ? value : safeItems.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFDC2626)
                  : const Color(0xFFD1D5DB),
              width: hasError ? 1.5 : 1.0,
            ),
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
        ),
        if (hasError) _fieldError(errorText),
      ],
    );
  }
}
