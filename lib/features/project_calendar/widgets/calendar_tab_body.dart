import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/project_calendar_controller.dart';
import 'calendar_month_grid.dart';
import 'delivery_cards_section.dart';

class CalendarTabBody extends GetView<ProjectCalendarController> {
  const CalendarTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final colGap = (size.width * 0.014).clamp(14.0, 20.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 850;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CalendarMonthGrid(),
              SizedBox(height: colGap),
              const DeliveryCardsSection(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 65, child: CalendarMonthGrid()),
            SizedBox(width: colGap),
            const Expanded(flex: 35, child: DeliveryCardsSection()),
          ],
        );
      },
    );
  }
}
