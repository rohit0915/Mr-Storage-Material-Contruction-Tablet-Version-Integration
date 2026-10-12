import 'package:flutter/material.dart';
import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import 'scanner_dialog.dart';
import '../../delivery_tracking/services/delivery_tracking_service.dart';
import '../../../app/widgets/app_searchable_dropdown.dart';
import '../../../app/utils/app_toast.dart';

// ─── Success popup ────────────────────────────────────────────────────────────

class BundleScanSuccessDialog extends StatelessWidget {
  const BundleScanSuccessDialog({super.key, required this.title});
  final String title;

  static Future<void> show(BuildContext context, String title) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => BundleScanSuccessDialog(title: title),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.82,
          maxWidth: (size.width * 0.34).clamp(340.0, 440.0),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.14,
                  maxWidth: 110,
                ),
                child: Image.asset(AppAssets.successCheck, fit: BoxFit.contain),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Scan Delivery QR Dialog ──────────────────────────────────────────────────

class BundleScanQrDialog extends StatefulWidget {
  const BundleScanQrDialog({
    super.key,
    this.projectId,
    this.showProjectDropdown = true,
    this.onScanned,
  });

  final String? projectId;
  final bool showProjectDropdown;
  final void Function(String bundleId, String? projectId)? onScanned;

  static Future<void> show(
    BuildContext context, {
    String? projectId,
    bool showProjectDropdown = true,
    void Function(String bundleId, String? projectId)? onScanned,
  }) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BundleScanQrDialog(
      projectId: projectId,
      showProjectDropdown: showProjectDropdown,
      onScanned: onScanned,
    ),
  );

  @override
  State<BundleScanQrDialog> createState() => _BundleScanQrDialogState();
}

class _BundleScanQrDialogState extends State<BundleScanQrDialog> {
  final _ctrl = TextEditingController();
  List<AppDropdownItem<String>> _projects = [];
  String? _selectedProjectId;
  bool _isLoadingProjects = true;

  bool get _shouldShowProject =>
      widget.showProjectDropdown &&
      (widget.projectId == null || widget.projectId!.isEmpty);

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
    if (_shouldShowProject) {
      _loadProjects();
    } else {
      _isLoadingProjects = false;
    }
  }

  Future<void> _loadProjects() async {
    try {
      final service = DeliveryTrackingService();
      final pList = await service.getProjects();
      if (mounted) {
        setState(() {
          _projects = pList
              .map((e) => AppDropdownItem<String>(
                    value: e['id'] ?? '',
                    label: e['name'] ?? 'Unknown',
                  ))
              .toList();
          _isLoadingProjects = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProjects = false);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.90,
          maxWidth: (size.width * 0.42).clamp(380.0, 520.0),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Title and Close button
              Row(
                children: [
                  const SizedBox(width: 32),
                  const Expanded(
                    child: Text(
                      'Scan Delivery QR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Scan the QR code attached to the delivery challan or enter the Bundle ID manually.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),

              // Camera Scan button
              ElevatedButton.icon(
                onPressed: () async {
                  final nav = Navigator.of(context);
                  final scanned = await ScannerDialog.show(context);
                  if (scanned != null && scanned.isNotEmpty && mounted) {
                    nav.pop();
                    final effectiveProjectId =
                        (widget.projectId != null && widget.projectId!.isNotEmpty)
                            ? widget.projectId
                            : _selectedProjectId;
                    widget.onScanned?.call(scanned, effectiveProjectId);
                  }
                },
                icon: const Icon(
                  Icons.photo_camera_outlined,
                  size: 20,
                  color: Colors.white,
                ),
                label: const Text(
                  'Camera Scan',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4338CA),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // OR divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: const [
                    Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                  ],
                ),
              ),

              // Select Project section
              if (_shouldShowProject) ...[
                Row(
                  children: const [
                    Text(
                      'Select Project ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '(Required for manual entry)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                _isLoadingProjects
                    ? const SizedBox(
                        height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : AppSearchableDropdown<String>(
                        items: _projects,
                        value: _selectedProjectId,
                        hint: 'Select Project',
                        onChanged: (val) {
                          setState(() => _selectedProjectId = val);
                        },
                      ),
                const SizedBox(height: 20),
              ],

              // Enter Bundle ID label
              const Text(
                'Enter Bundle ID',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),

              // Input field
              TextField(
                controller: _ctrl,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. B-001',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF4338CA), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E8F0),
                        foregroundColor: const Color(0xFF334155),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final val = _ctrl.text.trim();
                        if (val.isEmpty) {
                          AppToast.showError(title: 'Please enter a bundle ID');
                          return;
                        }
                        final effectiveProjectId =
                            (widget.projectId != null && widget.projectId!.isNotEmpty)
                                ? widget.projectId
                                : _selectedProjectId;
                        if (_shouldShowProject &&
                            (effectiveProjectId == null || effectiveProjectId.isEmpty)) {
                          AppToast.showError(title: 'Please select a project');
                          return;
                        }
                        Navigator.of(context).pop();
                        widget.onScanned?.call(val, effectiveProjectId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF818CF8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Scan',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
