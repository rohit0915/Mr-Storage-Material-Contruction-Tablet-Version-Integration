import 'package:file_picker/file_picker.dart';
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

  final attachments = <Map<String, dynamic>>[].obs;
  final isUploadingAttachment = false.obs;

  Future<void> pickAttachment() async {
    if (isUploadingAttachment.value) return;
    final groupId = selectedDepartmentId.value;
    final contactId = selectedContactId.value;
    if (groupId == null && contactId == null) return;
    isUploadingAttachment.value = true;
    try {
      final result = await FilePicker.pickFiles();
      if (result.isEmpty ||
          isClosed ||
          groupId != selectedDepartmentId.value ||
          contactId != selectedContactId.value) {
        return;
      }
      if (attachments.length + result.length > 10) {
        throw Exception('Maximum 10 attachments per message');
      }
      for (final file in result) {
        final bytes = await file.readAsBytes();
        final type = switch (file.extension?.toLowerCase()) {
          'jpg' || 'jpeg' => 'image/jpeg',
          'png' => 'image/png',
          'webp' => 'image/webp',
          'gif' => 'image/gif',
          'pdf' => 'application/pdf',
          'mp4' => 'video/mp4',
          'txt' => 'text/plain',
          _ => 'application/octet-stream',
        };
        final uploaded = await _service.uploadAttachment(
          file.name,
          type,
          bytes,
        );
        if (isClosed ||
            groupId != selectedDepartmentId.value ||
            contactId != selectedContactId.value) {
          return;
        }
        attachments.add(uploaded);
      }
    } catch (error) {
      Get.snackbar(
        'Attachment upload failed',
        'Please retry. ${error.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (!isClosed) isUploadingAttachment.value = false;
    }
  }

  void showCallAvailability({required bool video}) {
    Get.dialog<void>(
      AlertDialog(
        title: Text(video ? 'Video call' : 'Voice call'),
        content: const Text(
          'Calling is not available yet. A calling service needs to be connected to this app.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  TextEditingController _messageController = TextEditingController();
  TextEditingController get messageController {
    try {
      final _ = _messageController.text;
    } catch (_) {
      _messageController = TextEditingController();
    }
    return _messageController;
  }

  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController {
    try {
      final _ = _searchController.text;
    } catch (_) {
      _searchController = TextEditingController(text: searchQuery.value);
    }
    return _searchController;
  }

  final isLoading = false.obs;
  final conversationError = ''.obs;
  final messageError = ''.obs;
  final searchQuery = ''.obs;
  int _messageRequest = 0;
  Map<String, dynamic> get currentUser => Get.isRegistered<ApiClient>()
      ? Get.find<ApiClient>().getUserData() ?? {}
      : {};
  String get userName =>
      (currentUser['name'] ?? currentUser['fullName'] ?? 'User').toString();
  String get userRole =>
      (currentUser['department'] ?? currentUser['role'] ?? '').toString();
  bool get isConnected =>
      Get.isRegistered<ConstructionSocketService>() &&
      Get.find<ConstructionSocketService>().isConnected.value;
  List<DepartmentChannel> get visibleDepartments => departments
      .where((d) => d.title.toLowerCase().contains(searchQuery.value))
      .toList();
  List<DirectContact> get visibleContacts =>
      (searchQuery.value.isEmpty ? contacts : searchResults)
          .where(
            (c) =>
                c.name.toLowerCase().contains(searchQuery.value) ||
                (c.email ?? '').toLowerCase().contains(searchQuery.value),
          )
          .toList();

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
    conversationError.value = '';
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
    } catch (_) {
      conversationError.value = 'Unable to load chats. Please retry.';
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

    final request = ++_messageRequest;
    isLoadingMessages.value = true;
    messageError.value = '';
    messages.clear();
    members.clear();
    try {
      final list = deptId != null
          ? await _service.getGroupMessages(deptId)
          : await _service.getDirectMessages(contactId!);
      if (request != _messageRequest || isClosed) return;
      messages.assignAll(list);
      if (deptId != null) fetchGroupDetail(deptId);
    } catch (_) {
      if (request == _messageRequest && !isClosed) {
        messageError.value = 'Unable to load messages. Please retry.';
      }
    } finally {
      if (request == _messageRequest && !isClosed) {
   
        isLoadingMessages.value = false;
      }
    }
  }

  Future<void> fetchGroupDetail(String groupId) async {
    final detail = await _service.getGroupDetail(groupId);
    if (!isClosed &&
        selectedDepartmentId.value == groupId &&
        detail != null &&
        detail['members'] is List) {
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
    searchQuery.value = q.toLowerCase();
    if (q.isNotEmpty) {
      _service.searchUsers(q).then((results) {
        if (!isClosed && searchController.text.trim() == q) {
          searchResults.assignAll(results);
        }
      });
    } else {
      searchResults.clear();
    }
  }

  void switchTab(ChatTab tab) {
    attachments.clear();
    activeTab.value = tab;
    _leaveCurrentSocketChannel();
    selectedDepartmentId.value = null;
    selectedContactId.value = null;
    ++_messageRequest;
    messages.clear();
    members.clear();
    isLoadingMessages.value = false;
    messageError.value = '';
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
      attachments.clear();
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
      attachments.clear();
      selectedContactId.value = id;
      selectedDepartmentId.value = null;
      isTeamTyping.value = false;
      typingUserName.value = '';
      _joinCurrentSocketChannel();
      fetchMessagesForActiveChat();
    }
  }

  Future<void> openNewChat() async {
    final users = await _service.searchUsers('');
    if (isClosed) return;
    await Get.dialog<void>(
      AlertDialog(
        title: const Text('New chat'),
        content: SizedBox(
          width: 360,
          height: 400,
          child: users.isEmpty
              ? const Center(child: Text('No users available'))
              : ListView(
                  children: users
                      .where((u) => u.id != _currentUserId())
                      .map(
                        (user) => ListTile(
                          title: Text(user.name),
                          subtitle: Text(user.role),
                          onTap: () {
                            if (!contacts.any((c) => c.id == user.id)) {
                              contacts.add(user);
                            }
                            searchController.clear();
                            activeTab.value = ChatTab.direct;
                            selectContact(user.id);
                            Get.back();
                          },
                        ),
                      )
                      .toList(),
                ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void toggleInfoPanel() {
    isInfoPanelOpen.value = !isInfoPanelOpen.value;
  }

  // ─── Real-Time Messaging & Socket Hooks ─────────────────────────────────────

  void _joinCurrentSocketChannel() {
    if (!Get.isRegistered<ConstructionSocketService>()) return;
    final socket = Get.find<ConstructionSocketService>();

    if (activeDepartment != null) {
      final chId = activeDepartment!.id;
      socket.joinTeamChannel('group', chId);
    } else if (activeContact != null) {
      socket.joinTeamChannel('direct', activeContact!.id);
    }
  }

  void _leaveCurrentSocketChannel() {
    if (!Get.isRegistered<ConstructionSocketService>()) return;
    final socket = Get.find<ConstructionSocketService>();

    if (activeDepartment != null) {
      final chId = activeDepartment!.id;
      socket.leaveTeamChannel('group', chId);
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
      final chId = activeDepartment!.id;
      socket.setTeamTyping('group', chId, typing);
    } else if (activeContact != null) {
      socket.setTeamTyping('direct', activeContact!.id, typing);
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (isUploadingAttachment.value || (text.isEmpty && attachments.isEmpty)) {
      return;
    }
    final outgoingAttachments = attachments
        .map((a) => Map<String, dynamic>.from(a))
        .toList();
    if (outgoingAttachments.isNotEmpty && !isConnected) {
      Get.snackbar(
        'Not connected',
        'Your attachments are ready. Retry when connected.',
      );
      return;
    }

    final dept = activeDepartment;
    final contact = activeContact;
    if (dept == null && contact == null) return;

    messageController.clear();
    attachments.clear();
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
      attachments: outgoingAttachments,
    );
    messages.add(optimisticMsg);

    bool socketSent = false;
    if (Get.isRegistered<ConstructionSocketService>()) {
      final socket = Get.find<ConstructionSocketService>();
      if (socket.isConnected.value) {
        if (dept != null) {
          final chId = dept.id;
          socketSent = socket.sendTeamMessage(
            'group',
            chId,
            text,
            attachments: outgoingAttachments,
          );
        } else if (contact != null) {
          socketSent = socket.sendTeamMessage(
            'direct',
            contact.id,
            text,
            attachments: outgoingAttachments,
          );
        }
      }
    }

    // If socket is not connected or failed to send, fall back to REST API
    if (!socketSent && outgoingAttachments.isNotEmpty) {
      messages.removeWhere((m) => m.id == optimisticMsg.id);
      attachments.assignAll(outgoingAttachments);
      messageController.text = text;
      Get.snackbar('Message not sent', 'Please retry when connected.');
      return;
    }
    if (!socketSent) {
      final sent = dept != null
          ? await _service.sendGroupMessage(dept.id, text)
          : await _service.sendDirectMessage(contact!.id, text);
      if (!sent) {
        messages.removeWhere((m) => m.id == optimisticMsg.id);
        if (messageController.text.isEmpty) messageController.text = text;
        Get.snackbar('Message not sent', 'Please retry when connected.');
      } else if (selectedDepartmentId.value == dept?.id &&
          selectedContactId.value == contact?.id) {
        fetchMessagesForActiveChat();
      }
    }
  }

  void _handleSocketEvent(ConstructionSocketEvent event) {
    AppLogger.i(
      'ChatController received socket event: ${event.name}',
      tag: 'CHAT',
    );

    if (event.name == 'team_chat_error') {
      final failed = messages.reversed.toList().firstWhereOrNull(
        (m) => m.id.startsWith('local_'),
      );
      if (failed != null) {
        attachments.addAll(failed.attachments);
        messages.removeWhere((m) => m.id == failed.id);
        if (messageController.text.isEmpty) {
          messageController.text = failed.message;
        }
      }
      Get.snackbar(
        'Chat error',
        (event.payload['message'] ?? 'Unable to send message. Please retry.')
            .toString(),
      );
      return;
    }
    if (event.name == 'team_typing') {
      if (!_matchesCurrentChannel(event.payload)) return;
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
                  m.attachments.map((a) => a['url']).join('|') ==
                      newMsg.attachments.map((a) => a['url']).join('|') &&
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
                m.attachments.map((a) => a['url']).join('|') ==
                    newMsg.attachments.map((a) => a['url']).join('|') &&
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
    if (channelType == 'group') {
      final dept = activeDepartment;
      if (dept == null) return false;
      return (payload['groupId'] ?? payload['channelId'])?.toString() ==
          dept.id;
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
    super.onClose();
  }
}
