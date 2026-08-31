import 'package:flutter/material.dart';

enum TaskColumn { todo, inProgress, done }

class TaskBoardItem {
  const TaskBoardItem({
    required this.id,
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
      pName = json['leadId']['projectName']?.toString() ?? json['leadId']['jobId']?.toString() ?? 'No Project';
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

class TaskStaticData {
  static const projects = [
    'Downtown Office Complex',
    'Residential Tower A',
    'ABC Logistics Warehouse',
    'Metro Cast Factory Shed',
  ];

  static const assignees = [
    'Sarah Wilson',
    'Mike Johnson',
    'Robert Chen',
    'John Miller',
  ];

  static const taskNames = [
    'Foundation Excavation',
    'Steel Frame Installation',
    'Plumbing Installation',
    'Electrical Wiring - Floor 1',
  ];

  static const priorities = ['High', 'Medium', 'Low'];

  static const statuses = ['To Do', 'In Progress', 'Done'];
}
