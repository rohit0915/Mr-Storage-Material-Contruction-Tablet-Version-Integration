import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/construction_socket_service.dart';
import '../../../app/utils/app_logger.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  ChatController({ChatService? service}) : _service = service ?? ChatService();

  final ChatService _service;

  final messageController = TextEditingController();
  final searchController = TextEditingController();

  final isLoading = false.obs;
  final isLoadingMessages = false.obs;

  final activeTab = ChatTab.departments.obs;
  final selectedDepartmentId = RxnString();
  final selectedContactId = RxnString();

  final isInfoPanelOpen = false.obs;
  final activeInfoTab = InfoPanelTab.members.obs;
  final isMuted = false.obs;

  // Real-time socket states
  final isTeamTyping = false.obs;
  final typingUserName = ''.obs;
  StreamSubscription<ConstructionSocketEvent>? _socketSubscription;
  Timer? _typingTimer;
  bool _typingSent = false;

  final departments = <DepartmentChannel>[].obs;
  final contacts = <DirectContact>[].obs;
  final searchResults = <DirectContact>[].obs;
  final messages = <ChatMessage>[].obs;
  final members = <ChatMember>[].obs;
  final files = <ChatFile>[].obs;
  final unreadTotal = 0.obs;

  DepartmentChannel? get activeDepartment {
    if (selectedDepartmentId.value == null) return null;
    return departments.firstWhereOrNull(
      (d) => d.id == selectedDepartmentId.value,
    );
  }

  DirectContact? get activeContact {
    if (selectedContactId.value == null) return null;
    return contacts.firstWhereOrNull((c) => c.id == selectedContactId.value) ??
        searchResults.firstWhereOrNull((c) => c.id == selectedContactId.value);
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    messageController.addListener(_onMessageInputChanged);

    // Subscribe to Socket.io real-time events
    if (Get.isRegistered<ConstructionSocketService>()) {
      _socketSubscription = Get.find<ConstructionSocketService>().listenFor(
        ConstructionSocketService.teamEvents,
        _handleSocketEvent,
      );
    }

    fetchConversations();
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    try {
      final data = await _service.getConversations();
      final groupList = data['groups'] as List<DepartmentChannel>? ?? [];
      final directList = data['direct'] as List<DirectContact>? ?? [];

      departments.assignAll(groupList);
      contacts.assignAll(directList);

      if (departments.isNotEmpty &&
          selectedDepartmentId.value == null &&
          selectedContactId.value == null) {
        selectDepartment(departments.first.id);
      } else {
        fetchMessagesForActiveChat();
      }

      fetchUnreadCount();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    final count = await _service.getUnreadCount();
    unreadTotal.value = count;
  }

  Future<void> fetchMessagesForActiveChat() async {
    final deptId = selectedDepartmentId.value;
    final contactId = selectedContactId.value;

    if (deptId == null && contactId == null) {
      messages.clear();
      return;
    }

    isLoadingMessages.value = true;
    try {
      if (deptId != null) {
        final list = await _service.getGroupMessages(deptId);
        messages.assignAll(list);
        fetchGroupDetail(deptId);
      } else if (contactId != null) {
        final list = await _service.getDirectMessages(contactId);
        messages.assignAll(list);
      }
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> fetchGroupDetail(String groupId) async {
    final detail = await _service.getGroupDetail(groupId);
    if (detail != null && detail['members'] is List) {
      final rawMembers = detail['members'] as List;
      final memberItems = rawMembers
          .whereType<Map>()
          .map((m) => ChatMember.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      members.assignAll(memberItems);
    }
  }

  void _onSearchChanged() {
    final q = searchController.text.trim();
    if (q.isNotEmpty) {
      _service.searchUsers(q).then((results) {
        searchResults.assignAll(results);
      });
    } else {
      searchResults.clear();
    }
  }

  void switchTab(ChatTab tab) {
    activeTab.value = tab;
    _leaveCurrentSocketChannel();
    if (tab == ChatTab.departments) {
      if (departments.isNotEmpty) {
        selectDepartment(departments.first.id);
      }
    } else {
      if (contacts.isNotEmpty) {
        selectContact(contacts.first.id);
      }
    }
  }

  void selectDepartment(String id) {
    if (selectedDepartmentId.value != id) {
      _leaveCurrentSocketChannel();
      selectedDepartmentId.value = id;
      selectedContactId.value = null;
      isTeamTyping.value = false;
      typingUserName.value = '';
      _joinCurrentSocketChannel();
      fetchMessagesForActiveChat();
    }
  }

  void selectContact(String id) {
    if (selectedContactId.value != id) {
      _leaveCurrentSocketChannel();
      selectedContactId.value = id;
      selectedDepartmentId.value = null;
      isTeamTyping.value = false;
      typingUserName.value = '';
      _joinCurrentSocketChannel();
      fetchMessagesForActiveChat();
    }
  }

  void toggleInfoPanel() {
    isInfoPanelOpen.value = !isInfoPanelOpen.value;
  }

  // ─── Real-Time Messaging & Socket Hooks ─────────────────────────────────────

  void _joinCurrentSocketChannel() {
    if (!Get.isRegistered<ConstructionSocketService>()) return;
    final socket = Get.find<ConstructionSocketService>();

    if (activeDepartment != null) {
      final chId = _resolveDepartmentChannelId(activeDepartment!);
      socket.joinTeamChannel('department', chId);
    } else if (activeContact != null) {
      socket.joinTeamChannel('direct', activeContact!.id);
    }
  }

  void _leaveCurrentSocketChannel() {
    if (!Get.isRegistered<ConstructionSocketService>()) return;
    final socket = Get.find<ConstructionSocketService>();

    if (activeDepartment != null) {
      final chId = _resolveDepartmentChannelId(activeDepartment!);
      socket.leaveTeamChannel('department', chId);
    } else if (activeContact != null) {
      socket.leaveTeamChannel('direct', activeContact!.id);
    }
  }

  void _onMessageInputChanged() {
    final text = messageController.text.trim();
    if (!_typingSent && text.isNotEmpty) {
      _typingSent = true;
      _sendTyping(true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 900), () {
      if (_typingSent) {
        _sendTyping(false);
      }
      _typingSent = false;
    });
  }

  void _sendTyping(bool typing) {
    if (!Get.isRegistered<ConstructionSocketService>()) return;
    final socket = Get.find<ConstructionSocketService>();

    if (activeDepartment != null) {
      final chId = _resolveDepartmentChannelId(activeDepartment!);
      socket.setTeamTyping('department', chId, typing);
    } else if (activeContact != null) {
      socket.setTeamTyping('direct', activeContact!.id, typing);
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final dept = activeDepartment;
    final contact = activeContact;
    if (dept == null && contact == null) return;

    messageController.clear();
    _typingTimer?.cancel();
    if (_typingSent) {
      _sendTyping(false);
      _typingSent = false;
    }

    // Optimistic UI insert
    final optimisticMsg = ChatMessage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      senderName: 'You',
      message: text,
      timestamp: 'Just now',
      isMe: true,
    );
    messages.add(optimisticMsg);

    bool socketSent = false;
    if (Get.isRegistered<ConstructionSocketService>()) {
      final socket = Get.find<ConstructionSocketService>();
      if (socket.isConnected.value) {
        if (dept != null) {
          final chId = _resolveDepartmentChannelId(dept);
          socketSent = socket.sendTeamMessage('department', chId, text);
        } else if (contact != null) {
          socketSent = socket.sendTeamMessage('direct', contact.id, text);
        }
      }
    }

    // If socket is not connected or failed to send, fall back to REST API
    if (!socketSent) {
      if (dept != null) {
        await _service.sendGroupMessage(dept.id, text);
      } else if (contact != null) {
        await _service.sendDirectMessage(contact.id, text);
      }
      fetchMessagesForActiveChat();
    }
  }

  void _handleSocketEvent(ConstructionSocketEvent event) {
    AppLogger.i(
      'ChatController received socket event: ${event.name}',
      tag: 'CHAT',
    );

    if (event.name == 'team_typing') {
      isTeamTyping.value = event.payload['isTyping'] == true;
      typingUserName.value = event.payload['name']?.toString() ?? '';
      return;
    }

    if (event.name == 'new_team_message') {
      final payload = event.payload;
      if (_matchesCurrentChannel(payload)) {
        final currentUserId = _currentUserId();
        final newMsg = ChatMessage.fromJson(
          payload,
          currentUserId: currentUserId,
        );

        // Deduplicate
        final exists = messages.any(
          (m) =>
              m.id == newMsg.id ||
              (m.isMe &&
                  m.message == newMsg.message &&
                  m.id.startsWith('local_')),
        );

        if (!exists) {
          messages.add(newMsg);
        } else {
          // Replace optimistic placeholder with confirmed server message
          final localIndex = messages.indexWhere(
            (m) =>
                m.isMe &&
                m.message == newMsg.message &&
                m.id.startsWith('local_'),
          );
          if (localIndex != -1) {
            messages[localIndex] = newMsg;
          }
        }
      } else {
        // Notification/badge update for other channels
        fetchUnreadCount();
      }
    }
  }

  bool _matchesCurrentChannel(Map<String, dynamic> payload) {
    final channelType = payload['channelType']?.toString();
    if (channelType == 'department') {
      final dept = activeDepartment;
      if (dept == null) return false;
      final deptKey = _resolveDepartmentChannelId(dept);
      final payloadDept = (payload['department'] ?? payload['channelId'])
          ?.toString();
      return payloadDept == deptKey || payloadDept == dept.id;
    } else if (channelType == 'direct') {
      final contact = activeContact;
      if (contact == null) return false;
      final participants = payload['participants'];
      final senderId = payload['senderId']?.toString();
      final directKey = payload['directKey']?.toString() ?? '';
      if (participants is List) {
        return participants.map((p) => p.toString()).contains(contact.id);
      }
      return senderId == contact.id || directKey.contains(contact.id);
    }
    return false;
  }

  String _resolveDepartmentChannelId(DepartmentChannel dept) {
    final idLower = dept.id.toLowerCase();
    for (final key in ['construction', 'sales', 'plant', 'account', 'admin']) {
      if (idLower == key || dept.title.toLowerCase().contains(key)) {
        return key;
      }
    }
    return dept.id;
  }

  String _currentUserId() {
    if (!Get.isRegistered<ApiClient>()) return '';
    final user = Get.find<ApiClient>().getUserData();
    if (user == null) return '';
    return (user['_id'] ?? user['id'] ?? '').toString();
  }

  Future<void> createGroupChannel(
    String name,
    String description,
    List<String> memberIds,
  ) async {
    final group = await _service.createGroup(name, description, memberIds);
    if (group != null) {
      departments.add(group);
      selectDepartment(group.id);
    }
  }

  @override
  void onClose() {
    _leaveCurrentSocketChannel();
    _socketSubscription?.cancel();
    _typingTimer?.cancel();
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
