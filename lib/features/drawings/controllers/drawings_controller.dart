import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/construction_socket_service.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_logger.dart';
import '../models/drawing_models.dart';
import '../services/drawings_service.dart';
import '../widgets/drawing_preview_dialog.dart';
import '../widgets/upload_media_dialog.dart';

enum DrawingTabType { allFiles, drawings, photosVideos }
enum MediaFilterType { allMedia, photos, videos }

class DrawingsController extends GetxController {
  DrawingsController({DrawingsService? service})
    : _service = service ?? Get.put(DrawingsService());

  final DrawingsService _service;

  final isLoading = false.obs;
  final searchQuery = ''.obs;
  TextEditingController _localSearchController = TextEditingController();
  TextEditingController get localSearchController {
    try {
      final _ = _localSearchController.text;
    } catch (_) {
      _localSearchController =
          TextEditingController(text: searchQuery.value);
    }
    return _localSearchController;
  }
  final projectList = <DrawingProjectItem>[].obs;
  String scopedLeadId = '';
  String scopedProjectName = '';

  // Tab, Media & Status Filter Observables
  final selectedTab = DrawingTabType.allFiles.obs;
  final selectedMediaFilter = MediaFilterType.allMedia.obs;
  final selectedStatusFilter = 'all'.obs;

  void setTab(DrawingTabType tab) {
    selectedTab.value = tab;
    if (tab == DrawingTabType.drawings) {
      selectedMediaFilter.value = MediaFilterType.allMedia;
    }
  }

