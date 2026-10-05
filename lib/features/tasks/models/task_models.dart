import 'package:flutter/material.dart';

enum TaskColumn { todo, inProgress, done }

class TaskBoardItem {
  const TaskBoardItem({
    required this.id,
    this.leadId = '',
    required this.title,
    required this.project,
    required this.description,
    required this.assignee,
    required this.dueDate,
    required this.priority,
    required this.column,
    this.completed = false,
  });

  final String id;
  final String leadId;
  final String title;
  final String project;
  final String description;
  final String assignee;
  final DateTime dueDate;
  final String priority;
  final TaskColumn column;
  final bool completed;

  factory TaskBoardItem.fromJson(Map<String, dynamic> json) {
    String pName = 'No Project';
    if (json['leadId'] is Map) {
      pName =
          json['leadId']['projectName']?.toString() ??
          json['leadId']['jobId']?.toString() ??
          'No Project';
    } else if (json['project'] != null) {
      pName = json['project'].toString();
    }

    String assigneeName = 'Unassigned';
    if (json['assignedTo'] is Map) {
      assigneeName = json['assignedTo']['name']?.toString() ?? 'Unassigned';
    } else if (json['assignedTo'] != null) {
      assigneeName = json['assignedTo'].toString();
    }

    TaskColumn col = TaskColumn.todo;
    final statusStr = (json['status'] ?? '').toString().toLowerCase();
    if (statusStr == 'in_progress' || statusStr == 'inprogress') {
      col = TaskColumn.inProgress;
    } else if (statusStr == 'done' || statusStr == 'completed') {
      col = TaskColumn.done;
    }

    DateTime dDate = DateTime.now();
    if (json['dueDate'] != null) {
      try {
        dDate = DateTime.parse(json['dueDate'].toString());
      } catch (_) {}
    }

    final prioRaw = json['priority']?.toString() ?? 'medium';
    final prioStr = prioRaw.isNotEmpty
        ? (prioRaw[0].toUpperCase() + prioRaw.substring(1).toLowerCase())
        : 'Medium';

    return TaskBoardItem(
      id: json['_id'] ?? json['id'] ?? '',
      leadId: json['leadId'] is Map
          ? (json['leadId']['_id'] ?? json['leadId']['id'] ?? '').toString()
          : (json['leadId'] ?? '').toString(),
      title: json['title'] ?? 'Task',
      project: pName,
      description: json['description'] ?? '',
      assignee: assigneeName,
      dueDate: dDate,
      priority: prioStr,
      column: col,
      completed: col == TaskColumn.done,
    );
  }

  TaskBoardItem copyWith({
    String? id,
    String? leadId,
    String? title,
    String? project,
    String? description,
    String? assignee,
    DateTime? dueDate,
    String? priority,
    TaskColumn? column,
    bool? completed,
  }) {
    return TaskBoardItem(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      title: title ?? this.title,
      project: project ?? this.project,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      column: column ?? this.column,
      completed: completed ?? this.completed,
    );
  }
}

class TaskSummaryItem {
  const TaskSummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
}

class TaskProjectOption {
  const TaskProjectOption({
    required this.id,
    required this.name,
    this.jobId = '',
  });

  final String id;
  final String name;
  final String jobId;

  String get displayName => jobId.isNotEmpty ? '$name ($jobId)' : name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskProjectOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  static List<TaskProjectOption> defaultProjects() => const [
    TaskProjectOption(id: 'lead-0011', name: 'Storage 0011', jobId: '2026014'),
    TaskProjectOption(id: 'lead-002', name: 'Lucas project', jobId: 'PRO-002'),
    TaskProjectOption(id: 'lead-042', name: 'Adam Gilchrist', jobId: 'PRO-042'),
    TaskProjectOption(id: 'lead-003', name: 'Another Project', jobId: 'PRO-003'),
  ];
}

class TaskStaticData {
  static const projects = [
    'Storage 0011',
    'Lucas project',
    'Adam Gilchrist',
    'Another Project',
  ];

  static const assignees = [
    'Unassigned',
    'Construction User',
    'Lucas1',
    'Namra',
    'Sarah Wilson',
    'Mike Johnson',
    'Robert Chen',
    'John Miller',
    'Adam Gilchrist',
  ];

  static const taskNames = [
    'Foundation Excavation',
    'Steel Frame Installation',
    'Plumbing Installation',
    'Electrical Wiring - Floor 1',
  ];

  static const priorities = ['High', 'Medium', 'Low', 'Urgent'];

  static const statuses = ['To Do', 'In Progress', 'Done'];
}
