import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_models.dart';

class ChatController extends GetxController {
  final messageController = TextEditingController();
  final searchController = TextEditingController();

  final activeTab = ChatTab.departments.obs;
  final selectedDepartmentId = RxnString('marketing');
  final selectedContactId = RxnString();

  final isInfoPanelOpen = false.obs;
  final activeInfoTab = InfoPanelTab.members.obs;
  final isMuted = false.obs;

  final departments = const <DepartmentChannel>[
    DepartmentChannel(
      id: 'marketing',
      title: 'Marketing Team',
      subtitle: '2 members . Marketing',
      icon: Icons.campaign_rounded,
      iconColor: Color(0xFF2563EB),
      unreadCount: 3,
    ),
    DepartmentChannel(
      id: 'accounting',
      title: 'Accounting Team',
      subtitle: '4 members . Accounting',
      icon: Icons.receipt_long_rounded,
      iconColor: Color(0xFF10B981),
      unreadCount: 0,
    ),
    DepartmentChannel(
      id: 'construction',
      title: 'Construction Team',
      subtitle: '6 members . Construction',
      icon: Icons.handyman_rounded,
      iconColor: Color(0xFFF59E0B),
      unreadCount: 1,
    ),
    DepartmentChannel(
      id: 'plant',
      title: 'Plant Management',
      subtitle: '3 members . Plant',
      icon: Icons.precision_manufacturing_rounded,
      iconColor: Color(0xFF8B5CF6),
      unreadCount: 0,
    ),
  ];

  final contacts = const <DirectContact>[
    DirectContact(id: 'michael', name: 'Michael Chen', role: 'Plant Supervisor'),
    DirectContact(id: 'alex', name: 'Alex Turner', role: 'Logistics Manager'),
    DirectContact(id: 'john', name: 'John Doe', role: 'Marketing Lead'),
  ];

  final messages = <ChatMessage>[
    const ChatMessage(
      id: '1',
      senderName: 'John Doe',
      message: 'Hi, I need a quote for a 40*60 workshop in Texas.',
      timestamp: '2024-10-10 09:30 pm',
      isMe: false,
    ),
    const ChatMessage(
      id: '2',
      senderName: 'Sarah Lee',
      message: "Hello John! I'd be happy to help you with that. Can you tell me more about the intended use and any specific requirements?",
      timestamp: '2024-10-10 09:30 pm',
      isMe: true,
    ),
    const ChatMessage(
      id: '3',
      senderName: 'Artificial Intelligence',
      message: 'Okay Sir, sending details to your inbox',
      timestamp: '2024-10-10 09:30 pm',
      isMe: false,
      isAi: true,
    ),
  ].obs;

  final members = const <ChatMember>[
    ChatMember(id: 'm1', name: 'John Doe', role: 'Marketing', isAdmin: true),
    ChatMember(id: 'm2', name: 'James Wilson', role: 'Marketing'),
  ];

  final files = const <ChatFile>[
    ChatFile(id: 'f1', fileName: 'Q1-Marketing-Budget-2024', author: 'Sarah Johnson'),
  ];

  DepartmentChannel? get activeDepartment {
    if (selectedDepartmentId.value == null) return null;
    return departments.firstWhereOrNull((d) => d.id == selectedDepartmentId.value);
  }

  DirectContact? get activeContact {
    if (selectedContactId.value == null) return null;
    return contacts.firstWhereOrNull((c) => c.id == selectedContactId.value);
  }

  void switchTab(ChatTab tab) {
    activeTab.value = tab;
    if (tab == ChatTab.departments) {
      selectedDepartmentId.value = 'marketing';
      selectedContactId.value = null;
    } else {
      selectedDepartmentId.value = null;
      selectedContactId.value = null; // Empty chat state as shown in Image 5
    }
  }

  void selectDepartment(String id) {
    selectedDepartmentId.value = id;
    selectedContactId.value = null;
  }

  void selectContact(String id) {
    selectedContactId.value = id;
    selectedDepartmentId.value = null;
  }

  void toggleInfoPanel() {
    isInfoPanelOpen.value = !isInfoPanelOpen.value;
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderName: 'Sarah Lee',
      message: text,
      timestamp: '2024-10-10 09:31 pm',
      isMe: true,
    ));
    messageController.clear();
  }

  @override
  void onClose() {
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
