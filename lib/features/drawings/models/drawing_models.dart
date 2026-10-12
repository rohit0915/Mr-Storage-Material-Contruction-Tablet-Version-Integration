enum DrawingPreviewType { singleImage, imageGrid }

enum DrawingFileType { pdf, dwg, docx, image, video }

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
    this.versionLabel = 'Version 1',
    this.versionNumber = 1,
    this.rejectionReason = '',
    this.buildingNumber = 1,
    this.buildingName = '',
    this.fileUrl = '',
    this.isBuildingDrawing = false,
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
  final String versionLabel;
  final int versionNumber;
  final String rejectionReason;
  final int buildingNumber;
  final String buildingName;
  final String fileUrl;
  final bool isBuildingDrawing;

  factory DrawingFileItem.fromJson(
    Map<String, dynamic> json, {
    bool isBuildingDrawing = false,
    int buildingNumber = 1,
    String buildingName = '',
  }) {
    final fName = (json['name'] ?? json['fileName'] ?? json['title'] ?? '').toString();
    final fSize = (json['sizeLabel'] ?? json['fileSize'] ?? json['size'] ?? '').toString();
    final fStatus = (json['status'] ?? json['approvalStatus'] ?? json['latestDrawingStatus'] ?? 'Approved').toString();
    final pCode = (json['projectCode'] ?? json['jobId'] ?? '').toString();
    final loc = (json['location'] ?? '').toString();
    final uBy = (json['uploadedBy'] ?? json['uploadedByName'] ?? 'Site Construction').toString();
    final rOn = (json['receivedOn'] ?? json['createdAt'] ?? json['uploadedAt'] ?? '').toString();
    final url = (json['fileUrl'] ?? json['url'] ?? json['signedUrl'] ?? '').toString();
    final mType = (json['type'] ?? json['mimeType'] ?? '').toString().toLowerCase();
    final cat = (json['category'] ?? json['documentType'] ?? '').toString().toLowerCase();
    final vNum = json['versionNumber'] ?? json['version'] ?? 1;
    final rReason = (json['rejectionReason'] ?? json['reason'] ?? '').toString();
    final bNum = json['buildingNumber'] ?? buildingNumber;
    final bName = (json['buildingName'] ?? json['building'] ?? buildingName).toString();

    final isDrawingDoc = isBuildingDrawing ||
        cat.contains('drawing') ||
        mType == 'drawing' ||
        json.containsKey('versionNumber') ||
        json.containsKey('rejectionReason');

    DrawingFileType type = DrawingFileType.pdf;
    final lower = fName.toLowerCase();
    final lowerUrl = url.toLowerCase();

    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm') ||
        lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.avi') ||
        lowerUrl.endsWith('.mkv') ||
        lowerUrl.endsWith('.webm') ||
        mType.contains('video') ||
        cat.contains('video')) {
      type = DrawingFileType.video;
    } else if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.svg') ||
        lower.endsWith('.gif') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.webp') ||
        lowerUrl.endsWith('.svg') ||
        lowerUrl.endsWith('.gif') ||
        mType.contains('image') ||
        mType.contains('photo') ||
        cat.contains('photo')) {
      type = DrawingFileType.image;
    } else if (lower.endsWith('.dwg') || lower.endsWith('.dxf')) {
      type = DrawingFileType.dwg;
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      type = DrawingFileType.docx;
    }

    final parsedVersionNumber = vNum is int ? vNum : int.tryParse('$vNum') ?? 1;

    return DrawingFileItem(
      name: fName.isNotEmpty ? fName : (type == DrawingFileType.video ? 'Site Video' : (isDrawingDoc ? 'Drawing' : 'Site Photo')),
      sizeLabel: fSize,
      fileType: type,
      status: _formatStatus(fStatus),
      previewType: type == DrawingFileType.image
          ? DrawingPreviewType.imageGrid
          : DrawingPreviewType.singleImage,
      title: fName.isNotEmpty ? fName : (type == DrawingFileType.video ? 'Site Video' : (isDrawingDoc ? 'Drawing' : 'Site Photo')),
      projectCode: pCode,
      location: loc,
      uploadedBy: uBy,
      receivedOn: rOn.contains('T') ? rOn.split('T')[0] : rOn,
      previewAssets: url.isNotEmpty ? [url] : const [],
      versionLabel: 'Version $parsedVersionNumber',
      versionNumber: parsedVersionNumber,
      rejectionReason: rReason,
      buildingNumber: bNum is int ? bNum : int.tryParse('$bNum') ?? 1,
      buildingName: bName,
      fileUrl: url,
      isBuildingDrawing: isDrawingDoc,
    );
  }

  static String _formatStatus(String status) {
    if (status.isEmpty) return 'Approved';
    final s = status.replaceAll('_', ' ').toLowerCase().trim();
    if (s.contains('reject')) return 'Rejected';
    if (s.contains('approve')) return 'Approved';
    if (s.contains('pending')) return 'Pending Review';
    if (s.contains('revision')) return 'Revision Required';
    return status[0].toUpperCase() + status.substring(1);
  }
}

