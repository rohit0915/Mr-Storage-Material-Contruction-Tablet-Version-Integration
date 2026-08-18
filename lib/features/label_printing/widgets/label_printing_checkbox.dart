import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Figma-style checkbox with brand purple (#7539FF) when checked.
class LabelPrintingCheckbox extends StatelessWidget {
  const LabelPrintingCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 20,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value ? AppColors.brandPrimary : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value ? AppColors.brandPrimary : const Color(0xFFD1D5DB),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: value
            ? Icon(Icons.check_rounded, size: size - 5, color: Colors.white)
            : null,
      ),
    );
  }
}

/// Checkbox column with trailing gap before the next table column.
class LabelPrintingCheckboxCell extends StatelessWidget {
  const LabelPrintingCheckboxCell({
    super.key,
    required this.value,
    this.onChanged,
    this.gapAfter = 16,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double gapAfter;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LabelPrintingCheckbox(value: value, onChanged: onChanged),
        SizedBox(width: gapAfter),
      ],
    );
  }
}
