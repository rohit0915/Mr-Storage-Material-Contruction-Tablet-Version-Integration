import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../models/task_models.dart';
import 'task_calendar_dialog.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({
    super.key,
    required this.projects,
    this.assignees = const [],
  });

  final List<TaskProjectOption> projects;
  final List<String> assignees;

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late String _selectedProjectId;
  late String _assignee;
  DateTime? _deadline;
  String _priority = 'High';
  String _status = 'To Do';

  @override
  void initState() {
    super.initState();
    _selectedProjectId =
        widget.projects.isNotEmpty ? widget.projects.first.id : 'lead-0011';

    final assigneeList = widget.assignees.isNotEmpty
        ? widget.assignees
        : TaskStaticData.assignees;
    if (assigneeList.contains('Mike Johnson')) {
      _assignee = 'Mike Johnson';
    } else if (assigneeList.isNotEmpty) {
      _assignee = assigneeList.first;
    } else {
      _assignee = 'Unassigned';
    }

    _deadline = DateTime.now();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await pickTaskDate(
      context,
      initialDate: _deadline ?? DateTime.now(),
      title: 'New Task',
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _create() {
    final column = switch (_status) {
      'In Progress' => TaskColumn.inProgress,
      'Done' => TaskColumn.done,
      _ => TaskColumn.todo,
    };

    final selProject = widget.projects.firstWhere(
      (p) => p.id == _selectedProjectId,
      orElse: () => widget.projects.isNotEmpty
          ? widget.projects.first
          : const TaskProjectOption(
              id: 'lead-0011',
              name: 'Storage 0011',
              jobId: '2026014',
            ),
    );

    Navigator.of(context).pop(
      TaskBoardItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        leadId: selProject.id,
        title: _nameCtrl.text.trim().isEmpty
            ? 'New Task'
            : _nameCtrl.text.trim(),
        project: selProject.name,
        description: _descCtrl.text.trim().isEmpty
            ? 'Task added from board'
            : _descCtrl.text.trim(),
        assignee: _assignee,
        dueDate: _deadline ?? DateTime.now(),
        priority: _priority,
        column: column,
        completed: column == TaskColumn.done,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width * 0.52).clamp(520.0, 640.0);
    final assigneeList = widget.assignees.isNotEmpty
        ? widget.assignees
        : TaskStaticData.assignees;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.08,
        vertical: size.height * 0.04,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Text(
                  'New Task',
                  style: TextStyle(
                    fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),

              // Form Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Task Name'),
                                TextField(
                                  controller: _nameCtrl,
                                  decoration: _inputDecoration(hint: 'Enter'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Project'),
                                _projectDropdown(
                                  value: _selectedProjectId,
                                  projects: widget.projects.isNotEmpty
                                      ? widget.projects
                                      : TaskProjectOption.defaultProjects(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _selectedProjectId = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Assigned To'),
                                _dropdown(
                                  value: _assignee,
                                  items: assigneeList,
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _assignee = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [_label('Deadline'), _dateField()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Priority'),
                                _dropdown(
                                  value: _priority,
                                  items: TaskStaticData.priorities,
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _priority = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Status'),
                                _dropdown(
                                  value: _status,
                                  items: TaskStaticData.statuses,
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _status = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _label('Description'),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 4,
                        decoration: _inputDecoration(hint: 'Enter'),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),

              // Bottom Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 140,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _create,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Create Task',
                          style: TextStyle(fontWeight: FontWeight.w700),
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

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: _inputDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _deadline == null
                    ? 'dd - mm - yyyy'
                    : formatTaskDate(_deadline!),
                style: TextStyle(
                  color: _deadline == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
    ),
  );

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primaryBlue),
    ),
  );

  Widget _projectDropdown({
    required String value,
    required List<TaskProjectOption> projects,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = projects.any((p) => p.id == value)
        ? value
        : (projects.isNotEmpty ? projects.first.id : '');

    return DropdownButtonFormField<String>(
      key: ValueKey(validValue),
      initialValue: validValue.isEmpty ? null : validValue,
      isExpanded: true,
      decoration: _inputDecoration(),
      hint: const Text(
        'Select Project',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      items: projects
          .map(
            (p) => DropdownMenuItem<String>(
              value: p.id,
              child: Text(
                p.displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : null);

    return DropdownButtonFormField<String>(
      key: ValueKey(validValue),
      initialValue: validValue,
      isExpanded: true,
      decoration: _inputDecoration(),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
