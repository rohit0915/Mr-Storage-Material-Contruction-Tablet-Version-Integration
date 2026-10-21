import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/utils/app_toast.dart';
import '../../drawings/services/drawings_service.dart';
import '../controllers/project_details_controller.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key, this.leadId = ''});

  final String leadId;

  static Future<void> show(BuildContext context, {String leadId = ''}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AddTaskDialog(leadId: leadId),
    );
  }

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _stepController = TextEditingController(text: 'Site Preparation & Foundation');
  final _startDateController = TextEditingController();
  final _estEndDateController = TextEditingController();
  final _workDescController = TextEditingController();

  DateTime? _startDate;
  DateTime? _estEndDate;
  bool _isSubmitting = false;
  final List<PlatformFile> _selectedFiles = [];

  final List<String> _commonSteps = const [
    'Site Preparation & Foundation',
    'Steel Structure Erection',
    'Secondary Framing Installation',
    'Roofing Installation',
    'Wall Cladding & Accessories',
    'Finishing & Quality Inspection',
    'Final Inspection & Handover',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now;
    _estEndDate = now.add(const Duration(days: 5));
    _startDateController.text = _formatDate(now);
    _estEndDateController.text = _formatDate(_estEndDate!);
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatIso(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')} - ${dt.month.toString().padLeft(2, '0')} - ${dt.year}';
  }

  @override
  void dispose() {
    _stepController.dispose();
    _startDateController.dispose();
    _estEndDateController.dispose();
    _workDescController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_estEndDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = _formatIso(picked);
        } else {
          _estEndDate = picked;
          _estEndDateController.text = _formatIso(picked);
        }
      });
    }
  }

  Future<void> _pickPhotos() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      );
      if (result.isNotEmpty) {
        setState(() {
          for (final f in result) {
            if (!_selectedFiles.any((existing) => existing.name == f.name)) {
              _selectedFiles.add(f);
            }
          }
        });
      }
    } catch (e) {
      AppToast.showError(
        title: 'File Picker Error',
        description: 'Failed to pick photos: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width * 0.46).clamp(420.0, 560.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              const Text(
                'Add Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 18),

              // Step Field
              const Text(
                'Step',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _stepController,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Select or enter step...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: Color(0xFF64748B), size: 20),
                      onSelected: (val) {
                        setState(() {
                          _stepController.text = val;
                        });
                      },
                      itemBuilder: (context) => _commonSteps
                          .map((s) => PopupMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dates Row (Start Date & EST End Date)
              Row(
                children: [
                  // Start Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Date',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _pickDate(isStart: true),
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
                                    _startDate != null ? _formatIso(_startDate!) : 'dd - mm - yyyy',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _startDate != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // EST End Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EST End Date',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _pickDate(isStart: false),
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
                                    _estEndDate != null ? _formatIso(_estEndDate!) : 'dd - mm - yyyy',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _estEndDate != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
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
                  controller: _workDescController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Describe the work planned or completed...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Upload Photos Dropzone
              const Text(
                'Upload Photos',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickPhotos,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 26,
                        color: Color(0xFF64748B),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Click to upload photos or drag and drop',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'PNG, JPG up to 10MB each',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Show selected files chips
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (int i = 0; i < _selectedFiles.length; i++)
                      Chip(
                        label: Text(
                          _selectedFiles[i].name,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() {
                            _selectedFiles.removeAt(i);
                          });
                        },
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 22),

              // Action Buttons (Cancel and Add)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: const Color(0xFF334155),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                final title = _stepController.text.trim();
                                if (title.isEmpty) {
                                  AppToast.showError(
                                    title: 'Required',
                                    description: 'Please specify a step/task name.',
                                  );
                                  return;
                                }
                                setState(() => _isSubmitting = true);
                                try {
                                  final controller = Get.find<ProjectDetailsController>();
                                  final effectiveLeadId = widget.leadId.isNotEmpty
                                      ? widget.leadId
                                      : controller.leadId.value;

                                  // Upload photos if any
                                  final photoUrls = <String>[];
                                  if (_selectedFiles.isNotEmpty && effectiveLeadId.isNotEmpty) {
                                    final drawingsService = Get.isRegistered<DrawingsService>()
                                        ? Get.find<DrawingsService>()
                                        : Get.put(DrawingsService());

                                    for (final file in _selectedFiles) {
                                      final bytes = await file.readAsBytes();
                                      final ext = (file.extension ?? '').toLowerCase();
                                      final mime = ext == 'png'
                                          ? 'image/png'
                                          : (ext == 'webp' ? 'image/webp' : 'image/jpeg');
                                      final url = await drawingsService.uploadMediaAndGetUrl(
                                        leadId: effectiveLeadId,
                                        fileName: file.name,
                                        mimeType: mime,
                                        bytes: bytes,
                                      );
                                      if (url != null && url.isNotEmpty) {
                                        photoUrls.add(url);
                                      }
                                    }
                                  }

                                  final success = await controller.createTimelineTask(
                                    title: title,
                                    startDate: _startDate,
                                    estimatedEndDate: _estEndDate,
                                    description: _workDescController.text.trim(),
                                    attachments: photoUrls,
                                    status: 'in_progress',
                                  );

                                  if (!mounted) return;
                                  if (success) {
                                    Get.back();
                                    AppToast.showSuccess(
                                      title: 'Task Added',
                                      description: 'New construction task added successfully.',
                                    );
                                  } else {
                                    AppToast.showError(
                                      title: 'Failed',
                                      description: 'Could not create task on server.',
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    AppToast.showError(
                                      title: 'Error',
                                      description: 'Error adding task: $e',
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _isSubmitting = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
}

