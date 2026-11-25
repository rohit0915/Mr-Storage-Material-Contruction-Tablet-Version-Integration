import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../services/delivery_tracking_service.dart';

class DeliveryDetailsController extends GetxController {
  DeliveryDetailsController({DeliveryTrackingService? service})
    : _service = service ?? Get.put(DeliveryTrackingService());

  final DeliveryTrackingService _service;

  final isLoading = true.obs;
  final isActionLoading = false.obs;
  final delivery = <String, dynamic>{}.obs;
  String deliveryId = '';
  String leadId = '';
  String projectNameArg = '';
  String jobIdArg = '';
  String locationArg = '';
  bool fromProject = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      fromProject = args['fromProject'] == true;
      leadId = (args['leadId'] ?? args['projectId'] ?? '').toString();
      deliveryId = (args['id'] ?? args['deliveryId'] ?? args['deliveryNumber'] ?? '').toString();
      projectNameArg = (args['project'] ?? args['projectName'] ?? '').toString();
      jobIdArg = (args['jobId'] ?? '').toString();
      locationArg = (args['location'] ?? '').toString();

      _seedFromItem(args['item'] ?? args['delivery']);
      if (projectNameArg.isNotEmpty && delivery['project'] == null) {
        delivery['project'] = {
          'projectName': projectNameArg,
          'name': projectNameArg,
          'jobId': jobIdArg,
          'location': locationArg,
        };
      }
    } else if (args != null) {
      _seedFromItem(args);
    }

    if (deliveryId.isEmpty) {
      deliveryId = value(['deliveryNumber', 'code', 'deliveryId', '_id', 'id'], fallback: '');
    }

    fetchDetails();
  }

  void _seedFromItem(dynamic item) {
    if (item == null) return;
    if (item is Map) {
      delivery.addAll(Map<String, dynamic>.from(item));
      if (deliveryId.isEmpty) {
        deliveryId = value(['deliveryNumber', 'code', 'deliveryId', '_id', 'id'], fallback: '');
      }
      return;
    }
    // Handle DeliveryItem model
    try {
      delivery.addAll({
        'deliveryNumber': (item as dynamic).code ?? (item as dynamic).id,
        'deliveryId': (item as dynamic).id,
        'description': (item as dynamic).description ?? (item as dynamic).title,
        'materialType': '-',
        'status': (item as dynamic).status.toString().toUpperCase(),
        'priority': (item as dynamic).priority?.name ?? '-',
        'loadWeight': (item as dynamic).quantity ?? '-',
        'stagingArea': (item as dynamic).stagingArea ?? '-',
        'location': (item as dynamic).location,
        'destination': (item as dynamic).finalDestination ?? (item as dynamic).location,
        'notes': (item as dynamic).notes ?? 'No special instructions provided.',
        'eta': (item as dynamic).eta ?? '-',
        'project': {
          'projectName': (item as dynamic).projectName ?? (item as dynamic).project,
          'name': (item as dynamic).projectName ?? (item as dynamic).project,
          'jobId': (item as dynamic).jobId,
          'location': (item as dynamic).location,
        },
        'carrier': {
          'name': (item as dynamic).carrier,
          'carrierName': (item as dynamic).carrier,
          'driverName': (item as dynamic).driver,
          'phone': (item as dynamic).phone,
        },
        'siteContact': {
          'contactName': '-',
          'phone': (item as dynamic).phone ?? '-',
          'role': 'Site Receiving Lead',
        },
        'schedule': {
          'arrivalAtPlant': (item as dynamic).arrivalAtPlant,
          'departureFromPlant': (item as dynamic).departureFromPlant,
          'deliveryDate': (item as dynamic).date ?? (item as dynamic).departureFromPlant,
        },
      });
      if (deliveryId.isEmpty) {
        deliveryId = (item as dynamic).id?.toString() ?? '';
      }
    } catch (_) {}
  }


  Future<void> fetchDetails() async {
    isLoading.value = true;
    try {
      Map<String, dynamic>? detail;

      // 1. If we have a deliveryId, try to fetch it directly
      if (deliveryId.isNotEmpty) {
        detail = await _service.getDeliveryDetail(deliveryId);
      }

      // 2. If detail not found, and we have a leadId:
      if ((detail == null || detail.isEmpty) && leadId.isNotEmpty) {
        final matRes = await _service.getProjectMaterialDeliveries(leadId);
        List deliveriesList = [];
        if (matRes is Map) {
          final dData = matRes.containsKey('data') ? matRes['data'] : matRes;
          if (dData is Map && dData['deliveries'] is List) {
            deliveriesList = dData['deliveries'] as List;
          } else if (dData is List) {
            deliveriesList = dData;
          }
        } else if (matRes is List) {
          deliveriesList = matRes;
        }

        // 3. Fallback to project details if material-deliveries was empty
        if (deliveriesList.isEmpty) {
          final projRes = await _service.getProjectDetails(leadId);
          if (projRes is Map) {
            final pData = projRes.containsKey('data') ? projRes['data'] : projRes;
            if (pData is Map && pData['deliveries'] is List) {
              deliveriesList = pData['deliveries'] as List;
            }
          }
        }

        // 4. Match the delivery or take first
        if (deliveriesList.isNotEmpty) {
          dynamic matched;
          if (deliveryId.isNotEmpty) {
            matched = deliveriesList.firstWhere(
              (d) =>
                  d is Map &&
                  ((d['_id'] ?? '').toString() == deliveryId ||
                      (d['deliveryId'] ?? '').toString() == deliveryId ||
                      (d['deliveryNumber'] ?? '').toString() == deliveryId ||
                      (d['code'] ?? '').toString() == deliveryId),
              orElse: () => null,
            );
          }
          matched ??= deliveriesList.first;

          if (matched is Map) {
            final foundId = (matched['_id'] ??
                    matched['deliveryId'] ??
                    matched['deliveryNumber'] ??
                    matched['id'] ??
                    '')
                .toString();
            _seedFromItem(matched);
            if (foundId.isNotEmpty) {
              detail = await _service.getDeliveryDetail(foundId);
            }
          }
        }
      }

      // 2b. If still null, search general deliveries list (/construction/deliveries)
      if (detail == null || detail.isEmpty) {
        try {
          final allDeliveries = await _service.getDeliveries();
          List list = [];
          if (allDeliveries is Map && allDeliveries['deliveries'] is List) {
            list = allDeliveries['deliveries'] as List;
          } else if (allDeliveries is List) {
            list = allDeliveries;
          }
          if (list.isNotEmpty && deliveryId.isNotEmpty) {
            final matched = list.firstWhere(
              (d) =>
                  d is Map &&
                  ((d['_id'] ?? '').toString() == deliveryId ||
                      (d['deliveryId'] ?? '').toString() == deliveryId ||
                      (d['deliveryNumber'] ?? '').toString() == deliveryId ||
                      (d['code'] ?? '').toString() == deliveryId),
              orElse: () => null,
            );
            if (matched is Map) {
              _seedFromItem(matched);
              final foundId =
                  (matched['_id'] ?? matched['id'] ?? '').toString();
              if (foundId.isNotEmpty && foundId != deliveryId) {
                detail = await _service.getDeliveryDetail(foundId);
              }
            }
          }
        } catch (_) {}
      }

      // 5. Merge API response
      if (detail != null && detail.isNotEmpty) {
        final raw = detail['delivery'] is Map ? detail['delivery'] as Map : detail;
        delivery.addAll(Map<String, dynamic>.from(raw));
        if (deliveryId.isEmpty) {
          deliveryId = value(['deliveryNumber', 'code', 'deliveryId', '_id', 'id'], fallback: '');
        }
      }

      // 6. Ensure project info is retained if provided in args
      if (projectNameArg.isNotEmpty) {
        final existingProj = delivery['project'];
        if (existingProj == null) {
          delivery['project'] = {
            'projectName': projectNameArg,
            'name': projectNameArg,
            'jobId': jobIdArg,
            'location': locationArg,
          };
        } else if (existingProj is Map) {
          final pMap = Map<String, dynamic>.from(existingProj);
          if (pMap['projectName'] == null || pMap['projectName'].toString().isEmpty) {
            pMap['projectName'] = projectNameArg;
          }
          if (locationArg.isNotEmpty && (pMap['location'] == null || pMap['location'].toString().isEmpty)) {
            pMap['location'] = locationArg;
          }
          delivery['project'] = pMap;
        } else if (existingProj is String && existingProj.length == 24) {
          delivery['project'] = {
            'projectName': projectNameArg,
            'name': projectNameArg,
            'jobId': jobIdArg,
            'location': locationArg,
          };
        }
      }
    } catch (error, stackTrace) {
      AppLogger.e(
        'Delivery detail fetch failed',
        error: error,
        stackTrace: stackTrace,
        tag: 'DELIVERY_DETAILS',
      );
    } finally {
      isLoading.value = false;
    }
  }

  String get requestId =>
      value(['deliveryId', '_id', 'id'], fallback: deliveryId);

  String value(List<String> keys, {String fallback = '—'}) {
    for (final key in keys) {
      final candidate = delivery[key];
      if (candidate != null &&
          candidate.toString().trim().isNotEmpty &&
          candidate.toString() != 'null') {
        return candidate.toString();
      }
    }
    return fallback;
  }

  Map<String, dynamic> mapValue(List<String> keys) {
    for (final key in keys) {
      final candidate = delivery[key];
      if (candidate is Map) return Map<String, dynamic>.from(candidate);
    }
    return const {};
  }

  List<dynamic> listValue(List<String> keys) {
    for (final key in keys) {
      final candidate = delivery[key];
      if (candidate is List) return candidate;
    }
    return const [];
  }

  String nestedValue(
    Map<String, dynamic> source,
    List<String> keys, {
    String fallback = '—',
  }) {
    for (final key in keys) {
      final candidate = source[key];
      if (candidate != null &&
          candidate.toString().trim().isNotEmpty &&
          candidate.toString() != 'null') {
        return candidate.toString();
      }
    }
    return fallback;
  }

  Future<bool> markReceived() => _runAction(
    () => _service.markReceived(requestId),
    successMessage: 'Delivery marked as received',
  );

  Future<bool> markPartial(
    String notes, {
    List<Map<String, dynamic>>? items,
    String? reason,
  }) => _runAction(
    () => _service.markPartial(
      requestId,
      notes,
      items: items,
      reason: reason,
    ),
    successMessage: 'Partial receipt & mismatch report saved',
  );

  Future<bool> updateSiteContact(Map<String, dynamic> contact) => _runAction(
    () => _service.updateSiteContact(requestId, contact),
    successMessage: 'Site contact updated',
  );

  Future<void> downloadDocument(String type) async {
    isActionLoading.value = true;
    try {
      final url = type == 'bill-of-lading'
          ? await _service.downloadBillOfLadingPdf(requestId)
          : await _service.downloadPackingListPdf(requestId);
      if (url == null || url.isEmpty) {
        AppToast.showError(title: 'Document is not available');
      } else {
        AppToast.showSuccess(title: 'Download link received', description: url);
      }
    } catch (e) {
      AppToast.showError(title: 'Failed to download document');
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> _runAction(
    Future<bool> Function() request, {
    required String successMessage,
  }) async {
    if (isActionLoading.value) return false;
    isActionLoading.value = true;
    try {
      final success = await request();
      if (!success) {
        AppToast.showError(
          title: 'Request failed',
          description: 'Please try again.',
        );
        return false;
      }
      await fetchDetails();
      AppToast.showSuccess(title: successMessage);
      return true;
    } finally {
      isActionLoading.value = false;
    }
  }
}
