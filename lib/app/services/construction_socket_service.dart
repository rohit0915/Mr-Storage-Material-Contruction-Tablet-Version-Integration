import 'dart:async';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/api_constants.dart';
import '../utils/app_logger.dart';
import '../utils/app_toast.dart';
import 'api_client.dart';

class ConstructionSocketEvent {
  final String name;
  final Map<String, dynamic> payload;

  const ConstructionSocketEvent(this.name, this.payload);
}

class ConstructionSocketService extends GetxService {
  /// Team chat events on /admin
  static const teamEvents = <String>{
    'new_team_message',
    'new_team_dm_notice',
    'team_typing',
    'team_chat_error',
  };

  /// Drawing & document events
  static const drawingEvents = <String>{'drawing_status_updated'};

  /// Lead / project chat events
  static const leadChatEvents = <String>{
    'chat_status',
    'new_message',
    'customer_typing',
    'customer_online_status',
    'staff_chat_active',
    'chat_ended',
    'chat_reopened',
    'error',
  };

  /// Staff and construction notifications
  static const notificationEvents = <String>{
    'project_assigned',
    'bom_extraction_complete',
    'bom_extraction_failed',
    'bom_review_complete',
    'shipper_file_submitted',
    'all_shipper_files_submitted',
    'shipper_comparison_complete',
    'shipper_comparison_failed',
    'freight_bid_submitted',
    'all_freight_bids_submitted',
    'lead_list_created',
    'lead_list_updated',
    'new_customer_message',
    'lead_assigned',
    'new_escalation',
    'new_po_order',
    'payment_proof_submitted',
    'followup:reminder',
  };

  final isConnected = false.obs;
  final connectionError = ''.obs;

  final _events = StreamController<ConstructionSocketEvent>.broadcast();
  final _activeTeamChannels = <String, Map<String, String>>{};
  final _activeLeadRooms = <String>{};
  io.Socket? _socket;

  Stream<ConstructionSocketEvent> get events => _events.stream;

  bool _attemptedFallback = false;

