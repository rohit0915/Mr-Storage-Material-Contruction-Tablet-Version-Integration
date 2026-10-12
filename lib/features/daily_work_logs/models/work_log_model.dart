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
  String get displayLoggedBy => _cleanUserName(loggedByName);
  String get displayLoggedByEmail => _cleanUserEmail(loggedByEmail);

  factory WorkLogItem.fromJson(Map<String, dynamic> json) {
    String pName = '';
    String jId = '';
    String lId = '';

    if (json['leadId'] is Map) {
      final lead = json['leadId'] as Map;
      pName = lead['projectName']?.toString() ??
          lead['name']?.toString() ??
          '';
      jId = lead['jobId']?.toString() ?? lead['code']?.toString() ?? '';
      lId = lead['_id']?.toString() ?? lead['id']?.toString() ?? '';
    } else if (json['project'] is Map) {
      final p = json['project'] as Map;
      pName = p['projectName']?.toString() ?? p['name']?.toString() ?? '';
      jId = p['jobId']?.toString() ?? p['code']?.toString() ?? '';
      lId = p['_id']?.toString() ?? p['id']?.toString() ?? '';
    } else if (json['projectName'] != null && json['projectName'].toString().isNotEmpty) {
      pName = json['projectName'].toString();
      jId = json['jobId']?.toString() ?? '';
      lId = json['leadId']?.toString() ?? json['projectId']?.toString() ?? '';
    } else if (json['leadId'] != null) {
      lId = json['leadId'].toString();
      pName = json['leadName']?.toString() ?? json['project']?.toString() ?? '';
    }

    if (pName.isEmpty) {
      pName = json['project']?.toString() ?? 'Storage 0011';
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

    final userObj = json['loggedBy'] ??
        json['createdBy'] ??
        json['user'] ??
        json['author'];

    if (userObj is Map) {
      final u = userObj;
      creator = u['name']?.toString() ??
          u['fullName']?.toString() ??
          u['userName']?.toString() ??
          u['email']?.toString() ??
          creator;
      email = u['email']?.toString() ?? email;
    } else if (userObj != null) {
      creator = _cleanUserName(userObj.toString(), fallback: creator);
      email = _cleanUserEmail(userObj.toString(), fallback: email);
    }

    if (json['loggedByName'] != null && json['loggedByName'].toString().isNotEmpty) {
      creator = _cleanUserName(json['loggedByName'].toString(), fallback: creator);
    }
    if (json['loggedByEmail'] != null && json['loggedByEmail'].toString().isNotEmpty) {
      email = _cleanUserEmail(json['loggedByEmail'].toString(), fallback: email);
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

  static String _cleanUserName(String raw, {String fallback = 'Construction User'}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return fallback;
    // Check if it's a map toString or json string like "{_id: ..., name: Construction User, ...}"
    if (trimmed.contains('{') && trimmed.contains('}')) {
      final nameMatch = RegExp(r'''['"]?name['"]?\s*:\s*['"]?([^,'"}]+)['"]?''').firstMatch(trimmed);
      if (nameMatch != null && nameMatch.group(1) != null) {
        final extracted = nameMatch.group(1)!.trim();
        if (extracted.isNotEmpty && extracted != 'null') return extracted;
      }
      final emailMatch = RegExp(r'''['"]?email['"]?\s*:\s*['"]?([^,'"}]+)['"]?''').firstMatch(trimmed);
      if (emailMatch != null && emailMatch.group(1) != null) {
        final extracted = emailMatch.group(1)!.trim();
        if (extracted.isNotEmpty && extracted != 'null') return extracted;
      }
      return fallback;
    }
    return trimmed;
  }

  static String _cleanUserEmail(String raw, {String fallback = 'construction1@example.com'}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return fallback;
    if (trimmed.contains('{') && trimmed.contains('}')) {
      final emailMatch = RegExp(r'''['"]?email['"]?\s*:\s*['"]?([^,'"}]+)['"]?''').firstMatch(trimmed);
      if (emailMatch != null && emailMatch.group(1) != null) {
        final extracted = emailMatch.group(1)!.trim();
        if (extracted.isNotEmpty && extracted != 'null') return extracted;
      }
      return fallback;
    }
    if (trimmed.contains('@')) return trimmed;
    return fallback;
  }

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
      WorkLogItem(
        id: 'log-005',
        leadId: 'lead-namra-01',
        projectName: 'Storage Namra LLC 01',
        jobId: 'LOAD-001',
        taskId: '',
        taskTitle: 'Site Preparation & Groundwork',
        date: DateTime(2026, 10, 4),
        progress: 85,
        workDescription:
            'Grading and ground preparation completed. Anchor bolt positions verified.',
        photos: const [],
        issues: 'Site cleared and ready for next erection phase.',
        loggedByName: 'Construction User',
        loggedByEmail: 'construction1@example.com',
      ),
      WorkLogItem(
        id: 'log-006',
        leadId: 'lead-namra-01',
        projectName: 'Storage Namra LLC 01',
        jobId: 'LOAD-001',
        taskId: '',
        taskTitle: 'Structural Frame Erection',
        date: DateTime(2026, 10, 3),
        progress: 50,
        workDescription:
            'Unloaded bundle materials and verified package checklist. Commenced column erection.',
        photos: const [],
        issues: 'All bundles scanned and accounted for.',
        loggedByName: 'Construction User',
        loggedByEmail: 'construction1@example.com',
      ),
    ];
  }
}