extension DrawingFileItemExt on DrawingFileItem {
  bool get isPhoto => fileType == DrawingFileType.image && !isBuildingDrawing;
  bool get isVideo => fileType == DrawingFileType.video;
  bool get isMedia => !isBuildingDrawing && (fileType == DrawingFileType.image || fileType == DrawingFileType.video);
  bool get isDrawing => isBuildingDrawing || (!isMedia && fileType != DrawingFileType.video);

  String get typeLabel {
    if (isBuildingDrawing) return 'Drawing';
    if (fileType == DrawingFileType.image) return 'Photo';
    if (fileType == DrawingFileType.video) return 'Video';
    if (fileType == DrawingFileType.dwg) return 'DWG';
    if (fileType == DrawingFileType.docx) return 'DOCX';
    return 'PDF';
  }
}

class BuildingDrawingGroup {
  const BuildingDrawingGroup({
    required this.buildingId,
    required this.buildingNumber,
    required this.buildingName,
    required this.status,
    required this.drawings,
  });

  final String buildingId;
  final int buildingNumber;
  final String buildingName;
  final String status;
  final List<DrawingFileItem> drawings;

  int get sheetCount => drawings.length;

  factory BuildingDrawingGroup.fromJson(Map<String, dynamic> json) {
    final bNum = json['buildingNumber'] ?? 1;
    final parsedBNum = bNum is int ? bNum : int.tryParse('$bNum') ?? 1;
    final bId = (json['buildingId'] ?? 'bldg-$parsedBNum').toString();
    final bName = (json['buildingName'] ?? json['name'] ?? 'Building $parsedBNum').toString();
    final status = DrawingFileItem._formatStatus((json['latestDrawingStatus'] ?? json['status'] ?? 'Pending').toString());

    final drawingsList = <DrawingFileItem>[];
    final rawDrawings = json['drawings'] ?? json['files'] ?? json['versions'] ?? json['documents'];
    if (rawDrawings is List) {
      for (final d in rawDrawings) {
        if (d is Map) {
          drawingsList.add(
            DrawingFileItem.fromJson(
              Map<String, dynamic>.from(d),
              isBuildingDrawing: true,
              buildingNumber: parsedBNum,
              buildingName: bName,
            ),
          );
        }
      }
    }

    return BuildingDrawingGroup(
      buildingId: bId,
      buildingNumber: parsedBNum,
      buildingName: bName,
      status: status,
      drawings: drawingsList,
    );
  }
}

class DrawingProjectItem {
  const DrawingProjectItem({
    this.id = '',
    required this.name,
    required this.code,
    required this.uploadedBy,
    required this.location,
    required this.lastUpdate,
    required this.files,
    this.buildings = const [],
    this.siteMedia = const [],
  });

