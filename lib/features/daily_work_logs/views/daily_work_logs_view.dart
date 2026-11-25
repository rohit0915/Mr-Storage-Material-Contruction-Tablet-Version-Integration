import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_searchable_dropdown.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../controllers/daily_work_logs_controller.dart';
import '../models/work_log_model.dart';

class DailyWorkLogsView extends GetView<DailyWorkLogsController> {
  const DailyWorkLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<DailyWorkLogsController>()
        ? Get.find<DailyWorkLogsController>()
        : Get.put(DailyWorkLogsController());

    final size = MediaQuery.sizeOf(context);
    final padH = (size.width * 0.02).clamp(16.0, 24.0);

    return AppScaffold(
      menuTitle: 'Daily Work Logs',
      body: Obx(() {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header: Title, Subtitle, and + Daily Work Log button ───
              _buildTopHeader(context, ctrl),
              const SizedBox(height: 18),

              // ─── Filter Section Card ───
              _buildFilterSection(ctrl),
              const SizedBox(height: 18),

              // ─── Daily Work Logs Table Card ───
              _buildTableCard(context, ctrl),
            ],
          ),
        );
      }),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TOP HEADER
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTopHeader(BuildContext context, DailyWorkLogsController ctrl) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 650;
        final canPop = Navigator.of(context).canPop();

        final titleCol = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Daily Work Logs',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Daily site diary entries tracking progress, field activities, issues, and photos.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        );

        final backBtn = canPop
            ? InkWell(
                onTap: Get.back,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              )
            : null;

        final titleRow = Row(
          children: [
            ?backBtn,
            Expanded(child: titleCol),
          ],
        );

        final btn = ElevatedButton.icon(
          onPressed: () => ctrl.openCreateLogDialog(context),
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          label: const Text(
            'Daily Work Log',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF22C55E),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleRow,
              const SizedBox(height: 12),
              btn,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleRow),
            const SizedBox(width: 16),
            btn,
          ],
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FILTER SECTION
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildFilterSection(DailyWorkLogsController ctrl) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;

          final projectItems = <String>['All Projects'];
          final displayMap = <String, String>{};
          for (final p in ctrl.projects) {
            final name = p['name'] ?? '';
            if (name.isNotEmpty) {
              if (!projectItems.contains(name)) {
                projectItems.add(name);
              }
              displayMap[name] = p['displayName'] ?? name;
            }
          }
          if (ctrl.selectedProject.value.isNotEmpty && !projectItems.contains(ctrl.selectedProject.value)) {
            projectItems.add(ctrl.selectedProject.value);
          }
          if (!projectItems.contains('Storage 0011')) {
            projectItems.add('Storage 0011');
          }

          final searchWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SEARCH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: ctrl.searchController,
                  onChanged: ctrl.onSearch,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Search description, task...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primaryBlue),
                    ),
                  ),
                ),
              ),
            ],
          );

          final projectWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PROJECT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: AppSearchableDropdown.simple(
                  key: ValueKey(ctrl.selectedProject.value),
                  items: projectItems,
                  value: projectItems.contains(ctrl.selectedProject.value)
                      ? ctrl.selectedProject.value
                      : projectItems.first,
                  displayMap: displayMap,
                  height: 40,
                  menuMaxHeight: 300,
                  searchHint: 'Search projects...',
                  onChanged: (val) {
                    if (val != null) ctrl.onProjectChanged(val);
                  },
                ),
              ),
            ],
          );

          final resetBtn = Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: ctrl.resetFilters,
              icon: const Icon(Icons.refresh, size: 15, color: Color(0xFF64748B)),
              label: const Text(
                'Reset Filters',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchWidget,
                const SizedBox(height: 12),
                projectWidget,
                const SizedBox(height: 8),
                resetBtn,
              ],
            );
          }

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: searchWidget),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: projectWidget),
                ],
              ),
              const SizedBox(height: 6),
              resetBtn,
            ],
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DAILY WORK LOGS TABLE CARD
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTableCard(BuildContext context, DailyWorkLogsController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Card Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Work Logs (${ctrl.totalResults.value})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => ctrl.openCreateLogDialog(context),
                  icon: const Icon(Icons.add, size: 14, color: Colors.white),
                  label: const Text(
                    'Add Log',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Table Content
          if (ctrl.isLoading.value && ctrl.workLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: AppShimmerTable(rowCount: 4),
            )
          else
            _buildTableView(context, ctrl),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Pagination Footer (Requested by user: "pagination joi laje")
          _buildPaginationFooter(ctrl),
        ],
      ),
    );
  }

  Widget _buildTableView(BuildContext context, DailyWorkLogsController ctrl) {
    final items = ctrl.workLogs;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < 1280 ? 1280.0 : constraints.maxWidth;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: tableWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Table Header
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1.5)),
                    ),
                    child: Row(
                      children: [
                        _thCell('DATE', flex: 2),
                        _thCell('PROJECT', flex: 3),
                        _thCell('LINKED TASK', flex: 2),
                        _thCell('PROGRESS', flex: 2),
                        _thCell('WORK DESCRIPTION', flex: 4),
                        _thCell('PHOTOS', flex: 2),
                        _thCell('ISSUES / NOTES', flex: 3),
                        _thCell('LOGGED BY', flex: 3),
                        _thCell('ACTIONS', flex: 2, textAlign: TextAlign.center, isLast: true),
                      ],
                    ),
                  ),

                  // Table Rows or Empty State
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: Text(
                          'No work logs found for the selected filters.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: items.map((log) => _buildRow(context, ctrl, log)).toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _thCell(String text, {required int flex, TextAlign textAlign = TextAlign.left, bool isLast = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(right: BorderSide(color: Color(0xFFCBD5E1), width: 1.0)),
        ),
        child: Text(
          text,
          textAlign: textAlign,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _tdCell({required int flex, required Widget child, bool isLast = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildRow(BuildContext context, DailyWorkLogsController ctrl, WorkLogItem log) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0)),
      ),
      child: Row(
        children: [
          // DATE
          _tdCell(
            flex: 2,
            child: Text(
              log.formattedDate,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ),

          // PROJECT
          _tdCell(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.projectName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (log.jobId.isNotEmpty)
                  Text(
                    '#${log.jobId}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // LINKED TASK
          _tdCell(
            flex: 2,
            child: Text(
              log.taskTitle.isNotEmpty ? log.taskTitle : 'General',
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Color(0xFF64748B),
              ),
            ),
          ),

          // PROGRESS
          _tdCell(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${log.progress}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ),
          ),

          // WORK DESCRIPTION
          _tdCell(
            flex: 4,
            child: Text(
              log.workDescription,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1E293B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // PHOTOS
          _tdCell(
            flex: 2,
            child: log.photos.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_camera_outlined,
                        size: 15,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${log.photos.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  )
                : const Text(
                    '—',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
          ),

          // ISSUES / NOTES
          _tdCell(
            flex: 3,
            child: Text(
              log.issues,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // LOGGED BY
          _tdCell(
            flex: 3,
            child: Text(
              log.displayLoggedBy,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ACTIONS (View Button)
          _tdCell(
            flex: 2,
            isLast: true,
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 32,
                child: OutlinedButton(
                  onPressed: () => ctrl.openLogDetails(context, log),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E293B),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(64, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    'View',
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PAGINATION FOOTER
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPaginationFooter(DailyWorkLogsController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 500;

          final pageSizeWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Showing ',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: ctrl.pageSize.value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    items: ctrl.pageSizeOptions
                        .map(
                          (size) => DropdownMenuItem(
                            value: size,
                            child: Text('$size'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) ctrl.changePageSize(v);
                    },
                  ),
                ),
              ),
              const Text(
                ' Results',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          );

          final canGoPrev = ctrl.canGoPrev;
          final canGoNext = ctrl.canGoNext;

          final pagesWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Prev Button <
              _PaginationArrowBtn(
                icon: Icons.chevron_left,
                enabled: canGoPrev,
                onTap: ctrl.previousPage,
              ),
              const SizedBox(width: 8),

              // Page numbers (e.g. 1, 2...)
              for (int p = 1; p <= ctrl.totalPages.value; p++) ...[
                InkWell(
                  onTap: ctrl.totalPages.value > 1 && ctrl.currentPage.value != p
                      ? () => ctrl.changePage(p)
                      : null,
                  mouseCursor: ctrl.totalPages.value > 1 && ctrl.currentPage.value != p
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  borderRadius: BorderRadius.circular(6),
                  splashColor: ctrl.totalPages.value > 1 && ctrl.currentPage.value != p
                      ? null
                      : Colors.transparent,
                  highlightColor: ctrl.totalPages.value > 1 && ctrl.currentPage.value != p
                      ? null
                      : Colors.transparent,
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ctrl.currentPage.value == p ? const Color(0xFF2563EB) : Colors.white,
                      border: ctrl.currentPage.value == p ? null : Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$p',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ctrl.currentPage.value == p ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Next Button >
              _PaginationArrowBtn(
                icon: Icons.chevron_right,
                enabled: canGoNext,
                onTap: ctrl.nextPage,
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                pageSizeWidget,
                const SizedBox(height: 12),
                pagesWidget,
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              pageSizeWidget,
              pagesWidget,
            ],
          );
        },
      ),
    );
  }
}

class _PaginationArrowBtn extends StatelessWidget {
  const _PaginationArrowBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      borderRadius: BorderRadius.circular(6),
      splashColor: enabled ? null : Colors.transparent,
      highlightColor: enabled ? null : Colors.transparent,
      hoverColor: enabled ? null : Colors.transparent,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(6),
          color: enabled ? Colors.white : const Color(0xFFF8FAFC),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}

