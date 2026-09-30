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
  OverlayEntry? _entry;
  Worker? _closeWorker;

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
    super.dispose();
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  void _toggle() {
    if (_entry != null || _controller.dropdownOpen.value) {
      _controller.closeDropdown();
      return;
    }
    _controller.dropdownOpen.value = true;
    _showOverlay();
  }

  Widget _buildProjectIcon(String imageAsset) {
    if (imageAsset.isEmpty) {
      return const Icon(
        Icons.business_rounded,
        size: 22,
        color: AppColors.textSecondary,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Image.asset(
        imageAsset,
        width: 30,
        height: 20,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.business_rounded,
          size: 22,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showOverlay() {
    final size = MediaQuery.sizeOf(context);
    final menuWidth = (size.width * 0.28).clamp(240.0, 320.0);
    final valueSize = (size.width * 0.010).clamp(11.0, 13.0);

    _entry = OverlayEntry(
      builder: (context) {
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
              offset: Offset(0, size.height * 0.052),
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: menuWidth,
                  constraints: BoxConstraints(maxHeight: size.height * 0.38),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: _controller.projects.map((p) {
                      return InkWell(
                        onTap: () => _controller.selectProject(p.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              _buildProjectIcon(p.imageAsset),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.id.isEmpty
                                      ? p.name
                                      : '${p.name} (${p.code})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: valueSize,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(10.0, 12.0);
    final valueSize = (size.width * 0.010).clamp(11.0, 13.0);
    final menuWidth = (size.width * 0.28).clamp(240.0, 320.0);

    return GetBuilder<ProjectCalendarController>(
      id: AppGetIds.projectDropdown,
      builder: (controller) {
        final selected = _controller.selectedProject;
        final open = _controller.dropdownOpen.value;
        final displayTitle = (selected == null || selected.id.isEmpty)
            ? 'All Projects'
            : '${selected.name} (${selected.code})';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Select Project',
              style: TextStyle(
                fontSize: labelSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: size.height * 0.006),
            CompositedTransformTarget(
              link: _link,
              child: GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: menuWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      _buildProjectIcon(selected?.imageAsset ?? ''),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: valueSize,
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
                        size: 20,
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
  }
}