  void setMediaFilter(MediaFilterType filter) {
    selectedMediaFilter.value = filter;
    if (filter != MediaFilterType.allMedia &&
        selectedTab.value == DrawingTabType.drawings) {
      selectedTab.value = DrawingTabType.photosVideos;
    }
  }

  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
  }

  int get totalAllFilesCount {
    return projectList.fold(0, (sum, p) {
      final bldCount = p.effectiveBuildings.fold(
        0,
        (bSum, b) => bSum + b.drawings.length,
      );
      return sum + bldCount + p.effectiveSiteMedia.length;
    });
  }

  int get totalPhotosVideosCount {
    return projectList.fold(0, (sum, p) => sum + p.effectiveSiteMedia.length);
  }

  int get totalDrawingsCount {
    return projectList.fold(0, (sum, p) {
      return sum +
          p.effectiveBuildings.fold(0, (bSum, b) => bSum + b.drawings.length);
    });
  }

  static String _formatLocation(dynamic loc) {
    if (loc == null) return '-';
    if (loc is String) return loc.isEmpty ? '-' : loc;
    if (loc is Map) {
      final parts = [loc['address'], loc['city'], loc['state']]
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .map((e) => e.toString().trim())
          .toList();
      if (parts.isNotEmpty) return parts.join(', ');
      if (loc['name'] != null) return loc['name'].toString();
    }
    return loc.toString();
  }

  StreamSubscription<ConstructionSocketEvent>? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    scopedLeadId = args is Map ? (args['leadId'] ?? '').toString() : '';
    scopedProjectName = args is Map
        ? (args['projectName'] ?? args['title'] ?? '').toString()
        : '';

    // Join lead room if scoped to a project
    if (scopedLeadId.isNotEmpty &&
        Get.isRegistered<ConstructionSocketService>()) {
      Get.find<ConstructionSocketService>().joinLeadChat(scopedLeadId);
    }

    // Listen for drawing update events
    if (Get.isRegistered<ConstructionSocketService>()) {
      _socketSubscription = Get.find<ConstructionSocketService>().listenFor(
        ConstructionSocketService.drawingEvents,
        _handleDrawingEvent,
      );
    }

    fetchDrawings(leadId: scopedLeadId);
  }

  void _handleDrawingEvent(ConstructionSocketEvent event) {
    if (event.name == 'drawing_status_updated') {
      final eventLeadId = event.payload['leadId']?.toString() ?? '';
      if (scopedLeadId.isEmpty || scopedLeadId == eventLeadId) {
        AppLogger.i(
          'Drawing status updated event received for lead: $eventLeadId, auto-refetching...',
          tag: 'DRAWINGS',
        );
        fetchDrawings(leadId: scopedLeadId.isNotEmpty ? scopedLeadId : null);
      }
    }
  }

  Future<void> fetchDrawings({String? leadId}) async {
    isLoading.value = true;
    try {
      final effectiveLeadId =
          (leadId != null && leadId.isNotEmpty) ? leadId : scopedLeadId;

      if (effectiveLeadId.isNotEmpty) {
        // Fetch building-drawings, media, and project drawings concurrently
        final results = await Future.wait([
          _service.getBuildingDrawings(effectiveLeadId),
          _service.getMedia(effectiveLeadId),
          _service.getDrawings(leadId: effectiveLeadId),
        ]);

        final bldRes = results[0];
        final mediaRes = results[1];
        final drawRes = results[2];

        // 1. Parse buildings
        final List<BuildingDrawingGroup> buildings = [];
        dynamic bldData = bldRes;
        if (bldData is Map && bldData.containsKey('data')) {
          bldData = bldData['data'];
        }
        final rawBuildings = bldData is Map ? bldData['buildings'] : null;
        if (rawBuildings is List) {
          for (final b in rawBuildings) {
            if (b is Map) {
              buildings.add(
                BuildingDrawingGroup.fromJson(Map<String, dynamic>.from(b)),
              );
            }
          }
        }

        // 2. Parse site media
        final List<DrawingFileItem> mediaItems = [];
        dynamic mediaData = mediaRes;
        if (mediaData is Map && mediaData.containsKey('data')) {
          mediaData = mediaData['data'];
        }
        dynamic rawDocs;
        if (mediaData is Map) {
          if (mediaData['projects'] is List &&
              (mediaData['projects'] as List).isNotEmpty) {
            rawDocs = mediaData['projects'][0]['documents'];
          } else if (mediaData['project'] is Map) {
            rawDocs = mediaData['project']['documents'];
          } else if (mediaData['documents'] is List) {
            rawDocs = mediaData['documents'];
          }
        } else if (mediaData is List) {
          rawDocs = mediaData;
        }

        if (rawDocs is List) {
          for (final doc in rawDocs) {
            if (doc is Map) {
              mediaItems.add(
                DrawingFileItem.fromJson(
                  Map<String, dynamic>.from(doc),
                  isBuildingDrawing: false,
                ),
              );
            }
          }
        }

        // 3. Project metadata
        String pName = scopedProjectName;
        String pCode = '';
        String pLoc = '';
        if (drawRes is Map) {
          final dynData =
              drawRes.containsKey('data') ? drawRes['data'] : drawRes;
          if (dynData is Map) {
            if (pName.isEmpty) {
              pName = (dynData['projectName'] ?? dynData['name'] ?? '')
                  .toString();
            }
            pCode = (dynData['jobId'] ?? dynData['code'] ?? '').toString();
            pLoc = _formatLocation(dynData['location']);
          }
        }
        if (pName.isEmpty && mediaData is Map && mediaData['project'] is Map) {
          pName = (mediaData['project']['name'] ??
                  mediaData['project']['projectName'] ??
                  '')
              .toString();
        }
        if (pName.isEmpty) {
          pName = 'Lucas project';
        }

        // 4. Combine all files
        final allFiles = <DrawingFileItem>[...mediaItems];
        for (final b in buildings) {
          allFiles.addAll(b.drawings);
        }

        // Fallback grouping if buildings was empty from getBuildingDrawings
        if (buildings.isEmpty && drawRes is Map) {
          final dynData =
              drawRes.containsKey('data') ? drawRes['data'] : drawRes;
          final fallbackProj = DrawingProjectItem.fromJson(
            Map<String, dynamic>.from(dynData is Map ? dynData : drawRes),
          );
          if (fallbackProj.buildings.isNotEmpty) {
            buildings.addAll(fallbackProj.buildings);
          }
        }

        final projectItem = DrawingProjectItem(
          id: effectiveLeadId,
          name: pName,
          code: pCode,
          uploadedBy: 'Site Construction',
          location: pLoc.isNotEmpty && pLoc != '-' ? pLoc : 'Georgia',
          lastUpdate: DateTime.now().toIso8601String(),
          files: allFiles,
          buildings: buildings,
          siteMedia: mediaItems,
        );

        projectList.assignAll([projectItem]);
      } else {
        // Global drawings & media across ALL projects (matching web /drawing-attachment)
        final results = await Future.wait([
          _service.getGlobalMedia(),
          _service.getDrawings(),
        ]);
        final mediaRes = results[0];
        final drawingsRes = results[1];

        final Map<String, DrawingProjectItem> projectsMap = {};

        // 1. Process Media from GET /construction/media
        dynamic mediaData = mediaRes;
        if (mediaData is Map && mediaData.containsKey('data')) {
          mediaData = mediaData['data'];
        }
        List mediaProjects = [];
        if (mediaData is Map && mediaData['projects'] is List) {
          mediaProjects = mediaData['projects'] as List;
        } else if (mediaData is List) {
          mediaProjects = mediaData;
        }

        for (final mp in mediaProjects) {
          if (mp is Map) {
            final leadId = (mp['leadId'] ?? mp['projectId'] ?? mp['_id'] ?? '').toString();
            final pName = (mp['projectName'] ?? mp['name'] ?? 'Project').toString();
            final pCode = (mp['projectId'] ?? mp['jobId'] ?? mp['code'] ?? leadId).toString();
            final pLoc = _formatLocation(mp['location']);
            final pDate = (mp['lastUpdate'] ?? mp['updatedAt'] ?? mp['createdAt'] ?? '').toString();

            final mediaDocs = <DrawingFileItem>[];
            final rawDocs = mp['documents'] ?? mp['media'] ?? mp['files'];
            if (rawDocs is List) {
              for (final doc in rawDocs) {
                if (doc is Map) {
                  mediaDocs.add(
                    DrawingFileItem.fromJson(
                      Map<String, dynamic>.from(doc),
                      isBuildingDrawing: false,
                    ),
                  );
                }
              }
            }

            final key = leadId.isNotEmpty ? leadId : (pCode.isNotEmpty ? pCode : pName);
            projectsMap[key] = DrawingProjectItem(
              id: leadId,
              name: pName,
              code: pCode,
              uploadedBy: 'Site Construction',
              location: pLoc,
              lastUpdate: pDate.contains('T') ? pDate.split('T')[0] : pDate,
              files: List.from(mediaDocs),
              buildings: const [],
              siteMedia: mediaDocs,
            );
          }
        }

        // 2. Process Drawings from GET /construction/drawings
        dynamic drawData = drawingsRes;
        if (drawData is Map && drawData.containsKey('data')) {
          drawData = drawData['data'];
        }
        List drawProjects = [];
        if (drawData is Map && drawData['projects'] is List) {
          drawProjects = drawData['projects'] as List;
        } else if (drawData is List) {
          drawProjects = drawData;
        }

        for (final dp in drawProjects) {
          if (dp is Map) {
            final leadId = (dp['leadId'] ?? dp['projectId'] ?? dp['_id'] ?? '').toString();
            final pName = (dp['projectName'] ?? dp['name'] ?? 'Project').toString();
            final pCode = (dp['projectId'] ?? dp['jobId'] ?? dp['code'] ?? leadId).toString();
            final pLoc = _formatLocation(dp['location']);
            final pDate = (dp['lastUpdate'] ?? dp['updatedAt'] ?? dp['createdAt'] ?? '').toString();
            final uBy = DrawingFileItem.formatUploadedBy(
              dp['uploadedBy'],
              fallback: 'Engineering Team',
            );

            final parsedProj = DrawingProjectItem.fromJson(Map<String, dynamic>.from(dp));
            final bldgs = parsedProj.effectiveBuildings;
            final drawFiles = bldgs.expand((b) => b.drawings).toList();

            final key = leadId.isNotEmpty ? leadId : (pCode.isNotEmpty ? pCode : pName);
            if (projectsMap.containsKey(key)) {
              final existing = projectsMap[key]!;
              final mergedFiles = [...existing.siteMedia, ...drawFiles];
              projectsMap[key] = DrawingProjectItem(
                id: existing.id.isNotEmpty ? existing.id : leadId,
                name: existing.name.isNotEmpty && existing.name != 'Project' ? existing.name : pName,
                code: existing.code.isNotEmpty ? existing.code : pCode,
                uploadedBy: uBy.isNotEmpty && uBy != 'Site Construction' ? uBy : existing.uploadedBy,
                location: existing.location.isNotEmpty && existing.location != '-' ? existing.location : pLoc,
                lastUpdate: existing.lastUpdate.isNotEmpty && existing.lastUpdate != '-' ? existing.lastUpdate : (pDate.contains('T') ? pDate.split('T')[0] : pDate),
                files: mergedFiles,
                buildings: bldgs,
                siteMedia: existing.siteMedia,
              );
            } else {
              projectsMap[key] = DrawingProjectItem(
                id: leadId,
                name: pName,
                code: pCode,
                uploadedBy: uBy,
                location: pLoc,
                lastUpdate: pDate.contains('T') ? pDate.split('T')[0] : pDate,
                files: drawFiles,
                buildings: bldgs,
                siteMedia: const [],
              );
            }
          }
        }

        projectList.assignAll(projectsMap.values.toList());
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'fetchDrawings Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'DRAWINGS_CTRL',
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<DrawingProjectItem> get filteredProjects {
    final q = searchQuery.value.trim().toLowerCase();
    return projectList.where((p) {
      final displayFiles = getDisplayFiles(p);
      if (q.isEmpty) return true;
      final matchesProject = p.name.toLowerCase().contains(q) ||
          p.code.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q);
      return matchesProject || displayFiles.isNotEmpty;
    }).toList();
  }

  List<DrawingFileItem> getProjectFiles(DrawingProjectItem project) =>
      getDisplayFiles(project);

  List<DrawingFileItem> getDisplayFiles(DrawingProjectItem project) {
    List<DrawingFileItem> list = [];
    final tab = selectedTab.value;
    if (tab == DrawingTabType.photosVideos) {
      list = project.effectiveSiteMedia;
      final mediaFilter = selectedMediaFilter.value;
      if (mediaFilter == MediaFilterType.photos) {
        list = list.where((f) => f.isPhoto).toList();
      } else if (mediaFilter == MediaFilterType.videos) {
        list = list.where((f) => f.isVideo).toList();
      }
    } else if (tab == DrawingTabType.drawings) {
      list = project.effectiveBuildings.expand((b) => b.drawings).toList();
      final status = selectedStatusFilter.value;
      if (status != 'all') {
        list = list
            .where((f) => f.status.toLowerCase().contains(status.toLowerCase()))
            .toList();
      }
    } else {
      // allFiles
      final mediaFilter = selectedMediaFilter.value;
      if (mediaFilter == MediaFilterType.photos) {
        list = project.files.where((f) => f.isPhoto || f.isDrawing).toList();
      } else if (mediaFilter == MediaFilterType.videos) {
        list = project.files.where((f) => f.isVideo || f.isDrawing).toList();
      } else {
        list = project.files;
      }
      final status = selectedStatusFilter.value;
      if (status != 'all') {
        list = list
            .where((f) => f.status.toLowerCase().contains(status.toLowerCase()))
            .toList();
      }
    }

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return list;

    final matchesProject = project.name.toLowerCase().contains(q) ||
        project.code.toLowerCase().contains(q) ||
        project.location.toLowerCase().contains(q);

    if (matchesProject) return list;

    return list
        .where(
          (f) =>
              f.name.toLowerCase().contains(q) ||
              f.title.toLowerCase().contains(q) ||
              f.sizeLabel.toLowerCase().contains(q),
        )
        .toList();
  }

  List<DrawingFileItem> getFilteredMedia(DrawingProjectItem project) {
    final q = searchQuery.value.trim().toLowerCase();
    final source = project.effectiveSiteMedia;

    return source.where((f) {
      final matchesSearch = q.isEmpty ||
          f.name.toLowerCase().contains(q) ||
          f.title.toLowerCase().contains(q);
      if (!matchesSearch) return false;

      if (selectedMediaFilter.value == MediaFilterType.photos) {
        return f.isPhoto;
      }
      if (selectedMediaFilter.value == MediaFilterType.videos) {
        return f.isVideo;
      }
      return true;
    }).toList();
  }

  List<DrawingFileItem> getFilteredBuildingDrawings(BuildingDrawingGroup building) {
    final q = searchQuery.value.trim().toLowerCase();
    final statusFilter = selectedStatusFilter.value;

    return building.drawings.where((f) {
      final matchesSearch = q.isEmpty ||
          f.name.toLowerCase().contains(q) ||
          f.title.toLowerCase().contains(q);
      if (!matchesSearch) return false;

      if (statusFilter != 'all') {
        if (!f.status.toLowerCase().contains(statusFilter.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void onSearchChanged(String value) => searchQuery.value = value;

  Future<void> openFilePreview(
    BuildContext context,
    DrawingFileItem file,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => DrawingPreviewDialog(file: file),
    );
  }

  Future<void> downloadFile(BuildContext context, DrawingFileItem file) async {
    final rawUrl = file.fileUrl.isNotEmpty
        ? file.fileUrl
        : (file.previewAssets.isNotEmpty ? file.previewAssets.first : '');
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File URL not available for ${file.name}'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    String url = trimmed;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.startsWith('/')) {
        url = '${ApiConstants.serverOrigin}$url';
      } else {
        url = '${ApiConstants.serverOrigin}/$url';
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening download for ${file.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final uri = Uri.parse(Uri.encodeFull(url));
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not download or open: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> openUpload(BuildContext context, {String? projectId}) async {
    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UploadMediaDialog(initialProjectId: projectId),
    );
    if (submitted == true && context.mounted) {
      await fetchDrawings(leadId: scopedLeadId);
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const UploadSuccessDialog(),
        );
      }
    }
  }

  @override
  void onClose() {
    if (scopedLeadId.isNotEmpty &&
        Get.isRegistered<ConstructionSocketService>()) {
      Get.find<ConstructionSocketService>().leaveLeadChat(scopedLeadId);
    }
    _socketSubscription?.cancel();
    super.onClose();
  }
}

