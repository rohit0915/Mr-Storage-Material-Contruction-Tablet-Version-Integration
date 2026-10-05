import 'dart:convert';
import 'dart:typed_data';

/// Quotes CSV cells and prevents API-provided text from becoming spreadsheet formulas.
Uint8List encodeDashboardCsv(List<List<Object?>> rows) {
  String cell(Object? value) {
    var text = value?.toString() ?? '';
    if (value is String && RegExp(r'^\s*[=+\-@]').hasMatch(text)) {
      text = "'$text";
    }
    return '"${text.replaceAll('"', '""')}"';
  }

  final csv = rows.map((row) => row.map(cell).join(',')).join('\r\n');
  return Uint8List.fromList(utf8.encode('\uFEFF$csv\r\n'));
}
