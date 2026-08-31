import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_models.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AppScaffold(
      menuTitle: 'Chat / Messaging',
      body: Container(
        margin: EdgeInsets.all(size.width * 0.012),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // ─── Left Sidebar (Width ~300) ───────────────────────────────────
            SizedBox(
              width: (size.width * 0.24).clamp(260.0, 320.0),
              child: _LeftSidebar(controller: controller),
            ),
            const VerticalDivider(width: 1, color: AppColors.cardBorder),

            // ─── Center Chat Thread / Main Panel ─────────────────────────────
            Expanded(
              child: Obx(() {
                final dept = controller.activeDepartment;
                final contact = controller.activeContact;
                if (dept == null && contact == null) {
                  return const _EmptyChatState();
                }
                return _CenterChatPanel(
                  controller: controller,
                  dept: dept,
                  contact: contact,
                );
              }),
            ),

            // ─── Right Info Panel (Drawer) ─────────────────────────────────
            Obx(() {
              if (!controller.isInfoPanelOpen.value) return const SizedBox.shrink();
              return Row(
                children: [
                  const VerticalDivider(width: 1, color: AppColors.cardBorder),
                  SizedBox(
                    width: (size.width * 0.24).clamp(260.0, 320.0),
                    child: _RightInfoPanel(controller: controller),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Left Sidebar ─────────────────────────────────────────────────────────────

class _LeftSidebar extends StatelessWidget {
  const _LeftSidebar({required this.controller});
  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // User Profile Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE2E8F0),
                    child: const Icon(Icons.person, color: Color(0xFF64748B)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sarah Johnson',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Marketing',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: controller.searchController,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search chats...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Tab Selector (Departments vs Direct)
        Obx(() {
          final activeTab = controller.activeTab.value;
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.switchTab(ChatTab.departments),
                      child: Column(
                        children: [
                          Text(
                            'Departments',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: activeTab == ChatTab.departments
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: activeTab == ChatTab.departments
                                  ? AppColors.primaryBlue
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            color: activeTab == ChatTab.departments
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.switchTab(ChatTab.direct),
                      child: Column(
                        children: [
                          Text(
                            'Direct',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: activeTab == ChatTab.direct
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: activeTab == ChatTab.direct
                                  ? AppColors.primaryBlue
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            color: activeTab == ChatTab.direct
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
            ],
          );
        }),

        // List View (Departments or Direct)
        Expanded(
          child: Obx(() {
            final activeTab = controller.activeTab.value;
            if (activeTab == ChatTab.departments) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.departments.length,
                itemBuilder: (context, index) {
                  final dept = controller.departments[index];
                  return Obx(() {
                    final selected = controller.selectedDepartmentId.value == dept.id;
                    return Container(
                      color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
                      child: ListTile(
                        onTap: () => controller.selectDepartment(dept.id),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: dept.iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(dept.icon, size: 20, color: dept.iconColor),
                        ),
                        title: Text(
                          dept.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: dept.unreadCount > 0
                            ? Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${dept.unreadCount}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  });
                },
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: controller.contacts.length,
              itemBuilder: (context, index) {
                final contact = controller.contacts[index];
                return Obx(() {
                  final selected = controller.selectedContactId.value == contact.id;
                  return Container(
                    color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
                    child: ListTile(
                      onTap: () => controller.selectContact(contact.id),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE2E8F0),
                        child: Text(
                          contact.name[0],
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      title: Text(
                        contact.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                });
              },
            );
          }),
        ),

        // Bottom Section: + New Chat & Status bar
        const Divider(height: 1, color: AppColors.cardBorder),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16, color: AppColors.textSecondary),
            label: const Text(
              'New Chat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFF8FAFC),
          child: const Row(
            children: [
              Icon(Icons.circle, size: 8, color: Color(0xFF22C55E)),
              SizedBox(width: 6),
              Text(
                'Online • 4 users online',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Spacer(),
              Text(
                'Last sync: just now',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Center Chat Panel ────────────────────────────────────────────────────────

class _CenterChatPanel extends StatelessWidget {
  const _CenterChatPanel({
    required this.controller,
    required this.dept,
    required this.contact,
  });

  final ChatController controller;
  final DepartmentChannel? dept;
  final DirectContact? contact;

  @override
  Widget build(BuildContext context) {
    final title = dept?.title ?? contact?.name ?? '';
    final subtitle = dept?.subtitle ?? contact?.role ?? '';
    final icon = dept?.icon ?? Icons.person;
    final iconColor = dept?.iconColor ?? AppColors.primaryBlue;

    return Column(
      children: [
        // Top Channel Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.textSecondary),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.videocam_outlined, size: 22, color: AppColors.textSecondary),
              ),
              IconButton(
                onPressed: controller.toggleInfoPanel,
                icon: const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        // Messages List
        Expanded(
          child: Obx(() {
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                return _ChatMessageBubble(msg: msg);
              },
            );
          }),
        ),

        // Bottom Input Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.cardBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.messageController,
                  onSubmitted: (_) => controller.sendMessage(),
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: controller.sendMessage,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Chat Message Bubble Component ───────────────────────────────────────────

class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({required this.msg});
  final ChatMessage msg;

  @override
  Widget build(BuildContext context) {
    if (msg.isMe) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg.senderName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.message,
                          style: const TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          msg.timestamp,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF991B1B),
              child: Text(
                msg.senderName[0],
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: msg.isAi ? const Color(0xFFFEF3C7) : const Color(0xFFE2E8F0),
            child: msg.isAi
                ? const Icon(Icons.smart_toy_outlined, size: 18, color: Color(0xFFD97706))
                : Text(
                    msg.senderName[0],
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.message,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        msg.timestamp,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Chat State (Image 5) ───────────────────────────────────────────────

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 32,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select a chat to start messaging',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose from your departments, direct messages, or cross-department channels',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.cardBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  enabled: false,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Right Info Panel (Images 2 & 3) ──────────────────────────────────────────

class _RightInfoPanel extends StatelessWidget {
  const _RightInfoPanel({required this.controller});
  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: controller.toggleInfoPanel,
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.campaign_rounded, size: 20, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marketing Team',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '2 members . Marketing',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Marketing department discussions and campaigns',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Center(
                child: Obx(() {
                  final muted = controller.isMuted.value;
                  return OutlinedButton.icon(
                    onPressed: () => controller.isMuted.value = !muted,
                    icon: Icon(
                      muted ? Icons.notifications_off_outlined : Icons.notifications_none_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    label: Text(
                      muted ? 'Unmute' : 'Mute',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // Sub Tabs: Members vs Files
        Obx(() {
          final tab = controller.activeInfoTab.value;
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.activeInfoTab.value = InfoPanelTab.members,
                      child: Column(
                        children: [
                          Text(
                            'Members',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: tab == InfoPanelTab.members ? FontWeight.w700 : FontWeight.w500,
                              color: tab == InfoPanelTab.members ? AppColors.primaryBlue : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            color: tab == InfoPanelTab.members ? AppColors.primaryBlue : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.activeInfoTab.value = InfoPanelTab.files,
                      child: Column(
                        children: [
                          Text(
                            'Files',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: tab == InfoPanelTab.files ? FontWeight.w700 : FontWeight.w500,
                              color: tab == InfoPanelTab.files ? AppColors.primaryBlue : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            color: tab == InfoPanelTab.files ? AppColors.primaryBlue : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
            ],
          );
        }),

        // Tab Content
        Expanded(
          child: Obx(() {
            final tab = controller.activeInfoTab.value;
            if (tab == InfoPanelTab.members) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...controller.members.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFE2E8F0),
                            child: Text(
                              m.name[0],
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                Text(
                                  m.role,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (m.isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 16, color: AppColors.textSecondary),
                    label: const Text(
                      'Add member',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...controller.files.map(
                  (f) => Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.article_outlined, size: 18, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.fileName,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              Text(
                                f.author,
                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
