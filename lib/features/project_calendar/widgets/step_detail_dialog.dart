import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_toast.dart';
import '../controllers/project_details_controller.dart';
import '../models/project_calendar_models.dart';

class StepDetailDialog extends StatefulWidget {
  const StepDetailDialog({
    super.key,
    this.task,
    this.step,
    this.leadId = '',
  });

  final ProjectTimelineTask? task;
  final ProjectWorkflowStep? step;
  final String leadId;

  static Future<void> show(
    BuildContext context, {
    ProjectTimelineTask? task,
    ProjectWorkflowStep? step,
    String leadId = '',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => StepDetailDialog(
        task: task,
        step: step,
        leadId: leadId,
      ),
    );
  }

  @override
  State<StepDetailDialog> createState() => _StepDetailDialogState();
}

class _StepDetailDialogState extends State<StepDetailDialog> {
  ProjectTimelineTask? _currentTask;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _loadLatestDetails();
  }

  Future<void> _loadLatestDetails() async {
    final taskId = widget.task?.id ?? widget.step?.stepKey ?? '';
    if (taskId.isEmpty) return;
    try {
      final controller = Get.find<ProjectDetailsController>();
      final fresh = await controller.getTimelineTaskDetail(taskId);
      if (fresh != null && mounted) {
        setState(() {
          _currentTask = fresh;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width * 0.58).clamp(520.0, 720.0);

    final title = _currentTask?.title ?? widget.step?.title ?? 'Task Details';
    final startDate = _currentTask?.startDate ?? widget.step?.startDate ?? '-';
    final estDate = _currentTask?.estimatedEndDate ?? widget.step?.effectiveEstEndDate ?? '-';
    final completedDate = _currentTask?.completedDate ?? widget.step?.effectiveCompletedDate ?? '-';
    final isCompleted = _currentTask != null
        ? _currentTask!.isCompleted
        : (widget.step?.status.toLowerCase().contains('complete') ?? false);
    final statusLine = _currentTask?.timelineStatusLine ?? '';
    final statusLabel = statusLine.isNotEmpty
        ? statusLine
        : (_currentTask?.badgeLabel ?? widget.step?.displayTimelineBadge ?? 'Pending');
    final statusColor = statusLine.isNotEmpty
        ? const Color(0xFFDC2626)
        : (_currentTask?.badgeTextColor ?? widget.step?.statusTextColor ?? const Color(0xFF1D4ED8));

    final description = _currentTask?.description.isNotEmpty == true
        ? _currentTask!.description
        : (widget.step?.description.isNotEmpty == true
            ? widget.step!.description
            : 'No detailed work description provided for this step yet.');

    final photos = _currentTask?.attachments.isNotEmpty == true
        ? _currentTask!.attachments
        : (widget.step?.photos ?? const <String>[]);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row matching Figma
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        // Modal header status in red text (e.g. 2 Days Delayed)
                        if (statusLine.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusLine,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Mark as Completed Button
                  ElevatedButton(
                    onPressed: (isCompleted || _isActionInProgress)
                        ? null
                        : () async {
                            final nav = Navigator.of(context);
                            setState(() => _isActionInProgress = true);
                            try {
                              final controller = Get.find<ProjectDetailsController>();
                              final taskId = _currentTask?.id ?? widget.step?.stepKey ?? '';
                              bool ok = false;
                              if (taskId.isNotEmpty) {
                                ok = await controller.markTimelineTaskComplete(taskId);
                              } else if (widget.step != null) {
                                ok = await controller.markStepComplete(widget.step!);
                              }
                              if (mounted) {
                                nav.pop();
                                if (ok) {
                                  AppToast.showSuccess(
                                    title: 'Task Completed',
                                    description: '$title marked as Completed ✓',
                                  );
                                } else {
                                  AppToast.showError(
                                    title: 'Error',
                                    description: 'Could not complete task on server.',
                                  );
                                }
                              }
                            } finally {
                              if (mounted) setState(() => _isActionInProgress = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF1D4ED8), // Blue matching Figma
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isActionInProgress
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            isCompleted ? 'Completed ✓' : 'Mark as Completed',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),

                  IconButton(
                    icon: const Icon(Icons.close, size: 22, color: Color(0xFF334155)),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Info Box with 4 Columns matching Figma
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    // Start Date
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            startDate,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _vDivider(),

                    // Est Date
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Est Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            estDate,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _vDivider(),

                    // Completed Date
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Completed Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            completedDate,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _vDivider(),

                    // Status
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Work Description Box matching Figma
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Work Description',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Photos Section
              const Text(
                'Photos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    if (photos.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'No photos attached to this task.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      )
                    else
                      for (int i = 0; i < photos.length; i++) ...[
                        _buildPhotoThumbnail(photos[i]),
                      ],

                    const SizedBox(width: 8),
                    // View All Media Outlined Button
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        final effectiveLeadId = widget.leadId.isNotEmpty
                            ? widget.leadId
                            : Get.find<ProjectDetailsController>().leadId.value;
                        Get.toNamed(
                          AppRoutes.drawings,
                          arguments: {'leadId': effectiveLeadId},
                        );
                      },
                      icon: const Icon(
                        Icons.photo_library_outlined,
                        size: 16,
                        color: Color(0xFF2563EB),
                      ),
                      label: const Text(
                        'View All Media',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Bottom Actions: Remove Task Button on Left
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _isActionInProgress
                        ? null
                        : () async {
                            final nav = Navigator.of(context);
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Remove Task'),
                                content: Text('Are you sure you want to delete "$title"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm != true || !mounted) return;
                            setState(() => _isActionInProgress = true);
                            try {
                              final controller = Get.find<ProjectDetailsController>();
                              final taskId = _currentTask?.id ?? widget.step?.stepKey ?? '';
                              bool ok = false;
                              if (taskId.isNotEmpty) {
                                ok = await controller.deleteTimelineTask(taskId);
                              } else if (widget.step != null) {
                                ok = await controller.removeTask(widget.step!);
                              }
                              if (mounted) {
                                nav.pop();
                                if (ok) {
                                  AppToast.showSuccess(
                                    title: 'Task Removed',
                                    description: '$title has been removed.',
                                  );
                                } else {
                                  AppToast.showError(
                                    title: 'Error',
                                    description: 'Could not remove task from server.',
                                  );
                                }
                              }
                            } finally {
                              if (mounted) setState(() => _isActionInProgress = false);
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Remove Task',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(String photoUrl) {
    final isNetwork = photoUrl.startsWith('http://') || photoUrl.startsWith('https://');

    return Container(
      width: 100,
      height: 66,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: isNetwork
          ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  ),
                );
              },
            )
          : Image.asset(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
            ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF94A3B8),
        size: 22,
      ),
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFFCBD5E1),
    );
  }
}

