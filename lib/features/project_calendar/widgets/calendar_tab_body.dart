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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CalendarMonthGrid(),
        SizedBox(height: size.height * 0.016),
        const DeliveryCardsSection(),
      ],
    );
  }
}
