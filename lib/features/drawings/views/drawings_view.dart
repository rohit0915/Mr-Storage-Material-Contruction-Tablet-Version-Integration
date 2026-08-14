import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
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
      menuTitle: 'Drawings & Attachments',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Project Drawings',
              style: TextStyle(
                fontSize: (size.width * 0.018).clamp(20.0, 26.0),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: size.height * 0.004),
            Text(
              'All structural, fabrication, and erection drawings for this project.',
              style: TextStyle(
                fontSize: (size.width * 0.011).clamp(12.0, 14.0),
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: gap),
            Container(
              padding: EdgeInsets.all((size.width * 0.014).clamp(14.0, 20.0)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          'Upload Photos & Videos',
                          style: TextStyle(
                            fontSize: (size.width * 0.011).clamp(12.0, 14.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.012,
                            vertical: size.height * 0.014,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.01),
                      SizedBox(
                        width: (size.width * 0.22).clamp(200.0, 280.0),
                        height: 44,
                        child: TextField(
                          controller: controller.localSearchController,
                          onChanged: controller.onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search leads, projects...',
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.cardBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
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
                  Obx(() {
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
                              child: _ProjectDrawingCard(project: p),
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

class _ProjectDrawingCard extends GetView<DrawingsController> {
  const _ProjectDrawingCard({required this.project});

  final DrawingProjectItem project;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      padding: EdgeInsets.all((size.width * 0.012).clamp(12.0, 16.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                        fontSize: (size.width * 0.013).clamp(14.0, 17.0),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      project.code,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _InfoCol(label: 'Uploaded By', value: project.uploadedBy),
              SizedBox(width: size.width * 0.02),
              _InfoCol(label: 'Location', value: project.location),
              SizedBox(width: size.width * 0.02),
              _InfoCol(label: 'Last Update on', value: project.lastUpdate),
            ],
          ),
          SizedBox(height: size.height * 0.014),
          const Text(
            'Attachments & Drawings',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: project.files
                .map(
                  (f) => SizedBox(
                    width: (size.width * 0.28).clamp(280.0, 360.0),
                    child: _FileTile(file: f),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoCol extends StatelessWidget {
  const _InfoCol({required this.label, required this.value});

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
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _FileTile extends GetView<DrawingsController> {
  const _FileTile({required this.file});

  final DrawingFileItem file;

  Color get _iconBg {
    switch (file.fileType) {
      case DrawingFileType.pdf:
        return const Color(0xFFEF4444);
      case DrawingFileType.dwg:
        return const Color(0xFFDC2626);
      case DrawingFileType.docx:
        return const Color(0xFF2563EB);
      case DrawingFileType.image:
        return AppColors.accentBlue;
    }
  }

  String get _iconLabel {
    switch (file.fileType) {
      case DrawingFileType.pdf:
        return 'PDF';
      case DrawingFileType.dwg:
        return 'DWG';
      case DrawingFileType.docx:
        return 'DOC';
      case DrawingFileType.image:
        return 'IMG';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _iconLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  file.sizeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 11,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      file.status,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.download_rounded,
                    onTap: () => controller.openFilePreview(context, file),
                  ),
                  const SizedBox(width: 6),
                  _RoundIconButton(
                    icon: Icons.visibility_outlined,
                    onTap: () => controller.openFilePreview(context, file),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryBlue),
        ),
        child: Icon(icon, size: 16, color: AppColors.primaryBlue),
      ),
    );
  }
}
