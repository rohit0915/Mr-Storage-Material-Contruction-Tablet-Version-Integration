import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';

class FilterRow extends GetView<DashboardController> {
  const FilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = DashboardGap.page(context);

    return Container(
      padding: EdgeInsets.all(gap),
      decoration: BoxDecoration(
        color: AppColors.tableHeader,
        borderRadius: BorderRadius.circular(DashboardGap.radius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSingleRow = constraints.maxWidth >= 600;

          if (isSingleRow) {
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Obx(
                      () => _InlineDropdownChip(
                        value: controller.selectedProject.value,
                        options: controller.projectOptions,
                        onSelected: controller.setProjectFilter,
                        enableSearch: true,
                      ),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: Obx(
                      () => _InlineDropdownChip(
                        value: controller.selectedBuilding.value,
                        options: controller.buildingOptions,
                        onSelected: controller.setBuildingFilter,
                        enableSearch: false,
                      ),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: Obx(
                      () => _InlineDropdownChip(
                        value: controller.selectedStatus.value,
                        options: controller.statusOptions,
                        onSelected: controller.setStatusFilter,
                        enableSearch: false,
                      ),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: Obx(
                      () => _DateFilterInlineChip(
                        value: controller.dateRange.value,
                        onSelected: (range) {
                          controller.setDateRangeFilter(range);
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: gap),
                  OutlinedButton.icon(
                    onPressed: controller.resetFilters,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(
                      'Restart',
                      style: TextStyle(
                        fontSize: (size.width * 0.009).clamp(11.0, 13.0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: EdgeInsets.symmetric(
                        horizontal: (size.width * 0.012).clamp(12.0, 18.0),
                        vertical: (size.height * 0.012).clamp(8.0, 14.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          DashboardGap.radius,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Fallback layout for narrow mobile screens: scrollable row
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 180,
                    child: Obx(
                      () => _InlineDropdownChip(
                        value: controller.selectedProject.value,
                        options: controller.projectOptions,
                        onSelected: controller.setProjectFilter,
                        enableSearch: true,
                      ),
                    ),
                  ),
                  SizedBox(width: gap),
                  SizedBox(
                    width: 140,
                    child: Obx(
                      () => _InlineDropdownChip(
                        value: controller.selectedBuilding.value,
                        options: controller.buildingOptions,
                        onSelected: controller.setBuildingFilter,
                        enableSearch: false,
                      ),
                    ),
                  ),
                  SizedBox(width: gap),
                  SizedBox(
                    width: 130,
                    child: Obx(
                      () => _InlineDropdownChip(
                        value: controller.selectedStatus.value,
                        options: controller.statusOptions,
                        onSelected: controller.setStatusFilter,
                        enableSearch: false,
                      ),
                    ),
                  ),
                  SizedBox(width: gap),
                  SizedBox(
                    width: 180,
                    child: Obx(
                      () => _DateFilterInlineChip(
                        value: controller.dateRange.value,
                        onSelected: (range) {
                          controller.setDateRangeFilter(range);
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: gap),
                  OutlinedButton.icon(
                    onPressed: controller.resetFilters,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(
                      'Restart',
                      style: TextStyle(
                        fontSize: (size.width * 0.009).clamp(11.0, 13.0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: EdgeInsets.symmetric(
                        horizontal: (size.width * 0.012).clamp(12.0, 18.0),
                        vertical: (size.height * 0.012).clamp(8.0, 14.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          DashboardGap.radius,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InlineDropdownChip extends StatefulWidget {
  const _InlineDropdownChip({
    required this.value,
    required this.options,
    required this.onSelected,
    this.enableSearch = false,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final bool enableSearch;

  @override
  State<_InlineDropdownChip> createState() => _InlineDropdownChipState();
}

class _InlineDropdownChipState extends State<_InlineDropdownChip> {
  final _link = LayerLink();
  final _searchController = TextEditingController();
  OverlayEntry? _entry;
  bool _isOpen = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
    _isOpen = false;
    _searchQuery = '';
  }

  void _toggle() {
    if (_isOpen) {
      _removeOverlay();
      setState(() {
        _isOpen = false;
      });
    } else {
      _showOverlay();
      setState(() {
        _isOpen = true;
      });
    }
  }

  void _showOverlay() {
    _searchQuery = '';
    _searchController.clear();
    final renderBox = context.findRenderObject() as RenderBox?;
    final buttonWidth = renderBox?.size.width ?? 220.0;
    final menuWidth = buttonWidth.clamp(200.0, 320.0);
    final size = MediaQuery.sizeOf(context);

    _entry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setOverlayState) {
            final filteredOptions = widget.options.where((opt) {
              if (_searchQuery.isEmpty) return true;
              return opt.toLowerCase().contains(_searchQuery);
            }).toList();

            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _removeOverlay();
                      if (mounted) {
                        setState(() {
                          _isOpen = false;
                        });
                      }
                    },
                  ),
                ),
                CompositedTransformFollower(
                  link: _link,
                  showWhenUnlinked: false,
                  offset: const Offset(0, 44),
                  child: Material(
                    elevation: 8,
                    shadowColor: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: menuWidth,
                      constraints: BoxConstraints(maxHeight: size.height * 0.38),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.enableSearch && widget.options.length > 3) ...[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 34,
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setOverlayState(() {
                                      _searchQuery = val.trim().toLowerCase();
                                    });
                                  },
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ],
                          Flexible(
                            child: filteredOptions.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'No options found',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : ListView(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    children: filteredOptions.map((opt) {
                                      final isSelected = opt == widget.value;
                                      return InkWell(
                                        onTap: () {
                                          widget.onSelected(opt);
                                          _removeOverlay();
                                          if (mounted) {
                                            setState(() {
                                              _isOpen = false;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          color: isSelected
                                              ? const Color(0xFFF8FAFC)
                                              : Colors.white,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  opt,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w500,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: AppColors.textPrimary,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final valueSize = (size.width * 0.009).clamp(11.0, 13.0);

    return CompositedTransformTarget(
      link: _link,
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(DashboardGap.radius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: (size.width * 0.012).clamp(10.0, 16.0),
            vertical: (size.height * 0.012).clamp(8.0, 14.0),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DashboardGap.radius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateFilterInlineChip extends StatefulWidget {
  const _DateFilterInlineChip({
    required this.value,
    required this.onSelected,
  });

  final String value;
  final ValueChanged<DateTimeRange?> onSelected;

  @override
  State<_DateFilterInlineChip> createState() => _DateFilterInlineChipState();
}

class _DateFilterInlineChipState extends State<_DateFilterInlineChip> {
  final _link = LayerLink();
  OverlayEntry? _entry;
  bool _isOpen = false;

  final List<String> _dateOptions = const [
    'All dates',
    'Today',
    'Last 7 days',
    'Last 30 days',
    'This month',
    'Custom range',
  ];

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
    _isOpen = false;
  }

  void _toggle() {
    if (_isOpen) {
      _removeOverlay();
      setState(() {
        _isOpen = false;
      });
    } else {
      _showOverlay();
      setState(() {
        _isOpen = true;
      });
    }
  }

  Future<void> _handleOptionSelect(String choice) async {
    _removeOverlay();
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }

    if (choice == 'All dates') {
      widget.onSelected(null);
      return;
    }
    final now = DateUtils.dateOnly(DateTime.now());
    if (choice == 'Custom range') {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(now.year + 10),
      );
      if (range != null) widget.onSelected(range);
      return;
    }
    final start = switch (choice) {
      'Last 7 days' => now.subtract(const Duration(days: 7)),
      'Last 30 days' => now.subtract(const Duration(days: 30)),
      'This month' => DateTime(now.year, now.month),
      _ => now,
    };
    widget.onSelected(DateTimeRange(start: start, end: now));
  }

  void _showOverlay() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final buttonWidth = renderBox?.size.width ?? 200.0;
    final menuWidth = buttonWidth.clamp(180.0, 260.0);
    final size = MediaQuery.sizeOf(context);

    _entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeOverlay();
                  if (mounted) {
                    setState(() {
                      _isOpen = false;
                    });
                  }
                },
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: const Offset(0, 44),
              child: Material(
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: menuWidth,
                  constraints: BoxConstraints(maxHeight: size.height * 0.38),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: _dateOptions.map((opt) {
                      final isSelected = widget.value.contains(opt);
                      return InkWell(
                        onTap: () => _handleOptionSelect(opt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          color: isSelected
                              ? const Color(0xFFF8FAFC)
                              : Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.textPrimary,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final valueSize = (size.width * 0.009).clamp(11.0, 13.0);

    return CompositedTransformTarget(
      link: _link,
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(DashboardGap.radius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: (size.width * 0.012).clamp(10.0, 16.0),
            vertical: (size.height * 0.012).clamp(8.0, 14.0),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DashboardGap.radius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.value.startsWith('Date:')
                      ? widget.value
                      : 'Date: ${widget.value}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
