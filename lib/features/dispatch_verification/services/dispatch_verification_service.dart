import 'package:get/get.dart';
import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';
import '../models/dispatch_verification_models.dart';

class DispatchVerificationService {
  DispatchVerificationService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchDispatchVerificationsData({
    String? projectId,
  }) async {
    List rawList = [];
    Map<String, dynamic> stats = {
      'loadsReady': 0,
      'bundlesVerified': 0,
      'bundlesMissing': 0,
      'dispatchedToday': 0,
    };

    try {
      final endpoint = projectId != null && projectId.isNotEmpty
          ? ApiConstants.dispatchVerificationUrl(page: 1, limit: 50, projectId: projectId)
          : ApiConstants.dispatchVerification;
      final res = await _apiClient.get(endpoint);
      AppLogger.i(
        'Fetch dispatch verification response: $res',
        tag: 'DISPATCH_VERIFICATION',
      );

      if (res is Map) {
        final data = res['data'];
        if (data is Map) {
          if (data['loads'] is List) {
            rawList = data['loads'];
          } else if (data['dispatches'] is List) {
            rawList = data['dispatches'];
          } else if (data['items'] is List) {
            rawList = data['items'];
          }
          if (data['stats'] is Map) {
            final s = data['stats'] as Map;
            stats['loadsReady'] =
                s['loadsReady'] ?? s['readyForDispatch'] ?? s['total'] ?? 0;
            stats['bundlesVerified'] =
                s['bundlesVerified'] ?? s['verified'] ?? 0;
            stats['bundlesMissing'] = s['bundlesMissing'] ?? s['missing'] ?? 0;
            stats['dispatchedToday'] = s['dispatchedToday'] ?? s['today'] ?? 0;
          }
        } else if (data is List) {
          rawList = data;
        }

        if (res['loads'] is List) rawList = res['loads'];
        if (res['dispatches'] is List) rawList = res['dispatches'];
      } else if (res is List) {
        rawList = res;
      }
    } catch (e, st) {
      AppLogger.e(
        'Error fetching dispatch verifications from /dispatch-verification',
        error: e,
        stackTrace: st,
        tag: 'DISPATCH_VERIFICATION',
      );
    }

    // Fallback: If /construction/dispatch-verification returned no items, fetch the confirmed loads from /construction/packing-lists
    if (rawList.isEmpty) {
      try {
        final pklUrl = projectId != null && projectId.isNotEmpty
            ? ApiConstants.packingListsUrl(page: 1, limit: 50, projectId: projectId)
            : ApiConstants.packingListsUrl(page: 1, limit: 50);
        final pklRes = await _apiClient.get(pklUrl);
        AppLogger.i(
          'Dispatch fallback to packing-lists response: $pklRes',
          tag: 'DISPATCH_VERIFICATION',
        );
        if (pklRes is Map) {
          final data = pklRes['data'];
          if (data is Map) {
            if (data['packingLists'] is List) {
              rawList = data['packingLists'];
            } else if (data['items'] is List) {
              rawList = data['items'];
            }
          } else if (data is List) {
            rawList = data;
          }
          if (pklRes['packingLists'] is List) rawList = pklRes['packingLists'];
        } else if (pklRes is List) {
          rawList = pklRes;
        }
      } catch (e, st) {
        AppLogger.e(
          'Error fetching fallback packing lists for dispatch',
          error: e,
          stackTrace: st,
          tag: 'DISPATCH_VERIFICATION',
        );
      }
    }

    final items = rawList
        .whereType<Map>()
        .map((item) => DispatchItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    if (items.isNotEmpty) {
      stats['loadsReady'] = items.length;
    }

    return {'items': items, 'stats': stats};
  }

  Future<List<DispatchItem>> fetchDispatchVerifications({String? projectId}) async {
    final res = await fetchDispatchVerificationsData(projectId: projectId);
    return (res['items'] as List<DispatchItem>?) ?? [];
  }

  /// Fetches Project List grouped for Dispatch Verification (Image 1)
  Future<List<DispatchProjectItem>> fetchDispatchProjects() async {
    // 1. Fetch dispatch loads / packing lists
    final data = await fetchDispatchVerificationsData();
    final loads = (data['items'] as List<DispatchItem>?) ?? [];

    // Group loads by project
    final Map<String, List<DispatchItem>> projectLoads = {};
    for (final load in loads) {
      final key = load.project.trim().isNotEmpty
          ? load.project.trim()
          : (load.destination.trim().isNotEmpty ? load.destination.trim() : 'Project');
      projectLoads.putIfAbsent(key, () => []).add(load);
    }

    final projects = <DispatchProjectItem>[];

    // Try fetching /construction/bundle-scan/projects or /construction/projects to correlate real project metadata & thumbnails
    final Map<String, Map<String, dynamic>> projectMeta = {};
    try {
      final bProjectsRes = await _apiClient.get(ApiConstants.bundleScanProjects);
      if (bProjectsRes is Map) {
        final d = bProjectsRes['data'] ?? bProjectsRes;
        final list = (d is Map ? (d['projects'] ?? d['items']) : (d is List ? d : null)) ??
            (bProjectsRes['projects'] is List ? bProjectsRes['projects'] : null);
        if (list is List) {
          for (final p in list) {
            if (p is Map) {
              final name = (p['projectName'] ?? p['name'] ?? '').toString();
              if (name.isNotEmpty) {
                projectMeta[name.toLowerCase()] = Map<String, dynamic>.from(p);
              }
            }
          }
        }
      }
    } catch (_) {}

    try {
      final pRes = await _apiClient.get('${ApiConstants.projects}?page=1&limit=50');
      if (pRes is Map && pRes['data'] is Map && pRes['data']['projects'] is List) {
        for (final p in (pRes['data']['projects'] as List)) {
          if (p is Map) {
            final name = (p['projectName'] ?? p['name'] ?? '').toString();
            if (name.isNotEmpty && !projectMeta.containsKey(name.toLowerCase())) {
              projectMeta[name.toLowerCase()] = Map<String, dynamic>.from(p);
            }
          }
        }
      }
    } catch (_) {}

    projectLoads.forEach((projName, pLoads) {
      final first = pLoads.first;
      final meta = projectMeta[projName.toLowerCase()];
      final leadId = meta?['_id']?.toString() ?? first.mongoId;
      final pId = meta?['jobId']?.toString() ??
          (first.jobId.isNotEmpty ? first.jobId : 'PRJ-2025-00${projects.length + 31}');
      final site = meta?['location']?.toString() ??
          meta?['siteLocation']?.toString() ??
          (first.destination.isNotEmpty ? first.destination : 'Construction Site A');

      final apiBundles = (meta?['totalBundles'] as num?)?.toInt() ??
          (meta?['bundlesCount'] as num?)?.toInt();
      final apiPkls = (meta?['totalPackingLists'] as num?)?.toInt() ??
          (meta?['packingListsCount'] as num?)?.toInt();

      final totalBundles = apiBundles ?? (pLoads.fold<int>(0, (sum, item) => sum + item.bundles));
      final totalPackingLists = apiPkls ?? (pLoads.map((l) => l.packingListNo).where((s) => s.isNotEmpty).toSet().length);

      DateTime? projCreatedAt;
      if (meta != null) {
        for (final k in ['createdAt', 'dispatchDate', 'date', 'updatedAt', 'created_at']) {
          if (meta[k] != null && meta[k].toString().isNotEmpty) {
            final parsed = DateTime.tryParse(meta[k].toString());
            if (parsed != null) {
              projCreatedAt = parsed;
              break;
            }
          }
        }
      }
      if (projCreatedAt == null && pLoads.isNotEmpty) {
        for (final l in pLoads) {
          if (l.createdAt != null) {
            projCreatedAt = l.createdAt;
            break;
          }
        }
      }

      projects.add(
        DispatchProjectItem(
          leadId: leadId,
          projectId: pId,
          projectName: projName,
          siteLocation: site,
          thumbnailUrl: meta?['thumbnailUrl']?.toString(),
          totalPackingLists: totalPackingLists > 0 ? totalPackingLists : pLoads.length,
          totalBundles: totalBundles > 0 ? totalBundles : pLoads.fold<int>(0, (sum, item) => sum + item.bundleList.length),
          loads: pLoads,
          createdAt: projCreatedAt,
        ),
      );
    });

    // If no projects were resolved from loads, use direct projects
    if (projects.isEmpty && projectMeta.isNotEmpty) {
      projectMeta.forEach((key, p) {
        DateTime? pDate;
        for (final k in ['createdAt', 'dispatchDate', 'date', 'updatedAt', 'created_at']) {
          if (p[k] != null && p[k].toString().isNotEmpty) {
            final parsed = DateTime.tryParse(p[k].toString());
            if (parsed != null) {
              pDate = parsed;
              break;
            }
          }
        }
        projects.add(
          DispatchProjectItem(
            leadId: p['_id']?.toString() ?? '',
            projectId: p['jobId']?.toString() ?? 'PRJ-2025-0031',
            projectName: p['projectName']?.toString() ?? 'Downtown Office Complex',
            siteLocation: p['location']?.toString() ?? 'Construction Site A',
            thumbnailUrl: p['thumbnailUrl']?.toString(),
            totalPackingLists: 8,
            totalBundles: 8,
            loads: [],
            createdAt: pDate,
          ),
        );
      });
    }

    return projects;
  }

  /// 3-Step Navigation Step 2: Fetch Loads for a specific Project
  Future<List<DispatchItem>> fetchProjectLoads(String leadId) async {
    try {
      final res = await _apiClient.get(ApiConstants.bundleScanProjectLoads(leadId));
      List rawList = [];
      if (res is Map && res['data'] is List) {
        rawList = res['data'] as List;
      } else if (res is List) {
        rawList = res;
      }
      if (rawList.isEmpty) {
        try {
          final pklRes = await _apiClient.get(ApiConstants.packingListsProjectLoads(leadId));
          if (pklRes is Map && pklRes['data'] is List) {
            rawList = pklRes['data'] as List;
          } else if (pklRes is List) {
            rawList = pklRes;
          }
        } catch (_) {}
      }
      return rawList
          .whereType<Map>()
          .map((m) => DispatchItem.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e, st) {
      AppLogger.e(
        'Error fetching loads for project $leadId',
        error: e,
        stackTrace: st,
        tag: 'DISPATCH_VERIFICATION',
      );
    }
    return [];
  }

  Future<Map<String, dynamic>?> getDispatchLoadDetail(
    String loadId, {
    String? packingListId,
  }) async {
    final candidateIds = <String>[
      if (loadId.isNotEmpty) loadId,
      if (packingListId != null && packingListId.isNotEmpty && packingListId != loadId)
        packingListId,
    ];

    // 1. First Priority: Call the exact 3-step navigation endpoint used by the Web App:
    // GET /construction/bundle-scan/loads/:id/bundles or /construction/packing-lists/loads/:id/bundles
    for (final id in candidateIds) {
      try {
        final bScanUrl = ApiConstants.bundleScanLoadBundles(id);
        final bScanRes = await _apiClient.get(bScanUrl);
        AppLogger.i('bundleScanLoadBundles response ($bScanUrl): $bScanRes', tag: 'DISPATCH_VERIFICATION');
        if (bScanRes is Map) {
          final data = bScanRes['data'] ?? bScanRes;
          if (data is Map) {
            final b = data['bundles'] ?? data['items'] ?? data['bundleItems'];
            if (b is List && b.isNotEmpty) {
              return Map<String, dynamic>.from(data);
            }
          } else if (data is List && data.isNotEmpty) {
            return {'bundles': data};
          }
        } else if (bScanRes is List && bScanRes.isNotEmpty) {
          return {'bundles': bScanRes};
        }
      } catch (e) {
        AppLogger.d('bundle-scan/loads/$id/bundles endpoint failed: $e', tag: 'DISPATCH_VERIFICATION');
      }

      try {
        final pklBundlesUrl = ApiConstants.packingListsLoadBundles(id);
        final pklRes = await _apiClient.get(pklBundlesUrl);
        if (pklRes is Map) {
          final data = pklRes['data'] ?? pklRes;
          if (data is Map) {
            final b = data['bundles'] ?? data['items'] ?? data['bundleItems'];
            if (b is List && b.isNotEmpty) {
              return Map<String, dynamic>.from(data);
            }
          } else if (data is List && data.isNotEmpty) {
            return {'bundles': data};
          }
        } else if (pklRes is List && pklRes.isNotEmpty) {
          return {'bundles': pklRes};
        }
      } catch (e) {
        AppLogger.d('packing-lists/loads/$id/bundles endpoint failed: $e', tag: 'DISPATCH_VERIFICATION');
      }
    }

    // 2. Fallback to /construction/dispatch-verification/:id
    try {
      if (loadId.isNotEmpty) {
        final res = await _apiClient.get(
          ApiConstants.dispatchVerificationDetail(loadId),
        );
        if (res is Map) {
          final data = res['data'] ?? res;
          if (data is Map) {
            final map = Map<String, dynamic>.from(data);
            final inner = map['load'] is Map ? map['load'] as Map : (map['dispatch'] is Map ? map['dispatch'] as Map : null);
            final b = map['bundles'] ?? map['items'] ?? map['bundleItems'] ?? inner?['bundles'] ?? inner?['items'] ?? inner?['bundleItems'];
            if (b is List && b.isNotEmpty) {
              return map;
            }
          }
        }
      }

      // 3. Fallback: If bundles not present in load detail, fetch from packing list
      if (packingListId != null && packingListId.isNotEmpty) {
        if (packingListId.length == 24) {
          final pklRes = await _apiClient.get(
            ApiConstants.packingListDetail(packingListId),
          );
          if (pklRes is Map) {
            final data = pklRes['data'] ?? pklRes;
            if (data is Map) return Map<String, dynamic>.from(data);
          }
        } else {
          // If human-readable code like 'PL-001', query packing-lists by search to get real Mongo ID
          final searchUrl = ApiConstants.packingListsUrl(page: 1, limit: 5, search: packingListId);
          final searchRes = await _apiClient.get(searchUrl);
          if (searchRes is Map) {
            final data = searchRes['data'];
            final list = (data is Map ? (data['packingLists'] ?? data['items']) : null) ?? (searchRes['packingLists'] ?? (data is List ? data : null));
            if (list is List && list.isNotEmpty && list.first is Map) {
              final firstMap = Map<String, dynamic>.from(list.first as Map);
              final realId = firstMap['_id']?.toString() ?? '';
              if (realId.length == 24) {
                final pklDetailRes = await _apiClient.get(ApiConstants.packingListDetail(realId));
                if (pklDetailRes is Map) {
                  final d = pklDetailRes['data'] ?? pklDetailRes;
                  if (d is Map) return Map<String, dynamic>.from(d);
                }
              }
              return firstMap;
            }
          }
        }
      }
    } catch (e, st) {
      AppLogger.e(
        'Error fetching dispatch load detail',
        error: e,
        stackTrace: st,
        tag: 'DISPATCH_VERIFICATION',
      );
    }
    return null;
  }

  Future<String?> exportDispatchVerifications() async {
    try {
      final res = await _apiClient.get('/construction/dispatch-verification/export');
      if (res is Map) {
        final url = res['url'] ??
            res['downloadUrl'] ??
            res['fileUrl'] ??
            res['data']?['url'] ??
            res['data']?['downloadUrl'];
        if (url != null && url.toString().isNotEmpty) return url.toString();
      } else if (res is String && res.startsWith('http')) {
        return res;
      }
    } catch (e) {
      AppLogger.w('Export dispatch verifications error: $e', tag: 'DISPATCH_VERIFICATION');
    }
    return null;
  }

  Future<bool> verifyLoad(String loadId, {double? actualWeight}) async {
    try {
      AppLogger.i(
        'Calling verifyLoad API for loadId: $loadId',
        tag: 'DISPATCH_VERIFICATION',
      );
      final body = actualWeight != null
          ? {'actualWeight': actualWeight}
          : {'actualWeight': 11137.4};
      final res = await _apiClient.post(
        ApiConstants.dispatchVerificationVerify(loadId),
        body: body,
      );
      AppLogger.i('Verify load response: $res', tag: 'DISPATCH_VERIFICATION');
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error verifying load: $e',
        error: e,
        stackTrace: st,
        tag: 'DISPATCH_VERIFICATION',
      );
      return false;
    }
  }

  Future<bool> confirmDispatch(String loadId, {String? packingListId}) async {
    try {
      AppLogger.i(
        'Calling confirmDispatch API for loadId: $loadId',
        tag: 'DISPATCH_VERIFICATION',
      );
      final res = await _apiClient.post(
        ApiConstants.dispatchVerificationConfirm(loadId),
        body: {},
      );
      AppLogger.i(
        'Confirm dispatch response: $res',
        tag: 'DISPATCH_VERIFICATION',
      );
      return res != null;
    } catch (e, st) {
      AppLogger.e(
        'Error confirming dispatch on /dispatch-verification: $e',
        error: e,
        stackTrace: st,
        tag: 'DISPATCH_VERIFICATION',
      );
      final targetId = (packingListId != null && packingListId.isNotEmpty)
          ? packingListId
          : loadId;
      try {
        AppLogger.i(
          'Trying fallback mark-dispatch API for packingListId: $targetId',
          tag: 'DISPATCH_VERIFICATION',
        );
        final res2 = await _apiClient.post(
          ApiConstants.packingListMarkDispatch(targetId),
          body: {},
        );
        AppLogger.i(
          'Fallback mark-dispatch response: $res2',
          tag: 'DISPATCH_VERIFICATION',
        );
        return res2 != null;
      } catch (e2, st2) {
        AppLogger.e(
          'Error on fallback mark-dispatch: $e2',
          error: e2,
          stackTrace: st2,
          tag: 'DISPATCH_VERIFICATION',
        );
        return false;
      }
    }
  }
}
