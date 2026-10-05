import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_logger.dart';
import '../models/work_log_model.dart';
import '../services/work_logs_service.dart';

class CreateWorkLogDialog extends StatefulWidget {
  const CreateWorkLogDialog({
    super.key,
    required this.projects,
    required this.tasks,
    this.initialProject = 'Storage 0011',
  });

  final List<Map<String, String>> projects;
  final List<Map<String, String>> tasks;
  final String initialProject;

  static Future<WorkLogItem?> show(
    BuildContext context, {
    required List<Map<String, String>> projects,
    required List<Map<String, String>> tasks,
    String initialProject = 'Storage 0011',
  }) {
    return showDialog<WorkLogItem>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateWorkLogDialog(
        projects: projects,
        tasks: tasks,
        initialProject: initialProject,
      ),
    );
  }

  @override
  State<CreateWorkLogDialog> createState() => _CreateWorkLogDialogState();
}

class _CreateWorkLogDialogState extends State<CreateWorkLogDialog> {
  late DateTime _selectedDate;
  late String _selectedProject;
  late String _selectedTask;
  final _progressCtrl = TextEditingController(text: '0');
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<String> _photos = [];

  List<Map<String, String>> get _effectiveProjects {
    final list = <Map<String, String>>[...widget.projects];
    if (list.isEmpty) {
      list.addAll(WorkLogsService.defaultProjectsList());
    }
    // Ensure all 4 core projects exist
    for (final def in WorkLogsService.defaultProjectsList()) {
      if (!list.any((p) => p['name'] == def['name'])) {
        list.add(def);
      }
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    final projects = _effectiveProjects;
    final pNames = projects
        .map((p) => p['name'] ?? '')
        .where((p) => p.isNotEmpty)
        .toList();
    if (pNames.contains(widget.initialProject)) {
      _selectedProject = widget.initialProject;
    } else if (pNames.isNotEmpty) {
      _selectedProject = pNames.first;
    } else {
      _selectedProject = 'Storage 0011';
    }

    _selectedTask = 'None / General Work';
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
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
            if (f.name.isNotEmpty && !_photos.contains(f.name)) {
              _photos.add(f.name);
            }
          }
        });
      }
    } catch (e) {
      AppLogger.w('Photo pick error or cancelled: $e', tag: 'WORK_LOG_PHOTO');
    }
  }

  void _submit() {
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) {
      Get.snackbar(
        'Description required',
        'Please describe the work completed today.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }

    final prog =
        int.tryParse(_progressCtrl.text.replaceAll('%', '').trim()) ?? 0;
    final leadItem = _effectiveProjects.firstWhere(
      (p) => p['name'] == _selectedProject,
      orElse: () => {
        'id': 'lead-0011',
        'name': _selectedProject,
        'jobId': '2026014',
      },
    );

    final item = WorkLogItem(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      leadId: leadItem['id'] ?? 'lead-0011',
      projectName: _selectedProject,
      jobId: leadItem['jobId'] ?? '2026014',
      taskId: _selectedTask == 'None / General Work' ? '' : _selectedTask,
      taskTitle: _selectedTask,
      date: _selectedDate,
      progress: prog.clamp(0, 100),
      workDescription: desc,
      photos: _photos,
      issues: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : '—',
      loggedByName: 'Construction User',
      loggedByEmail: 'construction1@example.com',
    );

    Get.back(result: item);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width * 0.55).clamp(500.0, 640.0);

    final projects = _effectiveProjects;
    final projectNames = projects
        .map((p) => p['name'] ?? '')
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();

    final displayMap = <String, String>{};
    for (final p in projects) {
      final name = p['name'] ?? '';
      if (name.isNotEmpty) {
        displayMap[name] = p['displayName'] ?? name;
      }
    }

    final taskOptions = <String>['None / General Work'];
    for (final t in widget.tasks) {
      final title = t['title'] ?? '';
      if (title.isNotEmpty && !taskOptions.contains(title)) {
        taskOptions.add(title);
      }
    }

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Daily Work Log',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),

              // Row 1: Date & Project
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Date'),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Project
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Project'),
                        const SizedBox(height: 6),
                        _dropdownField(
                          value: _selectedProject,
                          items: projectNames,
                          displayMap: displayMap,
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedProject = v);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Row 2: Task & Progress (%)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Task'),
                        const SizedBox(height: 6),
                        _dropdownField(
                          value: _selectedTask,
                          items: taskOptions,
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedTask = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Progress (%)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Progress (%)'),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _progressCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1E293B),
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryBlue,
                                ),
                              ),
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
              _fieldLabel('Work Description'),
              const SizedBox(height: 6),
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Describe the work completed today...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Upload Photos Dropzone (Real FilePicker)
              _fieldLabel('Upload Photos'),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickPhotos,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      style: BorderStyle.solid,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF8FAFC),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 28,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Click to upload photos or drag and drop',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'PNG, JPG, WEBP up to 10MB each (multiple supported)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      if (_photos.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _photos
                              .map(
                                (p) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.image_outlined,
                                        size: 16,
                                        color: Color(0xFF2563EB),
                                      ),
                                      const SizedBox(width: 6),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 160,
                                        ),
                                        child: Text(
                                          p,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () {
                                          setState(() => _photos.remove(p));
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Issues/Notes
              _fieldLabel('Issues/Notes'),
              const SizedBox(height: 6),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Any issues, delays, or important notes...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bottom Buttons: Cancel & Create
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E293B),
                      backgroundColor: const Color(0xFFF1F5F9),
                      side: BorderSide.none,
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
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Create',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
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

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    Map<String, String>? displayMap,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : null);

    return SizedBox(
      height: 44,
      child: DropdownButtonFormField<String>(
        key: ValueKey(validValue),
        initialValue: validValue,
        isExpanded: true,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryBlue),
          ),
        ),
        hint: const Text('Select Project'),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  displayMap?[e] ?? e,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
