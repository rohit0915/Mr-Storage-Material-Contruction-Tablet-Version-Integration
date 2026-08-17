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
