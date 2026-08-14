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
