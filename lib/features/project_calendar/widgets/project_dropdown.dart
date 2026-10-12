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
                    elevation: 10,
                    shadowColor: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: menuWidth,
                      constraints: BoxConstraints(
                        maxHeight: (size.height * 0.40).clamp(240.0, 360.0),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                                  hintText: 'Search projects...',
                                  hintStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 14),
                                          splashRadius: 14,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          color: AppColors.textSecondary,
                                          onPressed: () {
                                            _searchController.clear();
                                            setOverlayState(() => _searchQuery = '');
                                          },
                                        )
                                      : null,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
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
                          if (filteredProjects.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              child: Text(
                                'No matching projects found',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            Flexible(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                shrinkWrap: true,
                                children: filteredProjects.map((p) {
                                  final isAll = p.id.isEmpty;
                                  final isSelected =
                                      (_controller.selectedProject?.id == p.id) ||
                                          (_controller.selectedProjectId.value
                                                  .isEmpty &&
                                              isAll);

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      _controller.selectProject(p.id);
                                      _controller.closeDropdown();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 2),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFEFF6FF)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isAll
                                                ? Icons.layers_outlined
                                                : Icons.business_rounded,
                                            size: 16,
                                            color: isSelected
                                                ? AppColors.primaryBlue
                                                : const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    p.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                      color: isSelected
                                                          ? AppColors.primaryBlue
                                                          : AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                if (p.code.isNotEmpty) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 1.5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFF1F5F9),
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(
                                                        color: const Color(0xFFE2E8F0),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      p.code,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF475569),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              size: 16,
                                              color: AppColors.primaryBlue,
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
        final isAll = selected == null || selected.id.isEmpty;
        final displayName = isAll ? 'All Projects' : selected.name;
        final displayCode = isAll ? '' : selected.code;

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
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(
                    isAll ? Icons.layers_outlined : Icons.business_rounded,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (displayCode.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              displayCode,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ],
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
