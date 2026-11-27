import 'package:flutter/material.dart';
import '../services/walkthrough_voice_service.dart';

/// Welcome Modal Dialog matching the official visual reference:
/// - Dark transparent backdrop
/// - Centered white card with rounded corners (18px) and multi-layered elevation shadow
/// - Circular exploration compass icon badge
/// - Title with sparkle emoji
/// - Dynamically calculated duration in subtitle and action button (e.g. "4 min")
/// - Toggleable Voice Guidance pill badge
/// - Responsive full-width action buttons preventing text overflow
/// - Close (X) icon at top-right
class WalkthroughWelcomeDialog extends StatefulWidget {
  const WalkthroughWelcomeDialog({
    super.key,
    required this.onStartTour,
    required this.onExploreOnOwn,
    required this.voiceService,
    this.durationMinutes = 4,
    this.title = 'Welcome to Steel Building Depot – Field Construction ✨',
    this.subtitle,
  });

  final VoidCallback onStartTour;
  final VoidCallback onExploreOnOwn;
  final WalkthroughVoiceService voiceService;
  final int durationMinutes;
  final String title;
  final String? subtitle;

  String get resolvedSubtitle =>
      subtitle ??
      'Would you like a quick $durationMinutes-minute guided tour of your active jobsites, drawing attachments, material requests, daily work logs, and dispatch tracking?';

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onStartTour,
    required VoidCallback onExploreOnOwn,
    required WalkthroughVoiceService voiceService,
    int durationMinutes = 4,
    String? title,
    String? subtitle,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0xB8090D1A),
      builder: (dialogContext) {
        return WalkthroughWelcomeDialog(
          onStartTour: () {
            Navigator.of(dialogContext, rootNavigator: true).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onStartTour();
            });
          },
          onExploreOnOwn: () {
            Navigator.of(dialogContext, rootNavigator: true).pop();
            onExploreOnOwn();
          },
          voiceService: voiceService,
          durationMinutes: durationMinutes,
          title: title ?? 'Welcome to Steel Building Depot – Field Construction ✨',
          subtitle: subtitle,
        );
      },
    );
  }

  @override
  State<WalkthroughWelcomeDialog> createState() => _WalkthroughWelcomeDialogState();
}

class _WalkthroughWelcomeDialogState extends State<WalkthroughWelcomeDialog> {
  late bool _voiceEnabled;

  @override
  void initState() {
    super.initState();
    _voiceEnabled = widget.voiceService.isVoiceEnabled.value;
  }

  void _toggleVoice() {
    setState(() {
      _voiceEnabled = !_voiceEnabled;
    });
    widget.voiceService.setVoiceEnabled(_voiceEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth - 36).clamp(300.0, 440.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Center(
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar with Close (X) Icon
              Align(
                alignment: Alignment.topRight,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onExploreOnOwn,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),

              // Circular Compass Icon Badge
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFDBEAFE),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.explore_outlined,
                    color: Color(0xFF2563EB),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title with Sparkle
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                widget.resolvedSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),

              // Toggle Voice Guidance Badge
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleVoice,
                  borderRadius: BorderRadius.circular(20),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: _voiceEnabled ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _voiceEnabled ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          size: 14,
                          color: _voiceEnabled ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _voiceEnabled ? 'Voice Guidance: Enabled' : 'Voice Guidance: Disabled',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _voiceEnabled ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons: Stacked vertically with full width to guarantee no text wrapping
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Start Tour Button (Full Width Primary Blue Button)
                  Material(
                    color: const Color(0xFF1E5BD8),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: widget.onStartTour,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.5),
                        child: Center(
                          child: Text(
                            'Start Quick Tour (${widget.durationMinutes} min)',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Explore On My Own Button (Full Width Outlined Secondary Button)
                  Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                    ),
                    child: InkWell(
                      onTap: widget.onExploreOnOwn,
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 11.5),
                        child: Center(
                          child: Text(
                            'Explore on My Own',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),
                          ),
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
