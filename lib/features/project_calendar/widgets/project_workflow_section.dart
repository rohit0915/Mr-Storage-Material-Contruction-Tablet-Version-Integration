import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/project_details_controller.dart';
import '../models/project_calendar_models.dart';
import 'step_detail_dialog.dart';
import 'update_workflow_dialog.dart';

class ProjectWorkflowSection extends StatefulWidget {
  const ProjectWorkflowSection({super.key});

  @override
  State<ProjectWorkflowSection> createState() => _ProjectWorkflowSectionState();
}

class _ProjectWorkflowSectionState extends State<ProjectWorkflowSection> {
  final ScrollController _scrollController = ScrollController();
  static const double _stepItemWidth = 140.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll(double delta) {
    if (!_scrollController.hasClients) return;
    final newOffset = (_scrollController.offset + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectDetailsController>();

    return Obx(() {
      final steps = controller.workflowSteps;
      final completionDate = controller.workflowCompletionDate.value;
      final status = controller.workflowStatus.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row (Fully Responsive)
            Wrap(
              spacing: 16,
              runSpacing: 14,
              alignment: WrapAlignment.spaceBetween,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Title, step count badge, and navigation arrows
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Project Workflow',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        '${steps.length} Steps',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Navigation Arrows for quick scroll
                    _scrollArrow(
                      icon: Icons.chevron_left,
                      onTap: () => _scroll(-280),
                      tooltip: 'Scroll left',
                    ),
                    const SizedBox(width: 4),
                    _scrollArrow(
                      icon: Icons.chevron_right,
                      onTap: () => _scroll(280),
                      tooltip: 'Scroll right',
                    ),
                  ],
                ),

                // Overall Completion Date, Status, and Update Workflow Button
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _completionDateColumn(completionDate),
                        _headerDivider(),
                        _statusColumn(status),
                      ],
                    ),
                    _updateWorkflowButton(context),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stepper timeline with smooth Horizontal Scroll
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = math.max(
                  constraints.maxWidth,
                  steps.length * _stepItemWidth,
                );

                // Find index of last completed step to draw colored progress line
                final lastCompletedIndex = steps.lastIndexWhere(
                  (s) => s.status.toLowerCase().contains('complete'),
                );

                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                      PointerDeviceKind.stylus,
                    },
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: steps.length * _stepItemWidth > constraints.maxWidth,
                    trackVisibility: false,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: totalWidth,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // Base connecting line behind circles across all steps
                            if (steps.length > 1)
                              Positioned(
                                top: 15,
                                left: _stepItemWidth / 2,
                                width: (steps.length - 1) * _stepItemWidth,
                                child: Container(
                                  height: 2,
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),

                            // Colored progress line for completed steps
                            if (lastCompletedIndex > 0)
                              Positioned(
                                top: 15,
                                left: _stepItemWidth / 2,
                                width: lastCompletedIndex * _stepItemWidth,
                                child: Container(
                                  height: 2,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),

                            // Steps Row with generous fixed column widths
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int i = 0; i < steps.length; i++)
                                  SizedBox(
                                    width: _stepItemWidth,
                                    child: _WorkflowStepColumn(
                                      step: steps[i],
                                      leadId: controller.leadId.value,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _scrollArrow({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: const Color(0xFF475569)),
        ),
      ),
    );
  }

  Widget _completionDateColumn(String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overall Project Completion Date',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          date,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }

  Widget _headerDivider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: const Color(0xFFCBD5E1),
    );
  }

  Widget _statusColumn(String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          status,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }

  Widget _updateWorkflowButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        UpdateWorkflowDialog.show(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF475569),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Update Workflow',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WorkflowStepColumn extends StatelessWidget {
  const _WorkflowStepColumn({
    required this.step,
    required this.leadId,
  });

  final ProjectWorkflowStep step;
  final String leadId;

  @override
  Widget build(BuildContext context) {
    final statusLower = step.status.toLowerCase();
    final isCompleted = statusLower.contains('complete');
    final isInProgress = statusLower.contains('progress') || statusLower.contains('inprogress');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Number circle with status highlight
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFDCFCE7)
                  : (isInProgress
                      ? const Color(0xFFDBEAFE)
                      : const Color(0xFFF1F5F9)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF86EFAC)
                    : (isInProgress
                        ? const Color(0xFF93C5FD)
                        : const Color(0xFFCBD5E1)),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${step.stepNumber}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isCompleted
                    ? const Color(0xFF15803D)
                    : (isInProgress
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFF64748B)),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Step Title (clean 2-line title with no squishing)
          SizedBox(
            height: 34,
            child: Center(
              child: Text(
                step.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  height: 1.25,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Start & End Dates (readable and well-spaced)
          Text(
            'Start: ${step.startDate}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'End: ${step.endDate}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Status Badge Pill (Full text cleanly visible)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            constraints: const BoxConstraints(maxWidth: 130),
            decoration: BoxDecoration(
              color: step.statusBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: step.statusTextColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    step.status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: step.statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Eye icon button
          Tooltip(
            message: 'View details of ${step.title}',
            child: InkWell(
              onTap: () {
                StepDetailDialog.show(
                  context,
                  step: step,
                  leadId: leadId,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.remove_red_eye_outlined,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
