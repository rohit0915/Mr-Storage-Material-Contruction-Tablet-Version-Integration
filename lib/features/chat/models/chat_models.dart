import 'package:flutter/material.dart';

enum ChatTab { departments, direct }

enum InfoPanelTab { members, files }

class DepartmentChannel {
  const DepartmentChannel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.unreadCount = 0,
    this.membersCount = 0,
    this.rawMemberIds = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final int unreadCount;
  final int membersCount;
  final List<String> rawMemberIds;

  factory DepartmentChannel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'] ?? '';
    final name = json['name'] ?? json['title'] ?? 'Group Channel';
    final desc = json['description'] ?? json['subtitle'] ?? '';
    final unread = (json['unreadCount'] as num?)?.toInt() ?? 0;
    final members = json['members'] is List
        ? (json['members'] as List).length
        : 0;
    final memberIds = json['members'] is List
        ? (json['members'] as List)
              .map((m) => (m is Map ? m['_id'] ?? m['id'] ?? '' : m).toString())
              .toList()
        : <String>[];

    return DepartmentChannel(
      id: rawId.toString(),
      title: name.toString(),
      subtitle: desc.toString().isNotEmpty
          ? desc.toString()
          : '$members members',
      icon: Icons.campaign_rounded,
      iconColor: const Color(0xFF2563EB),
      unreadCount: unread,
      membersCount: members,
      rawMemberIds: memberIds,
    );
  }
}

class DirectContact {
  const DirectContact({
    required this.id,
    required this.name,
    required this.role,
    this.isOnline = true,
    this.avatarUrl,
    this.email,
  });

  final String id;
  final String name;
  final String role;
  final bool isOnline;
  final String? avatarUrl;
  final String? email;

  factory DirectContact.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'] ?? '';
    final name = json['name'] ?? json['fullName'] ?? json['email'] ?? 'User';
    final role =
        json['role'] ?? json['title'] ?? json['department'] ?? 'Team Member';
    final email = json['email'];
    final avatar = json['avatar'] ?? json['profileImage'];

    return DirectContact(
      id: rawId.toString(),
      name: name.toString(),
      role: role.toString(),
      isOnline: json['isOnline'] == true || json['status'] == 'online',
      avatarUrl: avatar?.toString(),
      email: email?.toString(),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isMe = false,
    this.isAi = false,
    this.senderAvatar,
    this.fileUrl,
    this.fileName,
  });

  final String id;
  final String senderName;
  final String message;
  final String timestamp;
  final bool isMe;
  final bool isAi;
  final String? senderAvatar;
  final String? fileUrl;
  final String? fileName;

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final rawId = json['_id'] ?? json['id'] ?? '';
    final senderMap = json['sender'] is Map ? json['sender'] as Map : {};
    final senderId =
        senderMap['_id'] ?? senderMap['id'] ?? json['senderId'] ?? '';
    final senderName =
        senderMap['name'] ??
        senderMap['fullName'] ??
        json['senderName'] ??
        'User';

    final text = json['content'] ?? json['message'] ?? json['text'] ?? '';
    final createdAt = json['createdAt'] ?? json['timestamp'] ?? '';
    final isMe = currentUserId != null && senderId.toString() == currentUserId;
    final fileUrl = json['attachmentUrl'] ?? json['fileUrl'];
    final fileName = json['fileName'] ?? json['attachmentName'];

    return ChatMessage(
      id: rawId.toString(),
      senderName: senderName.toString(),
      message: text.toString(),
      timestamp: createdAt.toString().isNotEmpty
          ? createdAt.toString()
          : 'Just now',
      isMe: isMe,
      isAi: json['isAi'] == true,
      senderAvatar: senderMap['avatar']?.toString(),
      fileUrl: fileUrl?.toString(),
      fileName: fileName?.toString(),
    );
  }
}

class ChatMember {
  const ChatMember({
    required this.id,
    required this.name,
    required this.role,
    this.isAdmin = false,
  });

  final String id;
  final String name;
  final String role;
  final bool isAdmin;

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'] ?? '';
    final name = json['name'] ?? json['fullName'] ?? 'Member';
    final role = json['role'] ?? json['department'] ?? 'Member';
    final isAdmin = json['isAdmin'] == true || json['role'] == 'admin';

    return ChatMember(
      id: rawId.toString(),
      name: name.toString(),
      role: role.toString(),
      isAdmin: isAdmin,
    );
  }
}

class ChatFile {
  const ChatFile({
    required this.id,
    required this.fileName,
    required this.author,
    this.fileUrl,
  });

  final String id;
  final String fileName;
  final String author;
  final String? fileUrl;

  factory ChatFile.fromJson(Map<String, dynamic> json) {
    return ChatFile(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fileName: (json['fileName'] ?? json['name'] ?? 'File').toString(),
      author: (json['author'] ?? json['senderName'] ?? 'User').toString(),
      fileUrl: json['url']?.toString(),
    );
  }
}
