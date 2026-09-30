import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class TaskCalendarDialog extends StatefulWidget {
  const TaskCalendarDialog({
    super.key,
    this.initialDate,
    this.title = 'Select Date',
    this.confirmLabel = 'Ok',
  });

  final DateTime? initialDate;
  final String title;
  final String confirmLabel;

  @override
  State<TaskCalendarDialog> createState() => _TaskCalendarDialogState();
}

class _TaskCalendarDialogState extends State<TaskCalendarDialog> {
  late DateTime _month;
  late DateTime _selected;

  static const _weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    final seed = widget.initialDate ?? DateTime(2025, 5, 18);
    _selected = DateTime(seed.year, seed.month, seed.day);
    _month = DateTime(seed.year, seed.month);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = (size.width * 0.32).clamp(340.0, 420.0);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width,
            maxHeight: size.height * 0.75,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() {
                        _month = DateTime(_month.year, _month.month - 1);
                      }),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        '${_months[_month.month - 1]} ${_month.year}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _month = DateTime(_month.year, _month.month + 1);
                      }),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: _weekDays
                      .map(
                        (d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                _buildGrid(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        backgroundColor: const Color(0xFFF3F4F6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_selected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(widget.confirmLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    // Monday-first: DateTime.weekday is 1=Mon ... 7=Sun
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday;
    final leading = firstWeekday - 1;
    final total = ((leading + daysInMonth + 6) ~/ 7) * 7;

    return Column(
      children: List.generate(total ~/ 7, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: List.generate(7, (col) {
              final index = row * 7 + col;
              final dayNum = index - leading + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 32));
              }
              final date = DateTime(_month.year, _month.month, dayNum);
              final selected =
                  date.year == _selected.year &&
                  date.month == _selected.month &&
                  date.day == _selected.day;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = date),
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

Future<DateTime?> pickTaskDate(
  BuildContext context, {
  DateTime? initialDate,
  String title = 'Select Date',
  String confirmLabel = 'Ok',
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (_) => TaskCalendarDialog(
      initialDate: initialDate,
      title: title,
      confirmLabel: confirmLabel,
    ),
  );
}

String formatTaskDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d - $m - ${date.year}';
}
