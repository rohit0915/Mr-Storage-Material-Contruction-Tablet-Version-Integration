import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/walkthrough/services/walkthrough_registry.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../controllers/drawings_controller.dart';
import '../models/drawing_models.dart';

String formatToSlashDate(String rawDate) {
  if (rawDate.isEmpty || rawDate == '-') return '-';
  final dt = DateTime.tryParse(rawDate);
  if (dt != null) {
    return DateFormat('dd/MM/yyyy').format(dt.toLocal());
  }
  if (rawDate.contains('/')) return rawDate;
  return rawDate;
}

String formatToMediumDate(String rawDate) {
  if (rawDate.isEmpty || rawDate == '-') return '-';
  final dt = DateTime.tryParse(rawDate);
  if (dt != null) {
    return DateFormat('MMM d, yyyy').format(dt.toLocal());
  }
  return rawDate;
}

class DrawingsView extends GetView<DrawingsController> {
  const DrawingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = (size.width * 0.02).clamp(14.0, 24.0);
    final padV = (size.height * 0.016).clamp(12.0, 20.0);
    final gap = (size.height * 0.014).clamp(10.0, 16.0);

    final isGlobalView = controller.scopedLeadId.isEmpty;

    return AppScaffold(
      menuTitle: 'Drawings & Attachments',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Screen Header: Back button, Title & Upload button
            Obx(() {
              final projects = controller.projectList;
              final firstProject = projects.isNotEmpty ? projects.first : null;
              final projectName = controller.scopedProjectName.isNotEmpty
                  ? controller.scopedProjectName
                  : (firstProject?.name.isNotEmpty == true
                      ? firstProject!.name
                      : 'Lucas project');

              if (isGlobalView) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drawings & Attachments',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: (size.width * 0.018).clamp(20.0, 26.0),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'View engineering drawings and upload site progress photos & videos for active projects.',
                            style: TextStyle(
                              fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      key: WalkthroughRegistry.instance.getKey(WalkthroughRegistry.drawingsUploadBtn),
                      onPressed: () => controller.openUpload(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Upload Photos & Videos',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Get.back();
                      } else {
                        Get.back();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$projectName - Drawings & Media',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: (size.width * 0.018).clamp(20.0, 26.0),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Engineering building drawings and site walkthrough photos & videos',
                          style: TextStyle(
                            fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => controller.openUpload(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Upload Photos & Videos',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: gap + 2),

            // Top Tabs Row: All Files, Photos & Videos, Drawings
            Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TabPill(
                      label: 'All Files',
                      count: controller.totalAllFilesCount,
                      isSelected: controller.selectedTab.value ==
                          DrawingTabType.allFiles,
                      icon: null,
                      onTap: () =>
                          controller.setTab(DrawingTabType.allFiles),
                    ),
                    const SizedBox(width: 10),
                    _TabPill(
                      label: 'Photos & Videos',
                      count: controller.totalPhotosVideosCount,
                      isSelected: controller.selectedTab.value ==
                          DrawingTabType.photosVideos,
                      icon: Icons.photo_camera_outlined,
                      onTap: () =>
                          controller.setTab(DrawingTabType.photosVideos),
                    ),
                    const SizedBox(width: 10),
                    _TabPill(
                      label: 'Drawings',
                      count: controller.totalDrawingsCount,
                      isSelected: controller.selectedTab.value ==
                          DrawingTabType.drawings,
                      icon: Icons.description_outlined,
                      onTap: () =>
                          controller.setTab(DrawingTabType.drawings),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: gap),

            // Search Bar & Filter Controls Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 640;
                  final searchField = SizedBox(
                    height: 40,
                    child: TextField(
                      controller: controller.localSearchController,
                      onChanged: controller.onSearchChanged,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search leads, projects, files...',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                      ),
                    ),
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        searchField,
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _SecondaryFilterBar(controller: controller),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: searchField),
                      const SizedBox(width: 14),
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _SecondaryFilterBar(controller: controller),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: gap + 4),

            // Main Content Area: Site Photos & Videos and Building Drawings Cards
            Obx(() {
              if (controller.isLoading.value) {
                return const AppShimmerGrid(
                  itemCount: 4,
                  crossAxisCount: 2,
                );
              }

              final projects = controller.filteredProjects;
              if (projects.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'No projects found',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try adjusting your search criteria or upload photos/videos for a project.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => controller.openUpload(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Upload Photos & Videos'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: projects
                    .map(
                      (p) => Padding(
                        padding: EdgeInsets.only(bottom: gap + 4),
                        child: isGlobalView
                            ? _GlobalProjectDrawingsCard(project: p)
                            : _ProjectDrawingsGroupView(project: p),
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.count,
    required this.isSelected,
    this.icon,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.10),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEFF6FF)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryFilterBar extends StatelessWidget {
  const _SecondaryFilterBar({required this.controller});

  final DrawingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = controller.selectedTab.value;
      if (tab == DrawingTabType.drawings) {
        final selectedStatus = controller.selectedStatusFilter.value;
        const statuses = [
          'all',
          'Approved',
          'Rejected',
          'Pending Review',
          'Revision Required',
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              final isSel = selectedStatus == status;
              final label = status == 'all' ? 'All Statuses' : status;
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: InkWell(
                  onTap: () => controller.setStatusFilter(status),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSel
                            ? AppColors.primaryBlue
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel
                            ? AppColors.primaryBlue
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }

      // Media filter: All Media, Photos, Videos
      final selected = controller.selectedMediaFilter.value;
      return Container(
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMediaFilterItem(
              label: 'All Media',
              icon: null,
              isSelected: selected == MediaFilterType.allMedia,
              onTap: () => controller.setMediaFilter(MediaFilterType.allMedia),
            ),
            _buildMediaFilterItem(
              label: 'Photos',
              icon: Icons.photo_outlined,
              isSelected: selected == MediaFilterType.photos,
              onTap: () => controller.setMediaFilter(MediaFilterType.photos),
            ),
            _buildMediaFilterItem(
              label: 'Videos',
              icon: Icons.videocam_outlined,
              isSelected: selected == MediaFilterType.videos,
              onTap: () => controller.setMediaFilter(MediaFilterType.videos),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMediaFilterItem({
    required String label,
    required IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobalProjectDrawingsCard extends GetView<DrawingsController> {
  const _GlobalProjectDrawingsCard({required this.project});

  final DrawingProjectItem project;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = controller.selectedTab.value;
      final displayFiles = controller.getDisplayFiles(project);

      String sectionTitle;
      if (tab == DrawingTabType.photosVideos) {
        sectionTitle = 'SITE PHOTOS & VIDEOS';
      } else if (tab == DrawingTabType.drawings) {
        sectionTitle = 'ENGINEERING & FABRICATION DRAWINGS';
      } else {
        sectionTitle = 'PROJECT ATTACHMENTS & DRAWINGS';
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Project Header Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 650;
                final leftMeta = Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        project.code.isNotEmpty ? project.code : 'PRO',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    if (project.photoCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_camera_outlined,
                              size: 13,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${project.photoCount} ${project.photoCount == 1 ? 'Photo' : 'Photos'}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (project.videoCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.videocam_outlined,
                              size: 14,
                              color: Color(0xFF7C3AED),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${project.videoCount} ${project.videoCount == 1 ? 'Video' : 'Videos'}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );

                final rightMeta = Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LOCATION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          project.location.isNotEmpty ? project.location : '-',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LAST UPDATED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatToSlashDate(project.lastUpdate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () => controller.openUpload(
                        context,
                        projectId: project.id.isNotEmpty
                            ? project.id
                            : project.code,
                      ),
                      icon: const Icon(
                        Icons.add,
                        size: 14,
                        color: AppColors.primaryBlue,
                      ),
                      label: const Text(
                        'Add Media',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leftMeta,
                      const SizedBox(height: 12),
                      rightMeta,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: leftMeta),
                    const SizedBox(width: 16),
                    rightMeta,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),

            // Section Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sectionTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${displayFiles.length} ${displayFiles.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Files Grid or Empty State
            if (displayFiles.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'No ${tab == DrawingTabType.drawings ? 'drawings' : 'photos or videos'} available for this project.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => controller.openUpload(
                          context,
                          projectId: project.id.isNotEmpty
                              ? project.id
                              : project.code,
                        ),
                        child: Text(
                          '+ Upload ${tab == DrawingTabType.drawings ? 'drawing' : 'photo or video'} for this project',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final int crossAxisCount =
                      width >= 900 ? 3 : (width >= 560 ? 2 : 1);
                  final double cardWidth =
                      (width - (crossAxisCount - 1) * 14) / crossAxisCount;

                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: displayFiles
                        .map(
                          (f) => SizedBox(
                            width: cardWidth,
                            child: _GlobalFileCard(file: f),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
          ],
        ),
      );
    });
  }
}

class _GlobalFileCard extends GetView<DrawingsController> {
  const _GlobalFileCard({required this.file});

  final DrawingFileItem file;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.openFilePreview(context, file),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 42x42 Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: _buildThumbnail(),
                ),
              ),
              const SizedBox(width: 12),

              // Title and date/type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${file.typeLabel} • ${formatToSlashDate(file.receivedOn)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Bottom Row: Status badge on left, Download & View buttons on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => controller.downloadFile(context, file),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => controller.openFilePreview(context, file),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        size: 17,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildThumbnail() {
    if (file.fileType == DrawingFileType.image) {
      final url = file.fileUrl.isNotEmpty
          ? file.fileUrl
          : (file.previewAssets.isNotEmpty ? file.previewAssets.first : '');
      if (url.startsWith('http')) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _defaultImageThumb(),
        );
      }
      return _defaultImageThumb();
    } else if (file.fileType == DrawingFileType.video) {
      return Container(
        color: const Color(0xFFFAF5FF),
        child: const Center(
          child: Icon(
            Icons.videocam_outlined,
            size: 22,
            color: Color(0xFF7C3AED),
          ),
        ),
      );
    } else {
      return Container(
        color: const Color(0xFFFEF2F2),
        child: const Center(
          child: Icon(
            Icons.picture_as_pdf_outlined,
            size: 22,
            color: Color(0xFFDC2626),
          ),
        ),
      );
    }
  }

  Widget _defaultImageThumb() {
    return Container(
      color: const Color(0xFFEFF6FF),
      child: const Center(
        child: Icon(
          Icons.photo_outlined,
          size: 20,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bg = const Color(0xFFEFF6FF);
    Color border = const Color(0xFFBFDBFE);
    Color text = const Color(0xFF1D4ED8);

    final s = file.status.toLowerCase();
    if (s.contains('reject') || s.contains('revision')) {
      bg = const Color(0xFFFEE2E2);
      border = const Color(0xFFFECACA);
      text = const Color(0xFFDC2626);
    } else if (s.contains('pending')) {
      bg = const Color(0xFFFEF9C3);
      border = const Color(0xFFFEF08A);
      text = const Color(0xFFB45309);
    } else if (s.contains('approve')) {
      bg = const Color(0xFFDCFCE7);
      border = const Color(0xFFBBF7D0);
      text = const Color(0xFF16A34A);
    } else if (file.isVideo || s.contains('video')) {
      bg = const Color(0xFFFAF5FF);
      border = const Color(0xFFE9D5FF);
      text = const Color(0xFF7C3AED);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(
        file.status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}

class _ProjectDrawingsGroupView extends GetView<DrawingsController> {
  const _ProjectDrawingsGroupView({required this.project});

  final DrawingProjectItem project;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = controller.selectedTab.value;
      final showMedia =
          tab == DrawingTabType.allFiles || tab == DrawingTabType.photosVideos;
      final showDrawings =
          tab == DrawingTabType.allFiles || tab == DrawingTabType.drawings;

      final filteredMedia = controller.getFilteredMedia(project);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Site Photos & Videos Section
          if (showMedia) ...[
            _SiteMediaSectionCard(
              project: project,
              mediaItems: filteredMedia,
            ),
            const SizedBox(height: 16),
          ],

          // 2. Building <N> Drawings Sections
          if (showDrawings) ...[
            if (project.effectiveBuildings.isEmpty)
              _EmptyBuildingDrawingsCard(project: project)
            else
              ...project.effectiveBuildings.map((building) {
                final filteredDrawings =
                    controller.getFilteredBuildingDrawings(building);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _BuildingDrawingsCard(
                    building: building,
                    drawings: filteredDrawings,
                  ),
                );
              }),
          ],
        ],
      );
    });
  }
}

class _SiteMediaSectionCard extends GetView<DrawingsController> {
  const _SiteMediaSectionCard({
    required this.project,
    required this.mediaItems,
  });

  final DrawingProjectItem project;
  final List<DrawingFileItem> mediaItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header: Site Photos & Videos (count) + Upload Media button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 20,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Site Photos & Videos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${mediaItems.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () =>
                    controller.openUpload(context, projectId: project.id),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 15, color: AppColors.primaryBlue),
                      SizedBox(width: 4),
                      Text(
                        'Upload Media',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid of Media items or empty box
          if (mediaItems.isEmpty)
            _EmptyStateBox(
              message: 'No site photos or videos match the current filter.',
              actionText: '+ Upload a photo or video',
              onAction: () =>
                  controller.openUpload(context, projectId: project.id),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final int crossAxisCount =
                    width >= 860 ? 3 : (width >= 560 ? 2 : 1);
                final double cardWidth =
                    (width - (crossAxisCount - 1) * 14) / crossAxisCount;

                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: mediaItems
                      .map(
                        (f) => SizedBox(
                          width: cardWidth,
                          child: _MediaItemCard(file: f),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MediaItemCard extends GetView<DrawingsController> {
  const _MediaItemCard({required this.file});

  final DrawingFileItem file;

  @override
  Widget build(BuildContext context) {
    final isVideo = file.isVideo;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.openFilePreview(context, file),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: _buildThumbnail(),
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formatToMediumDate(file.receivedOn),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Download & View Icons
                InkWell(
                  onTap: () => controller.downloadFile(context, file),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => controller.openFilePreview(context, file),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.remove_red_eye_outlined,
                      size: 17,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Badge Top Right (Photo / Video)
          Positioned(
            top: -9,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isVideo ? const Color(0xFFFAF5FF) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isVideo
                      ? const Color(0xFFE9D5FF)
                      : const Color(0xFFBFDBFE),
                ),
              ),
              child: Text(
                isVideo ? 'Video' : 'Photo',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isVideo
                      ? const Color(0xFF7E22CE)
                      : const Color(0xFF1D4ED8),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildThumbnail() {
    final url = file.fileUrl.isNotEmpty
        ? file.fileUrl
        : (file.previewAssets.isNotEmpty ? file.previewAssets.first : '');

    if (file.isVideo) {
      return Container(
        color: const Color(0xFF0F172A),
        child: const Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFEFF6FF),
          child: const Icon(
            Icons.photo_outlined,
            color: AppColors.primaryBlue,
            size: 22,
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFEFF6FF),
      child: const Icon(
        Icons.photo_outlined,
        color: AppColors.primaryBlue,
        size: 22,
      ),
    );
  }
}

class _BuildingDrawingsCard extends GetView<DrawingsController> {
  const _BuildingDrawingsCard({
    required this.building,
    required this.drawings,
  });

  final BuildingDrawingGroup building;
  final List<DrawingFileItem> drawings;

  @override
  Widget build(BuildContext context) {
    final statusBadge = _buildStatusBadge(building.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Building <N> Drawings [Status] ... <N> sheets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Building ${building.buildingNumber} Drawings',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  statusBadge,
                ],
              ),
              Text(
                '${building.sheetCount} ${building.sheetCount == 1 ? 'sheet' : 'sheets'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Drawings Grid
          if (drawings.isEmpty)
            _EmptyStateBox(
              message: 'No drawings match the current filter.',
              actionText: '+ Upload drawing for this building',
              onAction: () => controller.openUpload(context),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final int crossAxisCount =
                    width >= 860 ? 3 : (width >= 560 ? 2 : 1);
                final double cardWidth =
                    (width - (crossAxisCount - 1) * 14) / crossAxisCount;

                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: drawings
                      .map(
                        (f) => SizedBox(
                          width: cardWidth,
                          child: _DrawingItemCard(file: f),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    Color bg = const Color(0xFFDCFCE7);
    Color text = const Color(0xFF16A34A);
    Color border = const Color(0xFFBBF7D0);

    if (s.contains('reject')) {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
      border = const Color(0xFFFECACA);
    } else if (s.contains('pending')) {
      bg = const Color(0xFFFEFAE2);
      text = const Color(0xFFD97706);
      border = const Color(0xFFFEF08A);
    } else if (s.contains('revision')) {
      bg = const Color(0xFFFFF7ED);
      text = const Color(0xFFEA580C);
      border = const Color(0xFFFFEDD5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}

class _DrawingItemCard extends GetView<DrawingsController> {
  const _DrawingItemCard({required this.file});

  final DrawingFileItem file;

  @override
  Widget build(BuildContext context) {
    final isRejected = file.status.toLowerCase().contains('reject');
    final hasRejectionReason = isRejected && file.rejectionReason.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.openFilePreview(context, file),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Thumbnail / PDF Icon
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: _buildDrawingThumbnail(),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // File Name & Version
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            file.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            file.versionLabel.isNotEmpty
                                ? file.versionLabel
                                : 'Version 1',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Download & View Icons
                    InkWell(
                      onTap: () => controller.downloadFile(context, file),
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.openFilePreview(context, file),
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.remove_red_eye_outlined,
                          size: 17,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),

                // Rejection Reason Alert if Rejected (as seen in Image 1: (!) Reason: ...)
                if (hasRejectionReason) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFFEE2E2)),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 13,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Reason: ${file.rejectionReason}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Floating Status Badge on Top Right
          Positioned(
            top: -9,
            right: 12,
            child: _buildBadge(file.status),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildDrawingThumbnail() {
    final url = file.fileUrl.isNotEmpty
        ? file.fileUrl
        : (file.previewAssets.isNotEmpty ? file.previewAssets.first : '');

    final isImg = file.fileType == DrawingFileType.image ||
        url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.webp');

    if (isImg &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFFEF2F2),
          child: const Icon(
            Icons.picture_as_pdf_rounded,
            color: Color(0xFFEF4444),
            size: 24,
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFFEF2F2),
      child: const Center(
        child: Icon(
          Icons.picture_as_pdf_rounded,
          color: Color(0xFFEF4444),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBadge(String status) {
    final s = status.toLowerCase();
    Color bg = const Color(0xFFDCFCE7);
    Color text = const Color(0xFF16A34A);
    Color border = const Color(0xFFBBF7D0);

    if (s.contains('reject')) {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
      border = const Color(0xFFFECACA);
    } else if (s.contains('pending')) {
      bg = const Color(0xFFFEFAE2);
      text = const Color(0xFFD97706);
      border = const Color(0xFFFEF08A);
    } else if (s.contains('revision')) {
      bg = const Color(0xFFFFF7ED);
      text = const Color(0xFFEA580C);
      border = const Color(0xFFFFEDD5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}

class _EmptyBuildingDrawingsCard extends StatelessWidget {
  const _EmptyBuildingDrawingsCard({required this.project});

  final DrawingProjectItem project;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.description_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          const Text(
            'No Building Drawings Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'No structural or architectural drawings have been released for this project yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateBox extends StatelessWidget {
  const _EmptyStateBox({
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  final String message;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: onAction,
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
