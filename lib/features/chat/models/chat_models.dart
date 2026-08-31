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
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final int unreadCount;
}

class DirectContact {
  const DirectContact({
    required this.id,
    required this.name,
    required this.role,
    this.isOnline = true,
  });

  final String id;
  final String name;
  final String role;
  final bool isOnline;
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
  });

  final String id;
  final String senderName;
  final String message;
  final String timestamp;
  final bool isMe;
  final bool isAi;
  final String? senderAvatar;
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
}

class ChatFile {
  const ChatFile({
    required this.id,
    required this.fileName,
    required this.author,
  });

  final String id;
  final String fileName;
  final String author;
}
