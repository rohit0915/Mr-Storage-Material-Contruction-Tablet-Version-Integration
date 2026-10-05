import 'package:intl/intl.dart';

class WorkLogItem {
  const WorkLogItem({
    required this.id,
    this.leadId = '',
    required this.projectName,
    this.jobId = '',
    this.taskId = '',
    this.taskTitle = 'General',
    required this.date,
    required this.progress,
    required this.workDescription,
    this.photos = const [],
    this.issues = '—',
    this.loggedByName = 'Construction User',
    this.loggedByEmail = 'construction1@example.com',
  });

  final String id;
  final String leadId;
  final String projectName;
  final String jobId;
  final String taskId;
  final String taskTitle;
  final DateTime date;
  final int progress;
  final String workDescription;
  final List<String> photos;
  final String issues;
  final String loggedByName;
  final String loggedByEmail;

  String get formattedDate => DateFormat('dd MMM yyyy').format(date);
  String get displayDateModal => DateFormat('dd/MM/yyyy').format(date);

  factory WorkLogItem.fromJson(Map<String, dynamic> json) {
    String pName = 'Storage 0011';
    String jId = '2026014';
    String lId = '';

    if (json['leadId'] is Map) {
      final lead = json['leadId'] as Map;
      pName = lead['projectName']?.toString() ??
          lead['name']?.toString() ??
          'Storage 0011';
      jId = lead['jobId']?.toString() ?? lead['code']?.toString() ?? '2026014';
      lId = lead['_id']?.toString() ?? lead['id']?.toString() ?? '';
    } else if (json['project'] is Map) {
      final p = json['project'] as Map;
      pName = p['projectName']?.toString() ?? p['name']?.toString() ?? 'Storage 0011';
      jId = p['jobId']?.toString() ?? p['code']?.toString() ?? '2026014';
      lId = p['_id']?.toString() ?? p['id']?.toString() ?? '';
    } else if (json['projectName'] != null && json['projectName'].toString().isNotEmpty) {
      pName = json['projectName'].toString();
      jId = json['jobId']?.toString() ?? '2026014';
    } else if (json['leadId'] != null) {
      lId = json['leadId'].toString();
    }

    String tTitle = 'General';
    String tId = '';
    if (json['taskId'] is Map) {
      final task = json['taskId'] as Map;
      tTitle = task['title']?.toString() ?? 'General';
      tId = task['_id']?.toString() ?? task['id']?.toString() ?? '';
    } else if (json['task'] is Map) {
      final task = json['task'] as Map;
      tTitle = task['title']?.toString() ?? 'General';
      tId = task['_id']?.toString() ?? task['id']?.toString() ?? '';
    } else if (json['taskTitle'] != null && json['taskTitle'].toString().isNotEmpty) {
      tTitle = json['taskTitle'].toString();
    } else if (json['taskId'] != null) {
      tId = json['taskId'].toString();
    }

    DateTime d = DateTime.now();
    if (json['date'] != null) {
      try {
        d = DateTime.parse(json['date'].toString());
      } catch (_) {}
    } else if (json['createdAt'] != null) {
      try {
        d = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    int prog = 0;
    if (json['progress'] != null) {
      prog = int.tryParse(json['progress'].toString().replaceAll('%', '').trim()) ?? 0;
    }

    String creator = 'Construction User';
    String email = 'construction1@example.com';
    if (json['createdBy'] is Map) {
      final u = json['createdBy'] as Map;
      creator = u['name']?.toString() ?? u['email']?.toString() ?? creator;
      email = u['email']?.toString() ?? email;
    } else if (json['user'] is Map) {
      final u = json['user'] as Map;
      creator = u['name']?.toString() ?? u['email']?.toString() ?? creator;
      email = u['email']?.toString() ?? email;
    } else if (json['loggedBy'] != null) {
      creator = json['loggedBy'].toString();
    }

    final pList = <String>[];
    if (json['photos'] is List) {
      for (final p in json['photos']) {
        if (p != null && p.toString().isNotEmpty) {
          pList.add(p.toString());
        }
      }
    }

    return WorkLogItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'log-${DateTime.now().millisecondsSinceEpoch}',
      leadId: lId,
      projectName: pName,
      jobId: jId,
      taskId: tId,
      taskTitle: tTitle,
      date: d,
      progress: prog,
      workDescription: json['description']?.toString() ?? json['workDescription']?.toString() ?? '',
      photos: pList,
      issues: (json['issues']?.toString().isNotEmpty == true) ? json['issues'].toString() : '—',
      loggedByName: creator,
      loggedByEmail: email,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'leadId': leadId,
        'projectName': projectName,
        'jobId': jobId,
        'taskId': taskId,
        'taskTitle': taskTitle,
        'date': date.toIso8601String(),
        'progress': progress,
        'description': workDescription,
        'photos': photos,
        'issues': issues,
        'loggedByName': loggedByName,
        'loggedByEmail': loggedByEmail,
      };

  WorkLogItem copyWith({
    String? id,
    String? leadId,
    String? projectName,
    String? jobId,
    String? taskId,
    String? taskTitle,
    DateTime? date,
    int? progress,
    String? workDescription,
    List<String>? photos,
    String? issues,
    String? loggedByName,
    String? loggedByEmail,
  }) {
    return WorkLogItem(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      projectName: projectName ?? this.projectName,
      jobId: jobId ?? this.jobId,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      date: date ?? this.date,
      progress: progress ?? this.progress,
      workDescription: workDescription ?? this.workDescription,
      photos: photos ?? this.photos,
      issues: issues ?? this.issues,
      loggedByName: loggedByName ?? this.loggedByName,
      loggedByEmail: loggedByEmail ?? this.loggedByEmail,
    );
  }

  /// Default work logs matching active projects
  static List<WorkLogItem> defaultLogs() {
    final now = DateTime(2026, 10, 2);
    return [
      WorkLogItem(
        id: 'log-001',
        leadId: 'lead-0011',
        projectName: 'Storage 0011',
        jobId: '2026014',
        taskId: '',
        taskTitle: 'General',
        date: now,
        progress: 19,
        workDescription: 'de da madbv WF',
        photos: const [],
        issues: '—',
        loggedByName: 'Construction User',
        loggedByEmail: 'construction1@example.com',
      ),
      WorkLogItem(
        id: 'log-002',
        leadId: 'lead-0011',
        projectName: 'Storage 0011',
        jobId: '2026014',
        taskId: '',
        taskTitle: 'General',
        date: now,
        progress: 15,
        workDescription: 'EWF',
        photos: const [],
        issues: '—',
        loggedByName: 'Construction User',
        loggedByEmail: 'construction1@example.com',
      ),
      WorkLogItem(
        id: 'log-003',
        leadId: 'lead-002',
        projectName: 'Lucas project',
        jobId: 'PRO-002',
        taskId: '',
        taskTitle: 'Foundation Excavation',
        date: DateTime(2026, 9, 30),
        progress: 45,
        workDescription:
            'Foundation pouring completed for sector B and framing anchors staged.',
        photos: const ['slide-1.png', 'qa-test-media.jpg'],
        issues: 'Concrete curing inspection scheduled for tomorrow morning.',
        loggedByName: 'Lucas1',
        loggedByEmail: 'lucas1@example.com',
      ),
      WorkLogItem(
        id: 'log-004',
        leadId: 'lead-042',
        projectName: 'Adam Gilchrist',
        jobId: 'PRO-042',
        taskId: '',
        taskTitle: 'Steel Frame Installation',
        date: DateTime(2026, 9, 24),
        progress: 70,
        workDescription:
            'Main structural steel rafters and cross-bracings erected successfully.',
        photos: const ['Screenshot_2026-09-21.png'],
        issues: 'Wind speeds within acceptable limits, work on schedule.',
        loggedByName: 'Adam Gilchrist',
        loggedByEmail: 'adam@example.com',
      ),
    ];
  }
}
