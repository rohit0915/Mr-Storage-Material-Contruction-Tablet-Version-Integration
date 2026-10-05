import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/services/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_logger.dart';
import '../controllers/project_calendar_controller.dart';
import '../models/project_calendar_models.dart';
import '../services/project_calendar_service.dart';

class AddDeliveryResult {
  const AddDeliveryResult({
    required this.date,
    required this.leadId,
    required this.title,
    this.sectionLocation,
    this.description,
    this.notes,
    this.deliveryData,
  });

  final DateTime date;
  final String leadId;
  final String title;
  final String? sectionLocation;
  final String? description;
  final String? notes;
  final Map<String, dynamic>? deliveryData;
}

class AddDeliveryDialog extends StatefulWidget {
  const AddDeliveryDialog({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<AddDeliveryDialog> createState() => _AddDeliveryDialogState();
}

class _AddDeliveryDialogState extends State<AddDeliveryDialog> {
  final _titleCtrl = TextEditingController();
  final _sectionCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedProjectId;
  late DateTime _date;
  final List<String> _attachedFiles = [];
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final ctrl = Get.isRegistered<ProjectCalendarController>()
        ? Get.find<ProjectCalendarController>()
        : null;

    if (widget.initialDate != null) {
      _date = widget.initialDate!;
    } else if (ctrl != null) {
      final f = ctrl.focusedMonth.value;
      final day = ctrl.selectedDay.value.clamp(1, 28);
      _date = DateTime(f.year, f.month, day);
    } else {
      _date = DateTime.now();
    }

    if (ctrl != null &&
        ctrl.selectedProjectId.value.isNotEmpty &&
        ctrl.projects.any((p) => p.id == ctrl.selectedProjectId.value)) {
      _selectedProjectId = ctrl.selectedProjectId.value;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _sectionCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'docx', 'xlsx'],
      );
      if (result.isNotEmpty) {
        setState(() {
          for (final f in result) {
            if (!_attachedFiles.contains(f.name)) {
              _attachedFiles.add(f.name);
            }
          }
        });
      }
    } catch (e) {
      AppLogger.w('File picking error or cancelled: $e', tag: 'ADD_DELIVERY');
    }
  }

  Future<void> _onSaveDelivery() async {
    if (_isSubmitting) return;

    if (_selectedProjectId == null || _selectedProjectId!.isEmpty) {
      setState(() => _errorMessage = 'Please select a project');
      Get.snackbar(
        'Validation Error',
        'Please select a project to associate this delivery with.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.badgeRed,
        colorText: Colors.white,
      );
      return;
    }

    final title = _titleCtrl.text.trim().isNotEmpty
        ? _titleCtrl.text.trim()
        : 'Primary Frame Steel';

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final calendarService = Get.find<ProjectCalendarService>();
      final deliveryData = await calendarService.createDelivery(
        leadId: _selectedProjectId!,
        title: title,
        sectionLocation: _sectionCtrl.text.trim().isNotEmpty
            ? _sectionCtrl.text.trim()
            : null,
        deliveryDate: _date,
        description: _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : null,
        notes: _notesCtrl.text.trim().isNotEmpty
            ? _notesCtrl.text.trim()
            : null,
        attachments: _attachedFiles.isNotEmpty ? _attachedFiles : null,
      );

      if (mounted) {
        Navigator.of(context).pop(
          AddDeliveryResult(
            date: _date,
            leadId: _selectedProjectId!,
            title: title,
            sectionLocation: _sectionCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            notes: _notesCtrl.text.trim(),
            deliveryData: deliveryData,
          ),
        );
      }
    } on ApiException catch (e) {
      AppLogger.e('createDelivery ApiException: ${e.message}', tag: 'ADD_DELIVERY');
      setState(() => _errorMessage = e.message);
      Get.snackbar(
        'Delivery Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.badgeRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      AppLogger.e('createDelivery Error: $e', tag: 'ADD_DELIVERY');
      setState(() => _errorMessage = e.toString());
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.badgeRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width * 0.44).clamp(440.0, 560.0);
    final controller = Get.isRegistered<ProjectCalendarController>()
        ? Get.find<ProjectCalendarController>()
        : null;

    final projectOptions = (controller?.projects ?? <CalendarProjectOption>[])
        .where((p) => p.id.isNotEmpty)
        .toList();

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
        vertical: size.height * 0.03,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: size.height * 0.92,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Delivery',
                            style: TextStyle(
                              fontSize: (size.width * 0.016).clamp(18.0, 21.0),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Schedule a material shipment for a construction site',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 22),
                      splashRadius: 20,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // 2. Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section Header
                      const Text(
                        'DELIVERY INFORMATION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Error banner if any issue occurred
                      if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.badgeRed,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.badgeRed,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Field 1: Title (Recommended)
                      _buildRichLabel('Title', '(Recommended)'),
                      _buildTextField(
                        controller: _titleCtrl,
                        hint: 'e.g. Primary Frame Steel',
                      ),
                      const SizedBox(height: 14),

                      // Field 2: Project *
                      _buildRichLabel('Project', '*', isRequired: true),
                      _buildProjectDropdown(projectOptions),
                      const SizedBox(height: 14),

                      // Field 3: Section / Location (Optional)
                      _buildRichLabel('Section / Location', '(Optional)'),
                      _buildTextField(
                        controller: _sectionCtrl,
                        hint: 'e.g. Building A - Front Elevation',
                        suffixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Field 4: Delivery Date *
                      _buildRichLabel('Delivery Date', '*', isRequired: true),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(10),
                        child: InputDecorator(
                          decoration: _inputDecoration().copyWith(
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          child: Text(
                            '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Field 5: Description (Optional)
                      _buildRichLabel('Description', '(Optional)'),
                      _buildTextField(
                        controller: _descCtrl,
                        hint: 'e.g. Structural steel delivery for phase 1',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),

                      // Field 6: Notes (Optional)
                      _buildRichLabel('Notes', '(Optional)'),
                      _buildTextField(
                        controller: _notesCtrl,
                        hint: 'e.g. Requires forklift for unloading',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),

                      // Field 7: Attachments (Optional)
                      _buildRichLabel('Attachments', '(Optional)'),
                      _buildUploadBox(),
                      if (_attachedFiles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _attachedFiles
                              .map(
                                (fileName) => Chip(
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  label: Text(
                                    fileName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  onDeleted: () {
                                    setState(() => _attachedFiles.remove(fileName));
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // 3. Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _onSaveDelivery,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Delivery',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRichLabel(String title, String subtitle, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: '$title ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          children: [
            TextSpan(
              text: subtitle,
              style: TextStyle(
                fontWeight: isRequired ? FontWeight.w700 : FontWeight.w400,
                fontSize: 12,
                color: isRequired ? AppColors.badgeRed : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: _inputDecoration(hint: hint, suffixIcon: suffixIcon),
    );
  }

  Widget _buildProjectDropdown(List<CalendarProjectOption> options) {
    return DropdownButtonFormField<String>(
      key: ValueKey(_selectedProjectId ?? 'select_project'),
      initialValue: _selectedProjectId,
      isExpanded: true,
      isDense: true,
      decoration: _inputDecoration(),
      hint: const Text(
        'Select Project',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.textSecondary,
        size: 20,
      ),
      items: options.map((p) {
        final label = p.code.isNotEmpty ? '${p.name} (${p.code})' : p.name;
        return DropdownMenuItem<String>(
          value: p.id,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        );
      }).toList(),
      onChanged: (val) {
        setState(() => _selectedProjectId = val);
      },
    );
  }

  Widget _buildUploadBox() {
    return InkWell(
      onTap: _pickFiles,
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFFCBD5E1),
          strokeWidth: 1.2,
          radius: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.file_upload_outlined,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Click to upload',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: ' or drag and drop',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Documents, packing slips, drawings, photos (PDF, PNG, JPG)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  _DashedBorderPainter({
    this.color = const Color(0xFFCBD5E1),
    this.strokeWidth = 1.2,
    this.radius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 6.0;
    const gap = 4.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + dash < metric.length)
            ? dash
            : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DeliverySuccessDialog extends StatelessWidget {
  const DeliverySuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = (size.width * 0.32).clamp(320.0, 420.0);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.successCheck,
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  'Delivery Added\nSuccessfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
