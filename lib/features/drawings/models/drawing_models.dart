import '../../../app/constants/app_assets.dart';

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
    final fName = json['name'] ?? json['fileName'] ?? json['title'] ?? 'Document.pdf';
    final fSize = json['sizeLabel'] ?? json['fileSize'] ?? '5.0 MB';
    final fStatus = json['status'] ?? 'Approved';
    final pCode = json['projectCode'] ?? json['jobId'] ?? 'PRJ-001';
    final loc = json['location'] ?? 'Site Location';
    final uBy = json['uploadedBy'] ?? 'Construction User';
    final rOn = json['receivedOn'] ?? json['createdAt'] ?? '2026-08-31';
    final url = json['fileUrl'] ?? json['url'] ?? '';

    DrawingFileType type = DrawingFileType.pdf;
    final lower = fName.toString().toLowerCase();
    if (lower.endsWith('.dwg')) {
      type = DrawingFileType.dwg;
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      type = DrawingFileType.docx;
    } else if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      type = DrawingFileType.image;
    }

    return DrawingFileItem(
      name: fName.toString(),
      sizeLabel: fSize.toString(),
      fileType: type,
      status: fStatus.toString(),
      previewType: type == DrawingFileType.image ? DrawingPreviewType.imageGrid : DrawingPreviewType.singleImage,
      title: fName.toString(),
      projectCode: pCode.toString(),
      location: loc.toString(),
      uploadedBy: uBy.toString(),
      receivedOn: rOn.toString().split('T')[0],
      previewAssets: [url.isNotEmpty ? url : AppAssets.drawingArchitectural],
    );
  }
}

enum DrawingFileType { pdf, dwg, docx, image }

class DrawingProjectItem {
  const DrawingProjectItem({
    required this.name,
    required this.code,
    required this.uploadedBy,
    required this.location,
    required this.lastUpdate,
    required this.files,
  });

  final String name;
  final String code;
  final String uploadedBy;
  final String location;
  final String lastUpdate;
  final List<DrawingFileItem> files;

  factory DrawingProjectItem.fromJson(Map<String, dynamic> json) {
    final pName = json['projectName'] ?? json['name'] ?? 'Project';
    final pCode = json['jobId'] ?? json['code'] ?? 'PRJ-001';
    final pLocation = json['location'] ?? 'Site Location';
    final uBy = json['uploadedBy'] ?? 'Construction User';
    final dateStr = json['updatedAt'] ?? json['createdAt'] ?? '2026-08-31';

    final filesList = <DrawingFileItem>[];
    if (json['files'] is List) {
      for (final f in (json['files'] as List)) {
        if (f is Map) {
          filesList.add(DrawingFileItem.fromJson(Map<String, dynamic>.from(f)));
        }
      }
    }

    if (filesList.isEmpty) {
      filesList.add(
        DrawingFileItem(
          name: 'Architectural Plans.pdf',
          sizeLabel: '15.2 MB',
          fileType: DrawingFileType.pdf,
          status: 'Approved',
          previewType: DrawingPreviewType.singleImage,
          title: 'Architectural Plans',
          projectCode: pCode.toString(),
          location: pLocation.toString(),
          uploadedBy: uBy.toString(),
          receivedOn: dateStr.toString().split('T')[0],
          previewAssets: const [AppAssets.drawingArchitectural],
        ),
      );
    }

    return DrawingProjectItem(
      name: pName.toString(),
      code: pCode.toString(),
      uploadedBy: uBy.toString(),
      location: pLocation.toString(),
      lastUpdate: dateStr.toString().split('T')[0],
      files: filesList,
    );
  }
}

