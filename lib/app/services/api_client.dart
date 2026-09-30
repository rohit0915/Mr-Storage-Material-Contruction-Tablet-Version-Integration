import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../routes/app_routes.dart';
import '../utils/app_logger.dart';
import '../utils/app_toast.dart';
import 'construction_socket_service.dart';

class ApiClient extends GetxService {
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  SharedPreferences? _prefs;
  String? _token;
  String? _refreshToken;
  bool _isHandlingUnauthorized = false;
  Completer<bool>? _refreshCompleter;

  String get baseUrl => ApiConstants.baseUrl;

  Future<ApiClient> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs?.getString(_tokenKey);
    _refreshToken = _prefs?.getString(_refreshTokenKey);
    AppLogger.i(
      'ApiClient initialized. Saved token present: ${_token != null && _token!.isNotEmpty}',
      tag: 'API',
    );
    return this;
  }

  String? get token => _token;
  String? get refreshToken =>
      _refreshToken ?? _prefs?.getString(_refreshTokenKey);

  Future<void> saveToken(String token) async {
    _token = token;
    await _prefs?.setString(_tokenKey, token);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    _refreshToken = refreshToken;
    await _prefs?.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs?.setString(_userKey, jsonEncode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final dataStr = _prefs?.getString(_userKey);
    if (dataStr != null) {
      try {
        final decoded = jsonDecode(dataStr);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        AppLogger.e('Error decoding user data', error: e, tag: 'API');
      }
    }
    return null;
  }

  Future<void> clearAuthData() async {
    _token = null;
    _refreshToken = null;
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_refreshTokenKey);
    await _prefs?.remove(_userKey);

    if (Get.isRegistered<ConstructionSocketService>()) {
      Get.find<ConstructionSocketService>().disconnect();
    }
  }

  Future<bool> tryRefreshToken() async {
    final rToken = (refreshToken != null && refreshToken!.isNotEmpty)
        ? refreshToken
        : _token;
    if (rToken == null || rToken.isEmpty) {
      AppLogger.w(
        'No refresh token or current token available for refresh.',
        tag: 'API',
      );
      return false;
    }

    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      AppLogger.i(
        'Token refresh already in progress. Waiting for ongoing refresh...',
        tag: 'API',
      );
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final endpoints = [ApiConstants.refreshToken, '/auth/refresh-token'];
      for (final ep in endpoints) {
        try {
          AppLogger.i(
            'Attempting automatic token refresh via POST $ep...',
            tag: 'API',
          );
          final uri = Uri.parse('$baseUrl$ep');
          final headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (rToken.isNotEmpty) 'Authorization': 'Bearer $rToken',
          };
          final bodyMap = {
            'refreshToken': rToken,
            'token': rToken,
            'access_token': rToken,
          };

          final response = await http
              .post(uri, headers: headers, body: jsonEncode(bodyMap))
              .timeout(const Duration(seconds: 15));

          AppLogger.i(
            'Refresh Token Response [$ep -> ${response.statusCode}]',
            tag: 'API',
          );

          if (response.statusCode >= 200 && response.statusCode < 300) {
            final body = jsonDecode(response.body);
            if (body is Map) {
              final data = body['data'] ?? body;
              if (data is Map) {
                final newAccessToken =
                    data['accessToken'] ??
                    data['token'] ??
                    data['jwt'] ??
                    body['accessToken'] ??
                    body['token'];
                final newRefreshToken =
                    data['refreshToken'] ??
                    data['refresh_token'] ??
                    body['refreshToken'];

                if (newAccessToken != null &&
                    newAccessToken.toString().isNotEmpty) {
                  await saveToken(newAccessToken.toString());
                  if (newRefreshToken != null &&
                      newRefreshToken.toString().isNotEmpty) {
                    await saveRefreshToken(newRefreshToken.toString());
                  }
                  AppLogger.i(
                    'Token refreshed successfully via $ep! New token saved.',
                    tag: 'API',
                  );

                  if (Get.isRegistered<ConstructionSocketService>()) {
                    Get.find<ConstructionSocketService>()
                        .reconnectWithLatestToken();
                  }

                  if (!(_refreshCompleter?.isCompleted ?? true)) {
                    _refreshCompleter?.complete(true);
                  }
                  return true;
                }
              }
            }
          }
        } catch (subErr) {
          AppLogger.w('Refresh attempt for $ep failed: $subErr', tag: 'API');
        }
      }
      AppLogger.w('All token refresh endpoints failed.', tag: 'API');
      if (!(_refreshCompleter?.isCompleted ?? true)) {
        _refreshCompleter?.complete(false);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Token refresh exception',
        error: e,
        stackTrace: stackTrace,
        tag: 'API',
      );
      if (!(_refreshCompleter?.isCompleted ?? true)) {
        _refreshCompleter?.complete(false);
      }
    } finally {
      _refreshCompleter = null;
    }
    return false;
  }

  void _handleUnauthorized() {
    if (_isHandlingUnauthorized) return;
    if (Get.currentRoute == AppRoutes.login) return;
    _isHandlingUnauthorized = true;

    final hadToken = _token != null && _token!.isNotEmpty;
    clearAuthData();

    if (hadToken) {
      AppToast.showError(
        title: 'Session Expired',
        description: 'Your session has expired. Please login again.',
      );
    }

    Get.offAllNamed(AppRoutes.login);

    Future.delayed(const Duration(seconds: 2), () {
      _isHandlingUnauthorized = false;
    });
  }

  Map<String, String> _buildHeaders({Map<String, String>? customHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final urlStr = endpoint.startsWith('http') ? endpoint : '$baseUrl$endpoint';
    final uri = Uri.parse(urlStr);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: {...uri.queryParameters, ...queryParams},
      );
    }
    return uri;
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    bool isRetry = false,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final reqHeaders = _buildHeaders(customHeaders: headers);
      AppLogger.i('GET $uri', tag: 'API');

      final response = await http
          .get(uri, headers: reqHeaders)
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 401 && !isRetry) {
        AppLogger.w(
          'GET $endpoint returned 401. Triggering auto token refresh...',
          tag: 'API',
        );
        final refreshed = await tryRefreshToken();
        if (refreshed) {
          return get(
            endpoint,
            queryParams: queryParams,
            headers: headers,
            isRetry: true,
          );
        } else {
          _handleUnauthorized();
          throw ApiException('Unauthorized', 401);
        }
      }

      return _processResponse(response);
    } on ApiException catch (e) {
      if (e.statusCode == 401 && !isRetry) {
        AppLogger.w(
          'ApiException 401 for GET $endpoint. Triggering auto token refresh...',
          tag: 'API',
        );
        final refreshed = await tryRefreshToken();
        if (refreshed) {
          return get(
            endpoint,
            queryParams: queryParams,
            headers: headers,
            isRetry: true,
          );
        } else {
          _handleUnauthorized();
        }
      }
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.e(
        'ApiClient GET Exception for $endpoint',
        error: e,
        stackTrace: stackTrace,
        tag: 'API',
      );
      rethrow;
    }
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    bool isRetry = false,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final reqHeaders = _buildHeaders(customHeaders: headers);
      final encodedBody = body != null ? jsonEncode(body) : null;
      AppLogger.i('POST $uri', tag: 'API');

      final response = await http
          .post(uri, headers: reqHeaders, body: encodedBody)
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 401 &&
          !isRetry &&
          !endpoint.contains('/auth/login') &&
          !endpoint.contains('/auth/refresh')) {
        AppLogger.w(
          'POST $endpoint returned 401. Triggering auto token refresh...',
          tag: 'API',
        );
        final refreshed = await tryRefreshToken();
        if (refreshed) {
          return post(endpoint, body: body, headers: headers, isRetry: true);
        } else {
          _handleUnauthorized();
          throw ApiException('Unauthorized', 401);
        }
      }

      return _processResponse(response);
    } on ApiException catch (e) {
      if (e.statusCode == 401 &&
          !isRetry &&
          !endpoint.contains('/auth/login') &&
          !endpoint.contains('/auth/refresh')) {
        AppLogger.w(
          'ApiException 401 for POST $endpoint. Triggering auto token refresh...',
          tag: 'API',
        );
        final refreshed = await tryRefreshToken();
        if (refreshed) {
          return post(endpoint, body: body, headers: headers, isRetry: true);
        } else {
          _handleUnauthorized();
        }
      }
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.e(
        'ApiClient POST Exception for $endpoint',
        error: e,
        stackTrace: stackTrace,
        tag: 'API',
      );
      rethrow;
    }
  }

  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    bool isRetry = false,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final reqHeaders = _buildHeaders(customHeaders: headers);
      final encodedBody = body != null ? jsonEncode(body) : null;
      AppLogger.i('PUT $uri', tag: 'API');

      final response = await http
          .put(uri, headers: reqHeaders, body: encodedBody)
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 401 && !isRetry) {
        AppLogger.w(
          'PUT $endpoint returned 401. Triggering auto token refresh...',
          tag: 'API',
        );
        final refreshed = await tryRefreshToken();
        if (refreshed) {
          return put(endpoint, body: body, headers: headers, isRetry: true);
        } else {
          _handleUnauthorized();
          throw ApiException('Unauthorized', 401);
        }
      }

      return _processResponse(response);
    } on ApiException catch (e) {
      if (e.statusCode == 401 && !isRetry) {
        AppLogger.w(
          'ApiException 401 for PUT $endpoint. Triggering auto token refresh...',
          tag: 'API',
        );
        final refreshed = await tryRefreshToken();
        if (refreshed) {
          return put(endpoint, body: body, headers: headers, isRetry: true);
        } else {
          _handleUnauthorized();
        }
      }
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.e(
        'ApiClient PUT Exception for $endpoint',
        error: e,
        stackTrace: stackTrace,
        tag: 'API',
      );
      rethrow;
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool isRetry = false,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final reqHeaders = _buildHeaders(customHeaders: headers);
      AppLogger.i('DELETE $uri', tag: 'API');

      final response = await http
          .delete(uri, headers: reqHeaders)
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 401 && !isRetry) {
        AppLogger.w(
          'DELETE $endpoint returned 401. Triggering auto token refresh...',
          tag: 'API',
        );
        final refreshed = await tryRefreshToken();
        if (refreshed) {
          return delete(endpoint, headers: headers, isRetry: true);
        } else {
          _handleUnauthorized();
          throw ApiException('Unauthorized', 401);
        }
      }

      return _processResponse(response);
    } on ApiException catch (e) {
      if (e.statusCode == 401 && !isRetry) {
        AppLogger.w(
          'ApiException 401 for DELETE $endpoint. Triggering auto token refresh...',
          tag: 'API',
        );
        final refreshed = await tryRefreshToken();
        if (refreshed) {
          return delete(endpoint, headers: headers, isRetry: true);
        } else {
          _handleUnauthorized();
        }
      }
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.e(
        'ApiClient DELETE Exception for $endpoint',
        error: e,
        stackTrace: stackTrace,
        tag: 'API',
      );
      rethrow;
    }
  }

  dynamic _processResponse(http.Response response) {
    AppLogger.i(
      'API Response [${response.statusCode}] ${response.request?.url}',
      tag: 'API',
    );

    dynamic bodyJson;
    if (response.body.isNotEmpty) {
      try {
        bodyJson = jsonDecode(response.body);
      } catch (_) {
        bodyJson = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (bodyJson is Map && bodyJson['success'] == false) {
        final msg = bodyJson['message']?.toString() ?? '';
        final lowerMsg = msg.toLowerCase();
        if (lowerMsg.contains('token expired') ||
            lowerMsg.contains('jwt expired') ||
            lowerMsg.contains('invalid token') ||
            lowerMsg.contains('unauthorized')) {
          AppLogger.w(
            'API returned 200 with expired token payload: $msg',
            tag: 'API',
          );
          throw ApiException(msg, 401, bodyJson);
        }
      }
      return bodyJson;
    } else {
      String errorMessage =
          'Request failed with status: ${response.statusCode}';
      if (bodyJson is Map) {
        if (bodyJson.containsKey('message') && bodyJson['message'] != null) {
          errorMessage = bodyJson['message'].toString();
        } else if (bodyJson.containsKey('error') && bodyJson['error'] != null) {
          errorMessage = bodyJson['error'].toString();
        }
      }
      AppLogger.w(
        'API Error [${response.statusCode}]: $errorMessage',
        tag: 'API',
      );
      throw ApiException(errorMessage, response.statusCode, bodyJson);
    }
  }
}

class ApiException implements Exception {
  ApiException(this.message, this.statusCode, [this.data]);

  final String message;
  final int statusCode;
  final dynamic data;

  @override
  String toString() => 'ApiException [$statusCode]: $message';
}
