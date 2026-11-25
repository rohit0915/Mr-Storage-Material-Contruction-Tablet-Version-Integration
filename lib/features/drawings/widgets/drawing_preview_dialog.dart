import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../models/drawing_models.dart';

class DrawingPreviewDialog extends StatelessWidget {
  const DrawingPreviewDialog({super.key, required this.file});

  final DrawingFileItem file;

  String get _fileUrl {
    final raw = file.fileUrl.isNotEmpty
        ? file.fileUrl
        : (file.previewAssets.isNotEmpty ? file.previewAssets.first : '');
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('assets/')) return trimmed;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      if (trimmed.startsWith('/')) {
        return '${ApiConstants.serverOrigin}$trimmed';
      }
      return '${ApiConstants.serverOrigin}/$trimmed';
    }
    return trimmed;
  }

  bool get _isPdf =>
      file.fileType == DrawingFileType.pdf ||
      _fileUrl.toLowerCase().contains('.pdf') ||
      file.name.toLowerCase().endsWith('.pdf');

  bool get _isVideo =>
      file.fileType == DrawingFileType.video ||
      _fileUrl.toLowerCase().endsWith('.mp4') ||
      _fileUrl.toLowerCase().endsWith('.mov') ||
      file.name.toLowerCase().endsWith('.mp4');

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: (size.width * 0.05).clamp(16.0, 48.0),
        vertical: (size.height * 0.035).clamp(16.0, 36.0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: (size.width * 0.88).clamp(320.0, 960.0),
          height: (size.height * 0.86).clamp(420.0, 800.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: (size.width * 0.016).clamp(16.0, 22.0),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            file.versionLabel.isNotEmpty
                                ? file.versionLabel
                                : (file.projectCode.isNotEmpty
                                    ? file.projectCode
                                    : 'Version 1'),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          Expanded(
                            child: _MetaCol(
                              label: 'Location',
                              value: file.location.isNotEmpty
                                  ? file.location
                                  : '-',
                            ),
                          ),
                          Expanded(
                            child: _MetaCol(
                              label: 'Uploaded By:',
                              value: DrawingFileItem.formatUploadedBy(
                                file.uploadedBy,
                                fallback: 'Site Construction',
                              ),
                            ),
                          ),
                          Expanded(
                            child: _MetaCol(
                              label: 'Received on',
                              value: file.receivedOn.isNotEmpty
                                  ? file.receivedOn
                                  : '-',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              // Rejected Alert Banner (if rejected with reason)
              if (file.status.toLowerCase().contains('reject') &&
                  file.rejectionReason.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFDC2626),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Drawing Rejected — Reason: ${file.rejectionReason}',
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 1, color: AppColors.cardBorder),

              // Preview Content Body
              Expanded(
                child: Container(
                  color: const Color(0xFFF8FAFC),
                  padding: _isPdf ? const EdgeInsets.all(6) : const EdgeInsets.all(20),
                  child: _buildPreviewBody(context),
                ),
              ),

              // Bottom Action Bar (Download & Status Badge)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.cardBorder)),
                ),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _triggerDownload(context),
                      icon: const Icon(Icons.arrow_downward, size: 16),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF94A3B8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildStatusPill(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewBody(BuildContext context) {
    final url = _fileUrl;

    if (_isPdf) {
      return _InlinePdfViewer(
        url: url,
        fileName: file.name,
      );
    }

    if (_isVideo) {
      return Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  size: 42,
                  color: Color(0xFF9333EA),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                file.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _openExternal(context),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Play Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Image Preview with interactive zoom and error fallback
    return InteractiveViewer(
      minScale: 0.6,
      maxScale: 5.0,
      child: Center(
        child: _buildNetworkOrAssetImage(url),
      ),
    );
  }

  Widget _buildNetworkOrAssetImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.high,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.broken_image_outlined,
                  size: 56,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Failed to load image preview',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => _openExternal(context),
                  child: const Text('Open image directly in browser'),
                ),
              ],
            ),
          );
        },
      );
    }

    if (url.isNotEmpty) {
      return Image.asset(
        url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.high,
      );
    }

    return const Center(
      child: Icon(
        Icons.image_outlined,
        size: 56,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildStatusPill() {
    final status = file.status.isNotEmpty ? file.status : 'Approved';
    final lower = status.toLowerCase();

    Color bgColor = const Color(0xFF22C55E);
    if (lower.contains('reject')) {
      bgColor = const Color(0xFFEF4444);
    } else if (lower.contains('pending')) {
      bgColor = const Color(0xFFF59E0B);
    } else if (lower.contains('revision')) {
      bgColor = const Color(0xFFEA580C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Future<void> _openExternal(BuildContext context) async {
    final url = _fileUrl;
    if (url.isEmpty || (!url.startsWith('http://') && !url.startsWith('https://'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File link is not available for ${file.name}.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    try {
      final uri = Uri.parse(Uri.encodeFull(url));
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _triggerDownload(BuildContext context) async {
    final url = _fileUrl;
    if (url.isEmpty || (!url.startsWith('http://') && !url.startsWith('https://'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download URL not available for ${file.name}'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${file.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final uri = Uri.parse(Uri.encodeFull(url));
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not download file: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}

class _MetaCol extends StatelessWidget {
  const _MetaCol({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _InlinePdfViewer extends StatefulWidget {
  const _InlinePdfViewer({
    required this.url,
    required this.fileName,
  });

  final String url;
  final String fileName;

  @override
  State<_InlinePdfViewer> createState() => _InlinePdfViewerState();
}

class _InlinePdfViewerState extends State<_InlinePdfViewer> {
  late Future<Uint8List> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _pdfFuture = _fetchPdfBytes(widget.url);
  }

  @override
  void didUpdateWidget(covariant _InlinePdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _pdfFuture = _fetchPdfBytes(widget.url);
    }
  }

  Future<Uint8List> _fetchPdfBytes(String rawUrl) async {
    final clean = rawUrl.trim();
    if (clean.isEmpty) {
      throw Exception('PDF document URL is empty or unavailable.');
    }

    // 1. Asset file
    if (clean.startsWith('assets/')) {
      final byteData = await rootBundle.load(clean);
      return byteData.buffer.asUint8List();
    }

    // 2. Local device file (non-web only)
    if (!kIsWeb && clean.startsWith('file://')) {
      final file = File(clean.replaceFirst('file://', ''));
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    }

    // 3. Network URL
    String targetUrl = clean;
    if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
      if (targetUrl.startsWith('/')) {
        targetUrl = '${ApiConstants.serverOrigin}$targetUrl';
      } else {
        targetUrl = '${ApiConstants.serverOrigin}/$targetUrl';
      }
    }

    Uri uri;
    try {
      uri = Uri.parse(targetUrl);
    } catch (_) {
      uri = Uri.parse(Uri.encodeFull(targetUrl));
    }

    // Check if target is backend host or external storage (e.g. AWS S3, Cloudinary)
    final serverHost =
        Uri.tryParse(ApiConstants.serverOrigin)?.host.toLowerCase() ?? '';
    final uriHost = uri.host.toLowerCase();
    final isInternalBackend = uriHost.isEmpty ||
        uriHost == serverHost ||
        uriHost.contains('onrender.com') ||
        uriHost.contains('flyweis');

    // Only attach Authorization header if target is within our backend domain.
    // Sending Bearer token to AWS S3 pre-signed URLs triggers HTTP 400 Bad Request
    // ("Only one auth mechanism allowed").
    final headers = <String, String>{};
    if (isInternalBackend && Get.isRegistered<ApiClient>()) {
      final token = Get.find<ApiClient>().token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    http.Response? response;
    Object? lastError;

    // First attempt: with target headers
    try {
      response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 25));
    } catch (e) {
      lastError = e;
    }

    // If request failed with 400 and headers were present, retry without Authorization header
    if (response != null && response.statusCode == 400 && headers.isNotEmpty) {
      try {
        response = await http.get(uri).timeout(const Duration(seconds: 25));
      } catch (e) {
        lastError = e;
      }
    }

    // If request failed with 401/403 and headers were empty, retry with Authorization header
    if (response != null &&
        (response.statusCode == 401 || response.statusCode == 403) &&
        headers.isEmpty) {
      if (Get.isRegistered<ApiClient>()) {
        final token = Get.find<ApiClient>().token;
        if (token != null && token.isNotEmpty) {
          try {
            response = await http
                .get(uri, headers: {'Authorization': 'Bearer $token'})
                .timeout(const Duration(seconds: 25));
          } catch (e) {
            lastError = e;
          }
        }
      }
    }

    // In web browser: if direct fetch failed with CORS / ClientException ("Failed to fetch"),
    // attempt proxy fallback so external test files can be loaded and viewed in-app
    if ((response == null ||
            response.statusCode < 200 ||
            response.statusCode >= 300) &&
        kIsWeb) {
      final isCorsOrFetchErr = lastError != null &&
          lastError.toString().toLowerCase().contains('failed to fetch');
      if (isCorsOrFetchErr || response?.statusCode == 403) {
        try {
          final proxyUri = Uri.parse(
            'https://api.allorigins.win/raw?url=${Uri.encodeComponent(targetUrl)}',
          );
          final proxyRes =
              await http.get(proxyUri).timeout(const Duration(seconds: 25));
          if (proxyRes.statusCode >= 200 &&
              proxyRes.statusCode < 300 &&
              proxyRes.bodyBytes.isNotEmpty) {
            return proxyRes.bodyBytes;
          }
        } catch (_) {
          // Ignore proxy error and throw informative error below
        }
      }
    }

    if (response != null) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.bodyBytes.isEmpty) {
          throw Exception('The returned PDF file is empty (0 bytes).');
        }
        return response.bodyBytes;
      }
      throw Exception(
        'Server returned status code ${response.statusCode} while loading PDF.\nURL: $targetUrl',
      );
    }

    if (lastError != null) {
      final errStr = lastError.toString();
      if (errStr.contains('Failed to fetch')) {
        throw Exception(
          'Failed to fetch PDF due to browser cross-origin policy (CORS).\nURL: $targetUrl',
        );
      }
      throw Exception(
        'Failed to connect to PDF server: $errStr\nURL: $targetUrl',
      );
    }

    throw Exception('Unable to load PDF document.\nURL: $targetUrl');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _pdfFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading PDF Document...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Rendering sheets in-app...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          final rawErr =
              snapshot.error?.toString() ?? 'Could not render PDF document.';
          final cleanErr = rawErr.startsWith('Exception: ')
              ? rawErr.substring('Exception: '.length)
              : rawErr;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        size: 36,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.fileName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: SelectableText(
                        cleanErr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: Color(0xFFBE123C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _pdfFuture = _fetchPdfBytes(widget.url);
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final bytes = snapshot.data!;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: const Color(0xFF525659),
            child: PdfPreview(
              build: (format) async => bytes,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              allowPrinting: true,
              allowSharing: true,
              pdfFileName: widget.fileName,
              previewPageMargin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}