  final String id;
  final String name;
  final String code;
  final String uploadedBy;
  final String location;
  final String lastUpdate;
  final List<DrawingFileItem> files;
  final List<BuildingDrawingGroup> buildings;
  final List<DrawingFileItem> siteMedia;

  List<BuildingDrawingGroup> get effectiveBuildings {
    if (buildings.isNotEmpty) return buildings;
    final drawingFiles = files.where((f) => f.isDrawing).toList();
    if (drawingFiles.isEmpty) return const [];
    final map = <int, List<DrawingFileItem>>{};
    for (final df in drawingFiles) {
      map.putIfAbsent(df.buildingNumber, () => []).add(df);
    }
    final sortedKeys = map.keys.toList()..sort();
    return sortedKeys.map((k) {
      final groupFiles = map[k]!;
      final groupStatus = groupFiles.any((f) => f.status.toLowerCase() == 'rejected')
          ? 'Rejected'
          : (groupFiles.any((f) => f.status.toLowerCase().contains('pending'))
              ? 'Pending Review'
              : 'Approved');
      return BuildingDrawingGroup(
        buildingId: 'bldg-$k',
        buildingNumber: k,
        buildingName: 'Building $k',
        status: groupStatus,
        drawings: groupFiles,
      );
    }).toList();
  }

  List<DrawingFileItem> get effectiveSiteMedia {
    if (siteMedia.isNotEmpty) return siteMedia;
    return files.where((f) => f.isMedia).toList();
  }

  int get photoCount {
    final count = effectiveSiteMedia.where((f) => f.fileType == DrawingFileType.image).length;
    return count;
  }

  int get videoCount {
    final count = effectiveSiteMedia.where((f) => f.fileType == DrawingFileType.video).length;
    return count;
  }

  int get drawingCount {
    return effectiveBuildings.fold(0, (sum, b) => sum + b.drawings.length);
  }

