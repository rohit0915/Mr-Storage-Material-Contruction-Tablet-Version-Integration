import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.solid = true,
  });

  final String label;
  final Color color;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.width * 0.009).clamp(10.0, 12.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.008,
        vertical: size.height * 0.004,
      ),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: solid ? Colors.white : color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: size.width * 0.004),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: solid ? Colors.white : color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
