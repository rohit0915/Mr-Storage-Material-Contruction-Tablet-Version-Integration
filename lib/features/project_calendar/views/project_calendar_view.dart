import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../controllers/project_calendar_controller.dart';
import '../models/project_calendar_models.dart';
import '../widgets/calendar_tab_body.dart';
import '../widgets/project_calendar_header.dart';
import '../widgets/project_tab_body.dart';

class ProjectCalendarView extends GetView<ProjectCalendarController> {
  const ProjectCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = size.height * 0.014;

    return AppScaffold(
      menuTitle: 'Project & Calendar',
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollUpdateNotification) {
            controller.closeDropdown();
          }
          return false;
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProjectCalendarHeader(),
              SizedBox(height: gap),
              Obx(() {
                final tab = controller.selectedTab.value;
                return tab == ProjectCalendarTab.calendar
                    ? const CalendarTabBody()
                    : const ProjectTabBody();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
