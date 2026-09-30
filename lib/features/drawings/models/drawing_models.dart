enum DrawingPreviewType { singleImage, imageGrid }

class DrawingFileItem {
  const DrawingFileItem({
    required this.name,
    required this.sizeLabel,
    required this.fileType,
    required this.status,
    required this.previewType,
    required this.title,
    required this.projectCode,
    required this.location,
    required this.uploadedBy,
    required this.receivedOn,
    required this.previewAssets,
  });

  final String name;
  final String sizeLabel;
  final DrawingFileType fileType;
  final String status;
  final DrawingPreviewType previewType;
  final String title;
  final String projectCode;
  final String location;
  final String uploadedBy;
  final String receivedOn;
  final List<String> previewAssets;

  factory DrawingFileItem.fromJson(Map<String, dynamic> json) {
    final fName = json['name'] ?? json['fileName'] ?? json['title'] ?? '';
    final fSize = json['sizeLabel'] ?? json['fileSize'] ?? '';
    final fStatus = json['status'] ?? '';
    final pCode = json['projectCode'] ?? json['jobId'] ?? '';
    final loc = json['location'] ?? '';
    final uBy = json['uploadedBy'] ?? '';
    final rOn = json['receivedOn'] ?? json['createdAt'] ?? '';
    final url = json['fileUrl'] ?? json['url'] ?? '';

    DrawingFileType type = DrawingFileType.pdf;
    final lower = fName.toString().toLowerCase();
    if (lower.endsWith('.dwg')) {
      type = DrawingFileType.dwg;
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      type = DrawingFileType.docx;
    } else if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg')) {
      type = DrawingFileType.image;
    }

    return DrawingFileItem(
      name: fName.toString(),
      sizeLabel: fSize.toString(),
      fileType: type,
      status: fStatus.toString(),
      previewType: type == DrawingFileType.image
          ? DrawingPreviewType.imageGrid
          : DrawingPreviewType.singleImage,
      title: fName.toString(),
      projectCode: pCode.toString(),
      location: loc.toString(),
      uploadedBy: uBy.toString(),
      receivedOn: rOn.toString().split('T')[0],
      previewAssets: url.isNotEmpty ? [url.toString()] : const [],
    );
  }
}

enum DrawingFileType { pdf, dwg, docx, image }

class DrawingProjectItem {
  const DrawingProjectItem({
    this.id = '',
    required this.name,
    required this.code,
    required this.uploadedBy,
    required this.location,
    required this.lastUpdate,
    required this.files,
  });

  final String id;
  final String name;
  final String code;
  final String uploadedBy;
  final String location;
  final String lastUpdate;
  final List<DrawingFileItem> files;

  factory DrawingProjectItem.fromJson(Map<String, dynamic> json) {
    final pName = json['projectName'] ?? json['name'] ?? '';
    final pCode = json['jobId'] ?? json['code'] ?? '';
    final pLocation = json['location'] ?? '';
    final uBy = json['uploadedBy'] ?? '';
    final dateStr = json['updatedAt'] ?? json['createdAt'] ?? '';

    final filesList = <DrawingFileItem>[];
    final rawFiles = json['files'] ?? json['documents'] ?? json['attachments'];
    if (rawFiles is List) {
      for (final f in rawFiles) {
        if (f is Map) {
          filesList.add(DrawingFileItem.fromJson(Map<String, dynamic>.from(f)));
        }
      }
    }

    return DrawingProjectItem(
      id:
          (json['_id'] ??
                  json['leadId'] ??
                  json['projectId'] ??
                  json['id'] ??
                  '')
              .toString(),
      name: pName.toString(),
      code: pCode.toString(),
      uploadedBy: uBy.toString(),
      location: pLocation.toString(),
      lastUpdate: dateStr.toString().split('T')[0],
      files: filesList,
    );
  }
}