class DrawingProjectsData {
  static final projects = <DrawingProjectItem>[
    DrawingProjectItem(
      name: 'ABC Logistics Warehouse',
      code: 'PEB-1021',
      uploadedBy: 'Rahul Sharma',
      location: 'Pune, Maharashtra',
      lastUpdate: '25-April-2025',
      files: [
        DrawingFileItem(
          name: 'Architectural Plans.pdf',
          sizeLabel: '15.2 MB',
          fileType: DrawingFileType.pdf,
          status: 'Approved',
          previewType: DrawingPreviewType.singleImage,
          title: 'Architectural Plans',
          projectCode: 'PEB-1021',
          location: 'Pune, Maharashtra',
          uploadedBy: 'Rahul Sharma',
          receivedOn: '25-April-2025',
          previewAssets: const [AppAssets.drawingArchitectural],
        ),
        DrawingFileItem(
          name: 'Structural Drawings.dwg',
          sizeLabel: '15.2 MB',
          fileType: DrawingFileType.dwg,
          status: 'Approved',
          previewType: DrawingPreviewType.singleImage,
          title: 'Architectural Plans',
          projectCode: 'PEB-1021',
          location: 'Pune, Maharashtra',
          uploadedBy: 'Rahul Sharma',
          receivedOn: '25-April-2025',
          previewAssets: const [AppAssets.drawingFrame],
        ),
        DrawingFileItem(
          name: 'Specifications.docx',
          sizeLabel: '15.2 MB',
          fileType: DrawingFileType.docx,
          status: 'Approved',
          previewType: DrawingPreviewType.singleImage,
          title: 'Architectural Plans',
          projectCode: 'PEB-1021',
          location: 'Pune, Maharashtra',
          uploadedBy: 'Rahul Sharma',
          receivedOn: '25-April-2025',
          previewAssets: const [AppAssets.drawingArchitectural],
        ),
        DrawingFileItem(
          name: 'Building Image',
          sizeLabel: '12.4 MB',
          fileType: DrawingFileType.image,
          status: 'Approved',
          previewType: DrawingPreviewType.imageGrid,
          title: 'Building Image',
          projectCode: 'PEB-1021',
          location: 'Pune, Maharashtra',
          uploadedBy: 'Rahul Sharma',
          receivedOn: '25-April-2025',
          previewAssets: const [
            AppAssets.buildingPhoto1,
            AppAssets.buildingPhoto2,
            AppAssets.buildingPhoto3,
            AppAssets.buildingPhoto4,
          ],
        ),
      ],
    ),
    DrawingProjectItem(
      name: 'Metro Cast Factory Shed',
      code: 'PEB-0998',
      uploadedBy: 'Rahul Sharma',
      location: 'Ahmedabad, Gujarat',
      lastUpdate: '25-April-2025',
      files: [
        DrawingFileItem(
          name: 'Architectural Plans.pdf',
          sizeLabel: '15.2 MB',
          fileType: DrawingFileType.pdf,
          status: 'Approved',
          previewType: DrawingPreviewType.singleImage,
          title: 'Architectural Plans',
          projectCode: 'PEB-0998',
          location: 'Ahmedabad, Gujarat',
          uploadedBy: 'Rahul Sharma',
          receivedOn: '25-April-2025',
          previewAssets: const [AppAssets.drawingArchitectural],
        ),
        DrawingFileItem(
          name: 'Structural Drawings.dwg',
          sizeLabel: '15.2 MB',
          fileType: DrawingFileType.dwg,
          status: 'Approved',
          previewType: DrawingPreviewType.singleImage,
          title: 'Architectural Plans',
          projectCode: 'PEB-0998',
          location: 'Ahmedabad, Gujarat',
          uploadedBy: 'Rahul Sharma',
          receivedOn: '25-April-2025',
          previewAssets: const [AppAssets.drawingFrame],
        ),
        DrawingFileItem(
          name: 'Specifications.docx',
          sizeLabel: '15.2 MB',
          fileType: DrawingFileType.docx,
          status: 'Approved',
          previewType: DrawingPreviewType.singleImage,
          title: 'Architectural Plans',
          projectCode: 'PEB-0998',
          location: 'Ahmedabad, Gujarat',
          uploadedBy: 'Rahul Sharma',
          receivedOn: '25-April-2025',
          previewAssets: const [AppAssets.drawingArchitectural],
        ),
      ],
    ),
    DrawingProjectItem(
      name: 'Pebson Agro Storage',
      code: 'PEB-0881',
      uploadedBy: 'Rahul Sharma',
      location: 'Nashik, Maharashtra',
      lastUpdate: '25-April-2025',
      files: [
        DrawingFileItem(
          name: 'Architectural Plans.pdf',
          sizeLabel: '15.2 MB',
          fileType: DrawingFileType.pdf,
          status: 'Approved',
          previewType: DrawingPreviewType.singleImage,
          title: 'Architectural Plans',
          projectCode: 'PEB-0881',
          location: 'Nashik, Maharashtra',
          uploadedBy: 'Rahul Sharma',
          receivedOn: '25-April-2025',
          previewAssets: const [AppAssets.drawingArchitectural],
        ),
        DrawingFileItem(
          name: 'Structural Drawings.dwg',
          sizeLabel: '15.2 MB',
          fileType: DrawingFileType.dwg,
          status: 'Approved',
          previewType: DrawingPreviewType.singleImage,
          title: 'Architectural Plans',
          projectCode: 'PEB-0881',
          location: 'Nashik, Maharashtra',
          uploadedBy: 'Rahul Sharma',
          receivedOn: '25-April-2025',
          previewAssets: const [AppAssets.drawingFrame],
        ),
        DrawingFileItem(
          name: 'Specifications.docx',
          sizeLabel: '15.2 MB',
          fileType: DrawingFileType.docx,
          status: 'Approved',
          previewType: DrawingPreviewType.singleImage,
          title: 'Architectural Plans',
          projectCode: 'PEB-0881',
          location: 'Nashik, Maharashtra',
          uploadedBy: 'Rahul Sharma',
          receivedOn: '25-April-2025',
          previewAssets: const [AppAssets.drawingArchitectural],
        ),
      ],
    ),
  ];
}