  static List<DrawingProjectItem> defaultProjects() {
    return [
      DrawingProjectItem(
        id: 'PRO-002',
        name: 'Lucas project',
        code: 'PRO-002',
        uploadedBy: 'Site Construction',
        location: 'Georgia',
        lastUpdate: '2026-10-05',
        files: [
          const DrawingFileItem(
            name: 'Screenshot_2026-01-10-22-41-47-190_com.pinterest.png',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Photo',
            previewType: DrawingPreviewType.imageGrid,
            title: 'Screenshot_2026-01-10-22-41-47-190_com.pinterest.png',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-10-05',
            previewAssets: [],
          ),
          const DrawingFileItem(
            name: 'slide-1.png',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Photo',
            previewType: DrawingPreviewType.imageGrid,
            title: 'slide-1.png',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-09-30',
            previewAssets: [],
          ),
          const DrawingFileItem(
            name: 'qa-test-media.jpg',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Photo',
            previewType: DrawingPreviewType.imageGrid,
            title: 'qa-test-media.jpg',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-09-30',
            previewAssets: [],
          ),
          const DrawingFileItem(
            name: 'slide-1.png',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Photo',
            previewType: DrawingPreviewType.imageGrid,
            title: 'slide-1.png',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-09-30',
            previewAssets: [],
          ),
          const DrawingFileItem(
            name: 'qa-cleanup-remove.pdf',
            sizeLabel: 'PDF',
            fileType: DrawingFileType.pdf,
            status: 'Approved',
            previewType: DrawingPreviewType.singleImage,
            title: 'qa-cleanup-remove.pdf',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-10-05',
            previewAssets: [],
            isBuildingDrawing: true,
            versionLabel: 'Version 1',
            versionNumber: 1,
            buildingNumber: 1,
            buildingName: 'Building 1',
          ),
          const DrawingFileItem(
            name: 'quotation.png',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Rejected',
            previewType: DrawingPreviewType.imageGrid,
            title: 'quotation.png',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-10-05',
            previewAssets: [],
            isBuildingDrawing: true,
            versionLabel: 'Version 1',
            versionNumber: 1,
            buildingNumber: 1,
            buildingName: 'Building 1',
          ),
          const DrawingFileItem(
            name: 'steel-building-depot-log...',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Rejected',
            previewType: DrawingPreviewType.imageGrid,
            title: 'steel-building-depot-log...',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-10-05',
            previewAssets: [],
            isBuildingDrawing: true,
            versionLabel: 'Version 2',
            versionNumber: 2,
            buildingNumber: 1,
            buildingName: 'Building 1',
          ),
          const DrawingFileItem(
            name: 'quotation.png',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Approved',
            previewType: DrawingPreviewType.imageGrid,
            title: 'quotation.png',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-10-05',
            previewAssets: [],
            isBuildingDrawing: true,
            versionLabel: 'Version 1',
            versionNumber: 1,
            buildingNumber: 1,
            buildingName: 'Building 1',
          ),
        ],
        siteMedia: [
          const DrawingFileItem(
            name: 'Screenshot_2026-01-10-22-41-47-190_com.pinterest.png',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Photo',
            previewType: DrawingPreviewType.imageGrid,
            title: 'Screenshot_2026-01-10-22-41-47-190_com.pinterest.png',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-10-05',
            previewAssets: [],
          ),
          const DrawingFileItem(
            name: 'slide-1.png',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Photo',
            previewType: DrawingPreviewType.imageGrid,
            title: 'slide-1.png',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-09-30',
            previewAssets: [],
          ),
          const DrawingFileItem(
            name: 'qa-test-media.jpg',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Photo',
            previewType: DrawingPreviewType.imageGrid,
            title: 'qa-test-media.jpg',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-09-30',
            previewAssets: [],
          ),
          const DrawingFileItem(
            name: 'slide-1.png',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Photo',
            previewType: DrawingPreviewType.imageGrid,
            title: 'slide-1.png',
            projectCode: 'PRO-002',
            location: 'Georgia',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-09-30',
            previewAssets: [],
          ),
        ],
        buildings: [
          const BuildingDrawingGroup(
            buildingId: 'bldg-1',
            buildingNumber: 1,
            buildingName: 'Building 1',
            status: 'Rejected',
            drawings: [
              DrawingFileItem(
                name: 'qa-cleanup-remove.pdf',
                sizeLabel: 'PDF',
                fileType: DrawingFileType.pdf,
                status: 'Approved',
                previewType: DrawingPreviewType.singleImage,
                title: 'qa-cleanup-remove.pdf',
                projectCode: 'PRO-002',
                location: 'Georgia',
                uploadedBy: 'Site Construction',
                receivedOn: '2026-10-05',
                previewAssets: [],
                isBuildingDrawing: true,
                versionLabel: 'Version 1',
                versionNumber: 1,
                buildingNumber: 1,
                buildingName: 'Building 1',
              ),
              DrawingFileItem(
                name: 'quotation.png',
                sizeLabel: 'Photo',
                fileType: DrawingFileType.image,
                status: 'Rejected',
                previewType: DrawingPreviewType.imageGrid,
                title: 'quotation.png',
                projectCode: 'PRO-002',
                location: 'Georgia',
                uploadedBy: 'Site Construction',
                receivedOn: '2026-10-05',
                previewAssets: [],
                isBuildingDrawing: true,
                versionLabel: 'Version 1',
                versionNumber: 1,
                buildingNumber: 1,
                buildingName: 'Building 1',
              ),
              DrawingFileItem(
                name: 'steel-building-depot-log...',
                sizeLabel: 'Photo',
                fileType: DrawingFileType.image,
                status: 'Rejected',
                previewType: DrawingPreviewType.imageGrid,
                title: 'steel-building-depot-log...',
                projectCode: 'PRO-002',
                location: 'Georgia',
                uploadedBy: 'Site Construction',
                receivedOn: '2026-10-05',
                previewAssets: [],
                isBuildingDrawing: true,
                versionLabel: 'Version 2',
                versionNumber: 2,
                buildingNumber: 1,
                buildingName: 'Building 1',
              ),
              DrawingFileItem(
                name: 'quotation.png',
                sizeLabel: 'Photo',
                fileType: DrawingFileType.image,
                status: 'Approved',
                previewType: DrawingPreviewType.imageGrid,
                title: 'quotation.png',
                projectCode: 'PRO-002',
                location: 'Georgia',
                uploadedBy: 'Site Construction',
                receivedOn: '2026-10-05',
                previewAssets: [],
                isBuildingDrawing: true,
                versionLabel: 'Version 1',
                versionNumber: 1,
                buildingNumber: 1,
                buildingName: 'Building 1',
              ),
            ],
          ),
        ],
      ),
      DrawingProjectItem(
        id: '2026014',
        name: 'Storage 0011',
        code: '2026014',
        uploadedBy: 'Site Construction',
        location: 'Surat',
        lastUpdate: '2026-10-02',
        files: [
          const DrawingFileItem(
            name: 'Screenshot_2026-09-16-11-25-22-247_com.google.android.apps.messaging.png',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Photo',
            previewType: DrawingPreviewType.imageGrid,
            title: 'Screenshot_2026-09-16-11-25-22-247_com.google.android.apps.messaging.png',
            projectCode: '2026014',
            location: 'Surat',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-10-02',
            previewAssets: [],
          ),
          const DrawingFileItem(
            name: 'Screenshot at Nov 16 14...',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Pending Review',
            previewType: DrawingPreviewType.imageGrid,
            title: 'Screenshot at Nov 16 14...',
            projectCode: '2026014',
            location: 'Surat',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-10-02',
            previewAssets: [],
            isBuildingDrawing: true,
            versionLabel: 'Version 1',
            versionNumber: 1,
            buildingNumber: 1,
            buildingName: 'Building 1',
          ),
          const DrawingFileItem(
            name: '9081_Twin_Creek_Car_C...',
            sizeLabel: 'PDF',
            fileType: DrawingFileType.pdf,
            status: 'Pending Review',
            previewType: DrawingPreviewType.singleImage,
            title: '9081_Twin_Creek_Car_C...',
            projectCode: '2026014',
            location: 'Surat',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-10-02',
            previewAssets: [],
            isBuildingDrawing: true,
            versionLabel: 'Version 1',
            versionNumber: 1,
            buildingNumber: 1,
            buildingName: 'Building 1',
          ),
        ],
        siteMedia: [
          const DrawingFileItem(
            name: 'Screenshot_2026-09-16-11-25-22-247_com.google.android.apps.messaging.png',
            sizeLabel: 'Photo',
            fileType: DrawingFileType.image,
            status: 'Photo',
            previewType: DrawingPreviewType.imageGrid,
            title: 'Screenshot_2026-09-16-11-25-22-247_com.google.android.apps.messaging.png',
            projectCode: '2026014',
            location: 'Surat',
            uploadedBy: 'Site Construction',
            receivedOn: '2026-10-02',
            previewAssets: [],
          ),
        ],
        buildings: [
          const BuildingDrawingGroup(
            buildingId: 'bldg-1',
            buildingNumber: 1,
            buildingName: 'Building 1',
            status: 'Pending Review',
            drawings: [
              DrawingFileItem(
                name: 'Screenshot at Nov 16 14...',
                sizeLabel: 'Photo',
                fileType: DrawingFileType.image,
                status: 'Pending Review',
                previewType: DrawingPreviewType.imageGrid,
                title: 'Screenshot at Nov 16 14...',
                projectCode: '2026014',
                location: 'Surat',
                uploadedBy: 'Site Construction',
                receivedOn: '2026-10-02',
                previewAssets: [],
                isBuildingDrawing: true,
                versionLabel: 'Version 1',
                versionNumber: 1,
                buildingNumber: 1,
                buildingName: 'Building 1',
              ),
              DrawingFileItem(
                name: '9081_Twin_Creek_Car_C...',
                sizeLabel: 'PDF',
                fileType: DrawingFileType.pdf,
                status: 'Pending Review',
                previewType: DrawingPreviewType.singleImage,
                title: '9081_Twin_Creek_Car_C...',
                projectCode: '2026014',
                location: 'Surat',
                uploadedBy: 'Site Construction',
                receivedOn: '2026-10-02',
                previewAssets: [],
                isBuildingDrawing: true,
                versionLabel: 'Version 1',
                versionNumber: 1,
                buildingNumber: 1,
                buildingName: 'Building 1',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  factory DrawingProjectItem.fromJson(Map<String, dynamic> json) {
    final pName = (json['projectName'] ?? json['name'] ?? '').toString();
    final pCode = (json['jobId'] ?? json['code'] ?? '').toString();
    final pLocation = (json['location'] ?? '').toString();
    final uBy = (json['uploadedBy'] ?? '').toString();
    final dateStr = (json['updatedAt'] ?? json['createdAt'] ?? '').toString();

    final allFiles = <DrawingFileItem>[];
    final buildingsList = <BuildingDrawingGroup>[];
    final mediaList = <DrawingFileItem>[];

    // 1. Parse buildings if present
    final rawBuildings = json['buildings'];
    if (rawBuildings is List) {
      for (final b in rawBuildings) {
        if (b is Map) {
          final group = BuildingDrawingGroup.fromJson(Map<String, dynamic>.from(b));
          buildingsList.add(group);
          allFiles.addAll(group.drawings);
        }
      }
    }

    // 2. Parse raw files or documents
    final rawFiles = json['files'] ?? json['documents'] ?? json['attachments'] ?? json['media'];
    if (rawFiles is List) {
      for (final f in rawFiles) {
        if (f is Map) {
          final fileItem = DrawingFileItem.fromJson(Map<String, dynamic>.from(f));
          allFiles.add(fileItem);
          if (fileItem.isMedia) {
            mediaList.add(fileItem);
          }
        }
      }
    }

    // 3. Fallback grouping if buildings array was empty but files had drawings
    if (buildingsList.isEmpty) {
      final drawingFiles = allFiles.where((f) => f.isDrawing).toList();
      if (drawingFiles.isNotEmpty) {
        // Group by buildingNumber
        final map = <int, List<DrawingFileItem>>{};
        for (final df in drawingFiles) {
          map.putIfAbsent(df.buildingNumber, () => []).add(df);
        }
        final sortedKeys = map.keys.toList()..sort();
        for (final k in sortedKeys) {
          final groupFiles = map[k]!;
          final groupStatus = groupFiles.any((f) => f.status.toLowerCase() == 'rejected')
              ? 'Rejected'
              : (groupFiles.any((f) => f.status.toLowerCase().contains('pending')) ? 'Pending Review' : 'Approved');

          buildingsList.add(
            BuildingDrawingGroup(
              buildingId: 'bldg-$k',
              buildingNumber: k,
              buildingName: 'Building $k',
              status: groupStatus,
              drawings: groupFiles,
            ),
          );
        }
      }
    }

    // Filter media files if mediaList wasn't populated explicitly
    final finalMedia = mediaList.isNotEmpty
        ? mediaList
        : allFiles.where((f) => f.isMedia).toList();

    return DrawingProjectItem(
      id: (json['_id'] ?? json['leadId'] ?? json['projectId'] ?? json['id'] ?? '').toString(),
      name: pName,
      code: pCode,
      uploadedBy: uBy,
      location: pLocation,
      lastUpdate: dateStr.contains('T') ? dateStr.split('T')[0] : dateStr,
      files: allFiles,
      buildings: buildingsList,
      siteMedia: finalMedia,
    );
  }
}

