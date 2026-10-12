import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Item definition for [AppSearchableDropdown]
class AppDropdownItem<T> {
  const AppDropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.badge,
    this.icon,
  });

  final T value;
  final String label;
  final String? subtitle;
  final String? badge;
  final IconData? icon;
}

/// A modern, tablet-optimized searchable dropdown component.
///
/// Features:
/// - Inline search filter when list exceeds 5 items
/// - Constrained max height (prevents full-screen Material popup overlay)
/// - Rounded corners, elegant border, and subtle shadow
/// - Automatic position adjustment (opens above or below based on screen space)
/// - Selected item highlight with blue background & checkmark
/// - Smooth rotation on chevron indicator
class AppSearchableDropdown<T> extends StatefulWidget {
  const AppSearchableDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint = 'Select',
    this.searchHint = 'Search...',
    this.searchable = true,
    this.height = 40,
    this.menuMaxHeight = 300,
    this.leadingIcon,
    this.enabled = true,
    this.displayMap,
  });

  /// Convenience static constructor for simple String lists
  static AppSearchableDropdown<String> simple({
    Key? key,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    String hint = 'Select',
    String searchHint = 'Search...',
    bool searchable = true,
    double height = 40,
    double menuMaxHeight = 300,
    IconData? leadingIcon,
    bool enabled = true,
    Map<String, String>? displayMap,
  }) {
    final dropdownItems = items.map((item) {
      final display = displayMap?[item] ?? item;
      String label = display;
      String? badge;

      // Extract (#JOBID) or (JOBID) into a badge if present
      final match = RegExp(r'^(.*?)\s*\(#?([A-Za-z0-9\-_]+)\)$').firstMatch(display);
      if (match != null) {
        label = match.group(1)?.trim() ?? display;
        badge = '#${match.group(2)?.replaceAll('#', '')}';
      }

      IconData? icon;
      if (item == 'All Projects') {
        icon = Icons.layers_outlined;
      } else if (item.startsWith('lead-') || display.contains('Storage') || display.contains('Project')) {
        icon = Icons.business_rounded;
      }

      return AppDropdownItem<String>(
        value: item,
        label: label,
        badge: badge,
        icon: icon,
      );
    }).toList();

    return AppSearchableDropdown<String>(
      key: key,
      items: dropdownItems,
      value: value,
      onChanged: onChanged,
      hint: hint,
      searchHint: searchHint,
      searchable: searchable,
      height: height,
      menuMaxHeight: menuMaxHeight,
      leadingIcon: leadingIcon,
      enabled: enabled,
      displayMap: displayMap,
    );
  }

  final List<AppDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String hint;
  final String searchHint;
  final bool searchable;
  final double height;
  final double menuMaxHeight;
  final IconData? leadingIcon;
  final bool enabled;
  final Map<String, String>? displayMap;

  @override
  State<AppSearchableDropdown<T>> createState() => _AppSearchableDropdownState<T>();
}

class _AppSearchableDropdownState<T> extends State<AppSearchableDropdown<T>> {
  final _link = LayerLink();
  final _searchController = TextEditingController();
  OverlayEntry? _entry;
  bool _isOpen = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _removeOverlay(notify: false);
    _searchController.dispose();
    super.dispose();
  }

  void _removeOverlay({bool notify = true}) {
    _entry?.remove();
    _entry = null;
    _isOpen = false;
    _searchQuery = '';
    if (notify && mounted) {
      setState(() {});
    }
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  AppDropdownItem<T>? get _selectedItem {
    if (widget.value == null) return null;
    for (final item in widget.items) {
      if (item.value == widget.value) return item;
    }
    return null;
  }

  void _showOverlay() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.sizeOf(context);

    _searchQuery = '';
    _searchController.clear();

    // Determine whether to show above or below based on available screen space
    final spaceBelow = screenSize.height - (offset.dy + size.height);
    final bool openUpwards = spaceBelow < 260 && offset.dy > spaceBelow;
    final maxAvailable = (openUpwards ? offset.dy - 20 : spaceBelow - 20).clamp(80.0, 600.0);
    final minBound = maxAvailable < 160.0 ? maxAvailable : 160.0;
    final effectiveMaxHeight = widget.menuMaxHeight.clamp(minBound, maxAvailable);

    setState(() => _isOpen = true);

    _entry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setOverlayState) {
            final query = _searchQuery.toLowerCase().trim();
            final filtered = widget.items.where((it) {
              if (query.isEmpty) return true;
              final label = it.label.toLowerCase();
              final badge = (it.badge ?? '').toLowerCase();
              final valStr = it.value.toString().toLowerCase();
              return label.contains(query) || badge.contains(query) || valStr.contains(query);
            }).toList();

            final targetY = openUpwards ? -(effectiveMaxHeight + 4) : (size.height + 4);

            return Stack(
              children: [
                // Backdrop tap detection to close
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _removeOverlay,
                  ),
                ),
                CompositedTransformFollower(
                  link: _link,
                  showWhenUnlinked: false,
                  offset: Offset(0, targetY),
                  child: Material(
                    elevation: 8,
                    shadowColor: Colors.black.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: size.width,
                      constraints: BoxConstraints(
                        maxHeight: effectiveMaxHeight,
                        minWidth: 240,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search Box
                          if (widget.searchable && widget.items.length > 5) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                              child: SizedBox(
                                height: 36,
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setOverlayState(() {
                                      _searchQuery = val;
                                    });
                                  },
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1E293B),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: widget.searchHint,
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      size: 16,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear_rounded, size: 14),
                                            splashRadius: 14,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            color: const Color(0xFF94A3B8),
                                            onPressed: () {
                                              _searchController.clear();
                                              setOverlayState(() => _searchQuery = '');
                                            },
                                          )
                                        : null,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
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
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ],

                          // Items List
                          if (filtered.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              child: Text(
                                'No matching items found',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            )
                          else
                            Flexible(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                shrinkWrap: true,
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final isSelected = item.value == widget.value;

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      widget.onChanged(item.value);
                                      _removeOverlay();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 1.5),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          if (item.icon != null) ...[
                                            Icon(
                                              item.icon,
                                              size: 16,
                                              color: isSelected
                                                  ? AppColors.primaryBlue
                                                  : const Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Expanded(
                                            child: Text(
                                              item.label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                color: isSelected
                                                    ? AppColors.primaryBlue
                                                    : const Color(0xFF1E293B),
                                              ),
                                            ),
                                          ),
                                          if (item.badge != null && item.badge!.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 1.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFFDBEAFE)
                                                    : const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xFFBFDBFE)
                                                      : const Color(0xFFE2E8F0),
                                                ),
                                              ),
                                              child: Text(
                                                item.badge!,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? AppColors.primaryBlue
                                                      : const Color(0xFF475569),
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (isSelected) ...[
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              size: 16,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
    final selected = _selectedItem;
    final displayLabel = selected?.label ?? (widget.value != null ? widget.value.toString() : widget.hint);
    final displayBadge = selected?.badge;
    final displayIcon = selected?.icon ?? widget.leadingIcon;

    return CompositedTransformTarget(
      link: _link,
      child: InkWell(
        onTap: widget.enabled ? _toggleDropdown : null,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isOpen ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
              width: _isOpen ? 1.5 : 1.0,
            ),
            boxShadow: _isOpen
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              if (displayIcon != null) ...[
                Icon(
                  displayIcon,
                  size: 16,
                  color: _isOpen ? AppColors.primaryBlue : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  displayLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected != null ? FontWeight.w600 : FontWeight.w400,
                    color: selected != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              if (displayBadge != null && displayBadge.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    displayBadge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
