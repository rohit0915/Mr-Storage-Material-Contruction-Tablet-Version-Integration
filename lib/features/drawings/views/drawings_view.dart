import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../controllers/drawings_controller.dart';
import '../models/drawing_models.dart';

class DrawingsView extends GetView<DrawingsController> {
  const DrawingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = size.height * 0.014;

    return AppScaffold(
      menuTitle: 'Project Drawings',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                        'Project Drawings',
                        style: TextStyle(
                          fontSize: (size.width * 0.018).clamp(20.0, 24.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.004),
                      Text(
                        'All structural, fabrication, and erection drawings for this project.',
                        style: TextStyle(
                          fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),

            // Main White Card Container
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
                  // Card Header: Title, Upload Button & Search Bar
                  Row(
                    children: [
                      Text(
                        'Projects & Drawings',
                        style: TextStyle(
                          fontSize: (size.width * 0.014).clamp(15.0, 18.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => controller.openUpload(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Upload Photos & Videos'),
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
                      const SizedBox(width: 12),
                      SizedBox(
                        width: (size.width * 0.22).clamp(200.0, 260.0),
                        height: 42,
                        child: TextField(
                          controller: controller.localSearchController,
                          onChanged: controller.onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search leads, projects...',
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
                    ],
                  ),
                  SizedBox(height: gap),

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
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No projects found')),
                      );
                    }
                    return Column(
                      children: projects
                          .map(
                            (p) => Padding(
                              padding: EdgeInsets.only(bottom: gap),
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

class _ProjectItemCard extends GetView<DrawingsController> {
  const _ProjectItemCard({required this.project});

  final DrawingProjectItem project;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header Row with Project Name, Code & Meta
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: TextStyle(
                        fontSize: (size.width * 0.014).clamp(15.0, 18.0),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.code,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _MetaCol(label: 'Uploaded By:', value: project.uploadedBy),
              SizedBox(width: size.width * 0.02),
              _MetaCol(label: 'Location:', value: project.location),
              SizedBox(width: size.width * 0.02),
              _MetaCol(label: 'Last Update on', value: project.lastUpdate),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Attachments & Drawings',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal/Wrap List of File Cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: project.files
                .map(
                  (f) => SizedBox(
                    width: (size.width * 0.26).clamp(260.0, 340.0),
                    child: _FileCardTile(file: f),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
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
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
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

class _FileCardTile extends GetView<DrawingsController> {
  const _FileCardTile({required this.file});

  final DrawingFileItem file;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.tableHeader,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              // Red icon box with P inside
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: const Text(
                  'P',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      file.sizeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => controller.openFilePreview(context, file),
                child: const Icon(
                  Icons.arrow_downward,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => controller.openFilePreview(context, file),
                child: const Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),

        // Approved Green Badge on top right
        if (file.status == 'Approved')
          Positioned(
            top: -2,
            right: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Approved',
                style: TextStyle(
                  color: AppColors.badgeGreen,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
