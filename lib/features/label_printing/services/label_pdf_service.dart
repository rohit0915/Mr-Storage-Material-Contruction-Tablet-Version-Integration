import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../app/utils/app_logger.dart';
import '../models/label_printing_models.dart';

class LabelPdfService {
  static const String _qrBaseUrl =
      'https://mr-storage-vendor.vercel.app/bundle';

  /// Generates a PDF Document containing labels for one or more bundles.
  /// Each bundle is rendered on its own page matching the web print layout.
  static Future<Uint8List> generateLabelsPdf(List<LabelBundleItem> items) async {
    final pdf = pw.Document();

    for (final item in items) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          build: (pw.Context context) {
            final qrData = item.realMongoId.isNotEmpty
                ? '$_qrBaseUrl/${item.realMongoId}'
                : (item.id.isNotEmpty ? '$_qrBaseUrl/${item.id}' : _qrBaseUrl);

            final projectVal =
                'project=${item.project.isNotEmpty && item.project != '-' ? item.project.replaceAll(' ', '') : 'WoodWorkshop'}';

            final shipperVal =
                'shipper=${item.shipper.isNotEmpty && item.shipper != '-' ? item.shipper : (item.jobId.isNotEmpty ? item.jobId : 'PRO-007')}';

            final loadVal =
                'load_id=${item.loadId.isNotEmpty && item.loadId != '-' ? item.loadId : ''}';

            final bundleVal =
                'bundle_id=${item.id.isNotEmpty ? item.id : 'B-001'}';

            final partsVal =
                'parts=${item.part.isNotEmpty && item.part != '-' ? item.part : '-'}';

            final weightVal =
                'weight=${item.rawWeight.isNotEmpty ? item.rawWeight : (item.totalWeightLbs > 0 ? (item.totalWeightLbs % 1 == 0 ? item.totalWeightLbs.toInt().toString() : item.totalWeightLbs.toString()) : '0')}';

            final lengthVal =
                'Length=${item.rawLength.isNotEmpty ? item.rawLength : (item.lengthFt > 0 ? (item.lengthFt % 1 == 0 ? item.lengthFt.toInt().toString() : item.lengthFt.toString()) : '0')}';

            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'QR Code Label',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qrData,
                    width: 140,
                    height: 140,
                  ),
                  pw.SizedBox(height: 24),
                  pw.Container(
                    width: 280,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildRow('Project:', projectVal),
                        _buildRow('Shipper:', shipperVal),
                        _buildRow('Load ID:', loadVal),
                        _buildRow('Bundle ID:', bundleVal),
                        _buildRow('Parts:', partsVal),
                        _buildRow('Weight:', weightVal),
                        _buildRow('Length:', lengthVal),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 9.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Triggers the native platform print preview & dialog.
  /// Works across iOS, Android, macOS, Windows, and Web.
  static Future<bool> printLabels(
    List<LabelBundleItem> items, {
    String jobName = 'QR_Code_Label',
  }) async {
    if (items.isEmpty) return false;
    try {
      final name = items.length == 1
          ? 'Label_${items.first.id}'
          : 'Labels_${items.length}_Bundles';

      return await Printing.layoutPdf(
        name: name,
        onLayout: (PdfPageFormat format) async => generateLabelsPdf(items),
      );
    } catch (e, st) {
      AppLogger.e('Error printing labels: $e', error: e, stackTrace: st, tag: 'LABEL_PDF');
      return false;
    }
  }

  /// Triggers print for a single bundle label.
  static Future<bool> printSingleLabel(LabelBundleItem item) async {
    return printLabels([item], jobName: 'Label_${item.id}');
  }
}
