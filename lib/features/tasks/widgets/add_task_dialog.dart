import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../models/task_models.dart';
import 'task_calendar_dialog.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key, required this.projects});

  final List<TaskBoardItem> projects;

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late String _project;
  String _assignee = 'Mike Johnson';
  DateTime? _deadline;
  String _priority = 'High';
  String _status = 'To Do';

  @override
  void initState() {
    super.initState();
    final names = widget.projects
        .map((e) => e.project)
        .where((e) => e.isNotEmpty)
        .toSet();
    _project = names.isEmpty ? '' : names.first;
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
      initialDate: _deadline ?? DateTime(2025, 5, 18),
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
    Navigator.of(context).pop(
      TaskBoardItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        leadId: widget.projects
            .firstWhere(
              (item) => item.project == _project,
              orElse: () => TaskBoardItem(
                id: '',
                title: '',
                project: '',
                description: '',
                assignee: '',
                dueDate: DateTime.now(),
                priority: '',
                column: TaskColumn.todo,
              ),
            )
            .leadId,
        title: _nameCtrl.text.trim().isEmpty
            ? 'New Task'
            : _nameCtrl.text.trim(),
        project: _project,
        description: _descCtrl.text.trim().isEmpty
            ? 'Task added from board'
            : _descCtrl.text.trim(),
        assignee: _assignee,
        dueDate: _deadline ?? DateTime(2024, 2, 15),
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
                                _dropdown(
                                  value: _project,
                                  items: widget.projects
                                      .map((e) => e.project)
                                      .where((e) => e.isNotEmpty)
                                      .toSet()
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _project = v!),
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
                                  items: TaskStaticData.assignees,
                                  onChanged: (v) =>
                                      setState(() => _assignee = v!),
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
                                  onChanged: (v) =>
                                      setState(() => _priority = v!),
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
                                  onChanged: (v) =>
                                      setState(() => _status = v!),
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

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: _inputDecoration(),
      items: items
          .map(
            (e) => DropdownMenuItem(
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