  /// Connects to socket with the stored JWT token
  void connect({bool isFallback = false}) {
    if (!Get.isRegistered<ApiClient>()) return;
    final token = Get.find<ApiClient>().token;
    if (token == null || token.isEmpty) {
      AppLogger.w(
        'Socket connection skipped: no access token available',
        tag: 'SOCKET',
      );
      return;
    }

    if (!isFallback) {
      _attemptedFallback = false;
    }

    disconnect(clearRooms: false);

    final cleanToken = token.startsWith('Bearer ') ? token.substring(7) : token;
    final bearerToken = token.startsWith('Bearer ') ? token : 'Bearer $token';

    final namespace = isFallback ? '' : ApiConstants.socketNamespace;
    final socketUrl = '${ApiConstants.serverOrigin}$namespace';
    AppLogger.i('Connecting to Socket.io at $socketUrl', tag: 'SOCKET');

    final socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({
            'token': cleanToken,
            'accessToken': cleanToken,
            'authorization': bearerToken,
          })
          .setQuery({
            'token': cleanToken,
            'accessToken': cleanToken,
            'authorization': bearerToken,
          })
          .setExtraHeaders({'Authorization': bearerToken})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      isConnected.value = true;
      connectionError.value = '';
      AppLogger.i(
        'Construction socket connected successfully ($socketUrl)',
        tag: 'SOCKET',
      );

      // Server auto-joins user:<userId>; calling join_user_room makes reconnect explicit
      socket.emit('join_user_room', <String, dynamic>{});

      // Restore active team channels
      for (final channel in _activeTeamChannels.values) {
        socket.emit('join_team_channel', channel);
      }

      // Restore active lead chat rooms
      for (final leadId in _activeLeadRooms) {
        socket.emit('join_lead_chat', {'leadId': leadId});
      }
    });

    socket.onDisconnect((_) {
      isConnected.value = false;
      AppLogger.w('Construction socket disconnected', tag: 'SOCKET');
    });

    socket.onConnectError((error) {
      isConnected.value = false;
      final errStr = error?.toString() ?? 'Socket connection failed';
      connectionError.value = errStr;
      AppLogger.w('Construction socket connect error: $errStr', tag: 'SOCKET');

      // Fallback from /admin to root namespace if server reports invalid namespace
      if (!isFallback &&
          !_attemptedFallback &&
          errStr.toLowerCase().contains('invalid namespace')) {
        _attemptedFallback = true;
        AppLogger.i(
          'Namespace $namespace returned invalid namespace. Falling back to root socket: ${ApiConstants.serverOrigin}',
          tag: 'SOCKET',
        );
        connect(isFallback: true);
        return;
      }

      if (errStr.toLowerCase().contains('invalid token') ||
          errStr.toLowerCase().contains('unauthorized')) {
        if (Get.isRegistered<ApiClient>()) {
          Get.find<ApiClient>().tryRefreshToken();
        }
      }
    });

    socket.onError((error) {
      AppLogger.w('Construction socket general error: $error', tag: 'SOCKET');
    });

    // Register all event listeners
    for (final eventName in teamEvents) {
      socket.on(eventName, (data) => _handleTeamEvent(eventName, data));
    }
    for (final eventName in drawingEvents) {
      socket.on(eventName, (data) => _handleDrawingEvent(eventName, data));
    }
    for (final eventName in leadChatEvents) {
      socket.on(eventName, (data) => _handleEvent(eventName, data));
    }
    for (final eventName in notificationEvents) {
      socket.on(eventName, (data) => _handleNotificationEvent(eventName, data));
    }

    socket.connect();
  }

  /// Reconnect with updated token (e.g. after refresh)
  void reconnectWithLatestToken() => connect();

  /// Listen for a specific subset of events
  StreamSubscription<ConstructionSocketEvent> listenFor(
    Set<String> eventNames,
    FutureOr<void> Function(ConstructionSocketEvent event) listener,
  ) {
    return events
        .where((event) => eventNames.contains(event.name))
        .listen(listener);
  }

  // ─── Team Chat Emits ────────────────────────────────────────────────────────

  void joinTeamChannel(String channelType, String channelId) {
    final payload = {'channelType': channelType, 'channelId': channelId};
    _activeTeamChannels['$channelType:$channelId'] = payload;
    _socket?.emit('join_team_channel', payload);
    AppLogger.i(
      'Joined team channel: $channelType / $channelId',
      tag: 'SOCKET',
    );
  }

  void leaveTeamChannel(String channelType, String channelId) {
    _activeTeamChannels.remove('$channelType:$channelId');
    _socket?.emit('leave_team_channel', {
      'channelType': channelType,
      'channelId': channelId,
    });
    AppLogger.i('Left team channel: $channelType / $channelId', tag: 'SOCKET');
  }

  bool sendTeamMessage(
    String channelType,
    String channelId,
    String content, {
    List<Map<String, dynamic>> attachments = const [],
  }) {
    if (!isConnected.value || (content.trim().isEmpty && attachments.isEmpty)) {
      return false;
    }
    _socket?.emit('team_message', {
      'channelType': channelType,
      'channelId': channelId,
      'content': content.trim(),
      if (attachments.isNotEmpty) 'attachments': attachments,
    });
    AppLogger.i(
      'Sent team message to $channelType / $channelId',
      tag: 'SOCKET',
    );
    return true;
  }

  void setTeamTyping(String channelType, String channelId, bool typing) {
    _socket?.emit(typing ? 'team_typing_start' : 'team_typing_stop', {
      'channelType': channelType,
      'channelId': channelId,
    });
  }

  // ─── Lead / Project Chat Emits ──────────────────────────────────────────────

  void joinLeadChat(String leadId) {
    if (leadId.isEmpty) return;
    _activeLeadRooms.add(leadId);
    _socket?.emit('join_lead_chat', {'leadId': leadId});
    AppLogger.i('Joined lead chat room: $leadId', tag: 'SOCKET');
  }

  void leaveLeadChat(String leadId) {
    if (leadId.isEmpty) return;
    _activeLeadRooms.remove(leadId);
    _socket?.emit('leave_lead_chat', {'leadId': leadId});
    AppLogger.i('Left lead chat room: $leadId', tag: 'SOCKET');
  }

  bool sendSalesMessage(String leadId, String content) {
    if (!isConnected.value || content.trim().isEmpty) return false;
    _socket?.emit('sales_message', {
      'leadId': leadId,
      'content': content.trim(),
    });
    return true;
  }

  void setSalesTyping(String leadId, bool typing) {
    _socket?.emit(typing ? 'sales_typing_start' : 'sales_typing_stop', {
      'leadId': leadId,
    });
  }

  void markMessagesRead(String leadId) {
    _socket?.emit('mark_messages_read', {'leadId': leadId});
  }

  void endLeadChat(String leadId) {
    _socket?.emit('end_lead_chat', {'leadId': leadId});
  }

  void reopenLeadChat(String leadId) {
    _socket?.emit('reopen_lead_chat', {'leadId': leadId});
  }

  // ─── Event Dispatchers & Global Handlers ────────────────────────────────────

  void _handleEvent(String name, dynamic data) {
    final payload = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{'data': data};
    _events.add(ConstructionSocketEvent(name, payload));
  }

  void _handleTeamEvent(String name, dynamic data) {
    final payload = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{'data': data};
    _events.add(ConstructionSocketEvent(name, payload));

    if (name == 'new_team_dm_notice') {
      final senderName = payload['fromName']?.toString() ?? 'New Message';
      final msg =
          payload['content']?.toString() ??
          'You received a new direct message.';
      AppToast.showInfo(title: senderName, description: msg);
    } else if (name == 'team_chat_error') {
      final errorMsg =
          payload['message']?.toString() ?? 'Something went wrong in chat.';
      AppToast.showError(title: 'Chat Error', description: errorMsg);
    }
  }

  void _handleDrawingEvent(String name, dynamic data) {
    final payload = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{'data': data};
    _events.add(ConstructionSocketEvent(name, payload));

    if (name == 'drawing_status_updated') {
      final status = payload['status']?.toString() ?? 'updated';
      AppToast.showSuccess(
        title: 'Drawing Status Updated',
        description: 'Drawing document status is now $status',
      );
    }
  }

  void _handleNotificationEvent(String name, dynamic data) {
    final payload = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{'data': data};
    _events.add(ConstructionSocketEvent(name, payload));

    if (name == 'project_assigned') {
      final projectName = payload['projectName']?.toString() ?? 'A project';
      AppToast.showSuccess(
        title: 'Project Assigned',
        description: '$projectName has been assigned.',
      );
    } else if (name == 'followup:reminder') {
      final message =
          payload['message']?.toString() ?? 'Follow-up reminder due!';
      AppToast.showWarning(title: 'Follow-up Reminder', description: message);
    }
  }

  /// Disconnect and cleanup
  void disconnect({bool clearRooms = true}) {
    final socket = _socket;
    if (socket != null) {
      for (final eventName in teamEvents) {
        socket.off(eventName);
      }
      for (final eventName in drawingEvents) {
        socket.off(eventName);
      }
      for (final eventName in leadChatEvents) {
        socket.off(eventName);
      }
      for (final eventName in notificationEvents) {
        socket.off(eventName);
      }
      socket.dispose();
    }
    if (clearRooms) {
      _activeTeamChannels.clear();
      _activeLeadRooms.clear();
    }
    _socket = null;
    isConnected.value = false;
    AppLogger.i('Construction socket disconnected and disposed', tag: 'SOCKET');
  }

  @override
  void onClose() {
    disconnect();
    _events.close();
    super.onClose();
  }
}
