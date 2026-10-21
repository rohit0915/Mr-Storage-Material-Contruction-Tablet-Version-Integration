import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/project_details_controller.dart';
import 'workflow_success_dialog.dart';

class UpdateWorkflowDialog extends StatefulWidget {
  const UpdateWorkflowDialog({
    super.key,
    this.initialStepTitle,
    this.initialStatus,
    this.initialStartDate,
    this.initialEndDate,
  });

  final String? initialStepTitle;
  final String? initialStatus;
  final String? initialStartDate;
  final String? initialEndDate;

  static Future<void> show(
    BuildContext context, {
    String? initialStepTitle,
    String? initialStatus,
    String? initialStartDate,
    String? initialEndDate,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => UpdateWorkflowDialog(
        initialStepTitle: initialStepTitle,
        initialStatus: initialStatus,
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
      ),
    );
  }

  @override
  State<UpdateWorkflowDialog> createState() => _UpdateWorkflowDialogState();
}

class _UpdateWorkflowDialogState extends State<UpdateWorkflowDialog> {
  static const List<String> _defaultSteps = [
    'Site Preparation & Foundation',
    'Steel Structure Erection',
    'Secondary Framing Installation',
    'Roofing Installation',
    'Wall Cladding & Accessories',
    'Finishing & Quality Inspection',
    'Final Inspection & Handover',
  ];

  static const List<String> _statuses = [
    'Completed',
    'In Progress',
    'Pending',
    'Delayed',
  ];

  late List<String> _steps;
  late String _selectedStep;
  late String _selectedStatus;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _descController;
  final List<String> _selectedPhotos = [];

  @override
  void initState() {
    super.initState();
    final ctrl = Get.isRegistered<ProjectDetailsController>()
        ? Get.find<ProjectDetailsController>()
        : null;
    final dynamicSteps = ctrl?.workflowSteps.map((s) => s.title).toList() ?? [];
    _steps = dynamicSteps.isNotEmpty ? dynamicSteps : _defaultSteps;

    _selectedStep = widget.initialStepTitle ?? _steps[0];
    if (!_steps.contains(_selectedStep)) {
      _selectedStep = _steps[0];
    }

    _selectedStatus = widget.initialStatus ?? _statuses[0];
    if (!_statuses.contains(_selectedStatus)) {
      _selectedStatus = _statuses[0];
    }

    _startDateController = TextEditingController(
      text: widget.initialStartDate ?? '',
    );
    _endDateController = TextEditingController(
      text: widget.initialEndDate ?? '',
    );
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E5E9E),
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final formatted = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      setState(() {
        controller.text = formatted;
      });
    }
  }

  void _onUploadTapped() {
    setState(() {
      if (_selectedPhotos.length < 4) {
        _selectedPhotos.add(
          'assets/images/projects/project_${(_selectedPhotos.length % 6) + 1}.png',
        );
      }
    });
    Get.snackbar(
      'Photo Attached',
      'Sample construction photo added to step.',
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void _onSubmit() {
    if (Get.isRegistered<ProjectDetailsController>()) {
      final ctrl = Get.find<ProjectDetailsController>();
      final matching = ctrl.workflowSteps.firstWhereOrNull(
        (s) => s.title.toLowerCase().trim() == _selectedStep.toLowerCase().trim(),
      );
      ctrl.updateWorkflowStep(
        stepTitle: _selectedStep,
        stepKey: matching?.stepKey,
        status: _selectedStatus,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        description: _descController.text.isNotEmpty
            ? _descController.text
            : null,
        photos: _selectedPhotos.isNotEmpty ? _selectedPhotos : null,
      );
    }

    Navigator.of(context).pop();
    WorkflowSuccessDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width * 0.45).clamp(460.0, 560.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Update Workflow',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Row 1: Step Dropdown & Step Status Dropdown
              Row(
                children: [
                  // Step
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Step',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStep,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w500,
                              ),
                              items: _steps.map((step) {
                                return DropdownMenuItem<String>(
                                  value: step,
                                  child: Text(
                                    step,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStep = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Step Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Step Status',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w500,
                              ),
                              items: _statuses.map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStatus = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Row 2: Start Date & End Date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _pickDate(_startDateController),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _startDateController.text.isNotEmpty
                                        ? _startDateController.text
                                        : 'dd - mm - yyyy',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _startDateController.text.isNotEmpty
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _pickDate(_endDateController),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _endDateController.text.isNotEmpty
                                        ? _endDateController.text
                                        : 'dd - mm - yyyy',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _endDateController.text.isNotEmpty
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: Color(0xFF64748B),
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
              const SizedBox(height: 16),

              // Work Description
              const Text(
                'Work Description',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: TextField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  decoration: const InputDecoration(
                    hintText: 'Describe the work completed today...',
                    hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Upload Photos
              const Text(
                'Upload Photos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _onUploadTapped,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          size: 26,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Click to upload photos or drag and drop',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'PNG,JPG up to 10MB each',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_selectedPhotos.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedPhotos.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          _selectedPhotos[i],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Actions Row: Cancel & Update
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF475569),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
}
