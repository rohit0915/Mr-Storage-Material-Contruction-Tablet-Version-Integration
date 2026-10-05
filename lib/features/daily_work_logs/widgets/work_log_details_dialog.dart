import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/work_log_model.dart';

class WorkLogDetailsDialog extends StatelessWidget {
  const WorkLogDetailsDialog({super.key, required this.item});

  final WorkLogItem item;

  static Future<void> show(BuildContext context, WorkLogItem item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => WorkLogDetailsDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width * 0.52).clamp(480.0, 580.0);

    final projectDisplay = item.jobId.isNotEmpty
        ? '${item.projectName} (${item.jobId})'
        : item.projectName;

    final taskDisplay = item.taskTitle.isNotEmpty
        ? (item.taskTitle == 'General' ? 'None / General Work' : item.taskTitle)
        : 'None / General Work';

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Title and Close X icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Work Log Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                InkWell(
                  onTap: Get.back,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Row 1: Date & Progress
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Date'),
                      const SizedBox(height: 4),
                      Text(
                        item.formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Progress'),
                      const SizedBox(height: 4),
                      Text(
                        '${item.progress}%',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Row 2: Project & Linked Task
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Project'),
                      const SizedBox(height: 4),
                      Text(
                        projectDisplay,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Linked Task'),
                      const SizedBox(height: 4),
                      Text(
                        taskDisplay,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Work Description
            _label('Work Description'),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                item.workDescription.isNotEmpty ? item.workDescription : '—',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Logged By
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                children: [
                  const TextSpan(text: 'Logged by: '),
                  TextSpan(
                    text: item.loggedByName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (item.loggedByEmail.isNotEmpty)
                    TextSpan(text: ' (${item.loggedByEmail})'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Close button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: Get.back,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF1E293B),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
  }
}
