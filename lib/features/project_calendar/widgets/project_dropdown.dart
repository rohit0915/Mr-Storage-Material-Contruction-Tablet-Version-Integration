import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/project_calendar_controller.dart';

class ProjectDropdown extends StatefulWidget {
  const ProjectDropdown({super.key});

  @override
  State<ProjectDropdown> createState() => _ProjectDropdownState();
}

class _ProjectDropdownState extends State<ProjectDropdown> {
  final _link = LayerLink();
  final _controller = Get.find<ProjectCalendarController>();
  final _searchController = TextEditingController();
  OverlayEntry? _entry;
  Worker? _closeWorker;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _closeWorker = ever<bool>(_controller.dropdownOpen, (open) {
      if (!open) _removeOverlay();
    });
  }

  @override
  void dispose() {
    _closeWorker?.dispose();
    _removeOverlay();
    _searchController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
    _searchQuery = '';
  }

  void _toggle() {
    if (_entry != null || _controller.dropdownOpen.value) {
      _controller.closeDropdown();
      return;
    }
    _controller.dropdownOpen.value = true;
    _showOverlay();
  }

  void _showOverlay() {
    _searchQuery = '';
    _searchController.clear();
    final size = MediaQuery.sizeOf(context);
    final menuWidth = (size.width * 0.28).clamp(240.0, 320.0);

    _entry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setOverlayState) {
            final filteredProjects = _controller.projects.where((p) {
              if (_searchQuery.isEmpty) return true;
              final title = p.id.isEmpty
                  ? p.name.toLowerCase()
                  : '${p.name} (${p.code})'.toLowerCase();
              return title.contains(_searchQuery) ||
                  p.name.toLowerCase().contains(_searchQuery) ||
                  p.code.toLowerCase().contains(_searchQuery);
            }).toList();

            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _controller.closeDropdown,
                  ),
                ),
                CompositedTransformFollower(
                  link: _link,
                  showWhenUnlinked: false,
                  offset: const Offset(0, 44),
                  child: Material(
                    elevation: 8,
                    shadowColor: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: menuWidth,
                      constraints: BoxConstraints(maxHeight: size.height * 0.38),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Search Bar
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 36,
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setOverlayState(() {
                                    _searchQuery = val.trim().toLowerCase();
                                  });
                                },
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          // Items List
                          Flexible(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: filteredProjects.map((p) {
                                final title = p.id.isEmpty
                                    ? p.name
                                    : (p.code.isNotEmpty
                                        ? '${p.name} (${p.code})'
                                        : p.name);
                                final isSelected =
                                    (_controller.selectedProject?.id == p.id) ||
                                        (_controller.selectedProjectId.value
                                                .isEmpty &&
                                            p.id.isEmpty);

                                return InkWell(
                                  onTap: () {
                                    _controller.selectProject(p.id);
                                    _controller.closeDropdown();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    color: isSelected
                                        ? const Color(0xFFF8FAFC)
                                        : Colors.white,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: AppColors.textPrimary,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final menuWidth = (size.width * 0.28).clamp(240.0, 320.0);

    return GetBuilder<ProjectCalendarController>(
      id: AppGetIds.projectDropdown,
      builder: (controller) {
        final selected = _controller.selectedProject;
        final open = _controller.dropdownOpen.value;
        final displayTitle = (selected == null || selected.id.isEmpty)
            ? 'All Projects'
            : (selected.code.isNotEmpty
                ? '${selected.name} (${selected.code})'
                : selected.name);

        return CompositedTransformTarget(
          link: _link,
          child: GestureDetector(
            onTap: _toggle,
            child: Container(
              width: menuWidth,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
