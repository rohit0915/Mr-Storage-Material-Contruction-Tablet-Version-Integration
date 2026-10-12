import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  void _handlePresetSelect(String choice) {
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
    final start = switch (choice) {
      'Last 7 Days' || 'Last 7 days' => now.subtract(const Duration(days: 7)),
      'Last 30 Days' || 'Last 30 days' => now.subtract(const Duration(days: 30)),
      'This Month' || 'This month' => DateTime(now.year, now.month),
      _ => now,
    };
    widget.onSelected(DateTimeRange(start: start, end: now));
  }

  void _handleCustomApply(DateTimeRange? range) {
    _removeOverlay();
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
    widget.onSelected(range);
  }

  void _showOverlay() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = MediaQuery.sizeOf(context);
    const cardWidth = 320.0;
    final targetOffset = renderBox != null
        ? renderBox.localToGlobal(Offset.zero)
        : Offset.zero;
    final dxOffset = (targetOffset.dx + cardWidth > size.width - 16)
        ? (size.width - 16 - targetOffset.dx - cardWidth)
        : 0.0;

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
              offset: Offset(dxOffset, 44),
              child: Material(
                elevation: 10,
                shadowColor: Colors.black.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                child: _DateFilterCard(
                  currentValue: widget.value,
                  onPresetSelected: _handlePresetSelect,
                  onApplyCustom: _handleCustomApply,
                  onClose: () {
                    _removeOverlay();
                    if (mounted) {
                      setState(() {
                        _isOpen = false;
                      });
                    }
                  },
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
    final displayLabel = widget.value == 'All dates'
        ? 'All dates'
        : (widget.value.startsWith('Date:')
            ? widget.value
            : 'Date: ${widget.value}');

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
                  displayLabel,
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

class _DateFilterCard extends StatefulWidget {
  const _DateFilterCard({
    required this.currentValue,
    required this.onPresetSelected,
    required this.onApplyCustom,
    required this.onClose,
  });

  final String currentValue;
  final ValueChanged<String> onPresetSelected;
  final ValueChanged<DateTimeRange?> onApplyCustom;
  final VoidCallback onClose;

  @override
  State<_DateFilterCard> createState() => _DateFilterCardState();
}

class _DateFilterCardState extends State<_DateFilterCard> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _activePreset;
  String? _activeField; // 'from' | 'to' | null

  @override
  void initState() {
    super.initState();
    _parseInitialDates();
  }

  void _parseInitialDates() {
    final val = widget.currentValue.replaceFirst('Date: ', '').trim();
    if (val == 'All dates' || val.isEmpty) {
      _activePreset = 'All dates';
      return;
    }
    if (val.contains(' - ')) {
      final parts = val.split(' - ');
      try {
        final f = DateFormat('dd MMM yyyy');
        _fromDate = f.parse(parts[0].trim());
        _toDate = f.parse(parts[1].trim());
      } catch (_) {}
    }
  }

  void _onFieldTap(String field) {
    setState(() {
      if (_activeField == field) {
        _activeField = null;
      } else {
        _activeField = field;
      }
    });
  }

  DateTime _safeInitialDate(DateTime? preferred, DateTime first, DateTime last) {
    final target = preferred ?? DateTime.now();
    if (target.isBefore(first)) return first;
    if (target.isAfter(last)) return last;
    return target;
  }

  void _onCalendarDateChanged(DateTime date) {
    setState(() {
      if (_activeField == 'from') {
        _fromDate = date;
        if (_toDate != null && _toDate!.isBefore(date)) {
          _toDate = date;
        }
        _activeField = 'to'; // smoothly move to end date selection
      } else {
        _toDate = date;
        if (_fromDate != null && date.isBefore(_fromDate!)) {
          _fromDate = date;
        }
      }
      _activePreset = null;
    });
  }

  Widget _buildPresetChip(String label) {
    final isSelected = _activePreset == label;
    return InkWell(
      onTap: () {
        widget.onPresetSelected(label);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppColors.primaryBlue
                : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxHeight: size.height * 0.8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FILTER BY DATE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip('Today'),
                _buildPresetChip('Last 7 Days'),
                _buildPresetChip('Last 30 Days'),
                _buildPresetChip('This Month'),
                _buildPresetChip('All dates'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'FROM DATE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _onFieldTap('from'),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _activeField == 'from'
                        ? AppColors.primaryBlue
                        : const Color(0xFFCBD5E1),
                    width: _activeField == 'from' ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _fromDate != null
                            ? DateFormat('dd/MM/yyyy').format(_fromDate!)
                            : 'dd/mm/yyyy',
                        style: TextStyle(
                          fontSize: 12,
                          color: _fromDate != null
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: _activeField == 'from'
                          ? AppColors.primaryBlue
                          : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'TO DATE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _onFieldTap('to'),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _activeField == 'to'
                        ? AppColors.primaryBlue
                        : const Color(0xFFCBD5E1),
                    width: _activeField == 'to' ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _toDate != null
                            ? DateFormat('dd/MM/yyyy').format(_toDate!)
                            : 'dd/mm/yyyy',
                        style: TextStyle(
                          fontSize: 12,
                          color: _toDate != null
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: _activeField == 'to'
                          ? AppColors.primaryBlue
                          : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
            if (_activeField != null) ...[
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 8, 2),
                      child: Row(
                        children: [
                          Text(
                            _activeField == 'from'
                                ? 'Select Start Date'
                                : 'Select End Date',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _activeField = null;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primaryBlue,
                          onPrimary: Colors.white,
                          surface: Color(0xFFF8FAFC),
                          onSurface: Color(0xFF1E293B),
                        ),
                      ),
                      child: SizedBox(
                        height: 275,
                        child: CalendarDatePicker(
                          key: ValueKey(_activeField),
                          initialDate: _safeInitialDate(
                            _activeField == 'to' ? _toDate : _fromDate,
                            DateTime(2020),
                            DateTime(2035),
                          ),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          onDateChanged: _onCalendarDateChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (_fromDate != null || _toDate != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _fromDate = null;
                        _toDate = null;
                        _activeField = null;
                        _activePreset = 'All dates';
                      });
                      widget.onPresetSelected('All dates');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(48, 32),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (_fromDate != null && _toDate != null) {
                      widget.onApplyCustom(
                        DateTimeRange(start: _fromDate!, end: _toDate!),
                      );
                    } else if (_fromDate != null) {
                      widget.onApplyCustom(
                        DateTimeRange(start: _fromDate!, end: _fromDate!),
                      );
                    } else if (_toDate != null) {
                      widget.onApplyCustom(
                        DateTimeRange(start: _toDate!, end: _toDate!),
                      );
                    } else {
                      widget.onApplyCustom(null);
                    }
                    widget.onClose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    minimumSize: const Size(64, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

