import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
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

class DrawingsView extends GetView<DrawingsController> {
  const DrawingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = size.height * 0.014;

    return AppScaffold(
      menuTitle: 'Drawings & Attachments',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Screen Top Header: Title, Subtitle & Upload Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (Navigator.of(context).canPop()) ...[
                  InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drawings & Attachments',
                        style: TextStyle(
                          fontSize: (size.width * 0.018).clamp(20.0, 26.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.004),
                      Text(
                        'View engineering drawings and upload site progress photos & videos for active projects.',
                        style: TextStyle(
                          fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                          color: AppColors.textSecondary,
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
            ),
            SizedBox(height: gap),

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

            // Main White Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Action Row: Search Field & Media Filter Pills
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
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
                              fillColor: Colors.white,
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
                        ),
                      ),
                      const SizedBox(width: 14),
                      _MediaFilterPills(controller: controller),
                    ],
                  ),
                  SizedBox(height: gap + 4),

                  // List of Project Cards
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const AppShimmerGrid(
                        itemCount: 4,
                        crossAxisCount: 2,
                      );
                    }
                    final projects = controller.filteredProjects;
                    if (projects.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No projects found matching the criteria.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: projects
                          .map(
                            (p) => Padding(
                              padding: EdgeInsets.only(bottom: gap + 4),
                              child: _ProjectItemCard(project: p),
                            ),
                          )
                          .toList(),
                    );
                  }),
                ],
              ),
            ),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.12)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
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

class _MediaFilterPills extends StatelessWidget {
  const _MediaFilterPills({required this.controller});

  final DrawingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedMediaFilter.value;
      return Container(
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildItem(
              label: 'All Media',
              icon: null,
              isSelected: selected == MediaFilterType.allMedia,
              onTap: () => controller.setMediaFilter(MediaFilterType.allMedia),
            ),
            _buildItem(
              label: 'Photos',
              icon: Icons.photo_outlined,
              isSelected: selected == MediaFilterType.photos,
              onTap: () => controller.setMediaFilter(MediaFilterType.photos),
            ),
            _buildItem(
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

  Widget _buildItem({
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

class _ProjectItemCard extends GetView<DrawingsController> {
  const _ProjectItemCard({required this.project});

  final DrawingProjectItem project;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final files = controller.getProjectFiles(project);
      final mediaCount = project.files.where((f) => f.isMedia).length;
      final drawingCount = project.files.where((f) => f.isDrawing).length;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Row with Project Name, Code, Media Badge, Meta & Add Button
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 680;

                final badges = <Widget>[
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (project.code.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        project.code,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  if (controller.selectedTab.value ==
                          DrawingTabType.photosVideos &&
                      mediaCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_camera_outlined,
                            size: 12,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$mediaCount ${mediaCount == 1 ? 'Photo' : 'Photos'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (controller.selectedTab.value ==
                          DrawingTabType.drawings &&
                      drawingCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            size: 12,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$drawingCount ${drawingCount == 1 ? 'Drawing' : 'Drawings'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                ];

                final addButton = OutlinedButton.icon(
                  onPressed: () =>
                      controller.openUpload(context, projectId: project.id),
                  icon: const Icon(Icons.add, size: 14),
                  label: Text(
                    controller.selectedTab.value == DrawingTabType.drawings
                        ? 'Add Drawing'
                        : 'Add Media',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 6,
                              children: badges,
                            ),
                          ),
                          const SizedBox(width: 8),
                          addButton,
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _MetaCol(
                            label: 'LOCATION',
                            value: project.location.isNotEmpty
                                ? project.location
                                : '-',
                          ),
                          const SizedBox(width: 24),
                          _MetaCol(
                            label: 'LAST UPDATED',
                            value: formatToSlashDate(project.lastUpdate),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: badges,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _MetaCol(
                      label: 'LOCATION',
                      value:
                          project.location.isNotEmpty ? project.location : '-',
                    ),
                    const SizedBox(width: 24),
                    _MetaCol(
                      label: 'LAST UPDATED',
                      value: formatToSlashDate(project.lastUpdate),
                    ),
                    const SizedBox(width: 16),
                    addButton,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Subheader: Section Title & Item Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.selectedTab.value == DrawingTabType.photosVideos
                      ? 'SITE PHOTOS & VIDEOS'
                      : (controller.selectedTab.value == DrawingTabType.drawings
                          ? 'ENGINEERING DRAWINGS'
                          : 'ALL FILES & ATTACHMENTS'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${files.length} ${files.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Files Grid or Empty State
            if (files.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final int crossAxisCount =
                      width >= 860 ? 3 : (width >= 560 ? 2 : 1);
                  final double cardWidth =
                      (width - (crossAxisCount - 1) * 12) / crossAxisCount;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: files
                        .map(
                          (f) => SizedBox(
                            width: cardWidth,
                            child: _ModernFileCard(file: f),
                          ),
                        )
                        .toList(),
                  );
                },
              )
            else
              _EmptyStateBox(
                message: controller.selectedTab.value ==
                        DrawingTabType.photosVideos
                    ? 'No photos or videos available for this project.'
                    : (controller.selectedTab.value == DrawingTabType.drawings
                        ? 'No engineering drawings available for this project.'
                        : 'No files available for this project.'),
                actionText: controller.selectedTab.value ==
                        DrawingTabType.photosVideos
                    ? '+ Upload photo or video for this project'
                    : '+ Upload file for this project',
                onAction: () =>
                    controller.openUpload(context, projectId: project.id),
              ),
          ],
        ),
      );
    });
  }
}

class _MetaCol extends StatelessWidget {
  const _MetaCol({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ModernFileCard extends GetView<DrawingsController> {
  const _ModernFileCard({required this.file});

  final DrawingFileItem file;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 52,
              height: 52,
              child: _buildThumbnail(),
            ),
          ),
          const SizedBox(width: 10),

          // File Details (Expanded)
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
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${file.typeLabel} • ${formatToSlashDate(file.receivedOn)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    file.typeLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Icons
          InkWell(
            onTap: () => controller.openFilePreview(context, file),
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 15,
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
                size: 16,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    final url = file.previewAssets.isNotEmpty ? file.previewAssets.first : '';
    if (file.isPhoto) {
      if (url.isNotEmpty &&
          (url.startsWith('http://') || url.startsWith('https://'))) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallbackIcon(
            Icons.photo_outlined,
            const Color(0xFFEFF6FF),
            AppColors.primaryBlue,
          ),
        );
      }
      return _fallbackIcon(
        Icons.photo_outlined,
        const Color(0xFFEFF6FF),
        AppColors.primaryBlue,
      );
    }

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

    if (file.fileType == DrawingFileType.pdf) {
      return _fallbackIcon(
        Icons.picture_as_pdf_rounded,
        const Color(0xFFFEF2F2),
        const Color(0xFFEF4444),
      );
    }

    return _fallbackIcon(
      Icons.description_outlined,
      const Color(0xFFF1F5F9),
      AppColors.textSecondary,
    );
  }

  Widget _fallbackIcon(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      color: bgColor,
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: 22),
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
