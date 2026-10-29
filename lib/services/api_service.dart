import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/vehicle.dart';

/// Thin client for the Vehiclefy Flask API.
class ApiService {
  ApiService(this.baseUrl, this.apiKey);

  final String baseUrl;
  final String apiKey;

  Uri _uri(String path, [Map<String, String>? query]) {
    final root = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$root/api$path')
        .replace(queryParameters: query == null || query.isEmpty ? null : query);
  }

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (apiKey.isNotEmpty) 'X-API-Key': apiKey,
      };

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() call, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final res = await call().timeout(timeout);
      Map<String, dynamic> body = {};
      if (res.body.isNotEmpty) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      }
      if (res.statusCode >= 200 && res.statusCode < 300) return body;
      throw ApiException(
        body['message']?.toString() ?? 'Request failed (${res.statusCode}).',
        code: body['error']?.toString(),
        status: res.statusCode,
        suggestions: ((body['suggestions'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('The server took too long to respond. Try again.');
    } on FormatException {
      throw ApiException(
          'The server sent an unexpected reply. Is the address in Settings correct?');
    } catch (_) {
      throw ApiException(
          "Can't reach the server at $baseUrl. Check Settings and make sure the backend is running.");
    }
  }

  Future<Map<String, dynamic>> health() =>
      _send(() => http.get(_uri('/health'), headers: _headers),
          timeout: const Duration(seconds: 8));

  Future<Vehicle> lookup(String plate) async {
    final body = await _send(() => http.get(
        _uri('/vehicles/${Uri.encodeComponent(plate.trim())}'),
        headers: _headers));
    return Vehicle.fromJson(body['vehicle'] as Map<String, dynamic>);
  }

  Future<ScanResult> scan(Uint8List bytes, String filename) async {
    final body = await _send(() async {
      final req = http.MultipartRequest('POST', _uri('/scan'))
        ..headers.addAll(_headers)
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: filename.isEmpty ? 'plate.jpg' : filename,
        ));
      return http.Response.fromStream(await req.send());
    }, timeout: const Duration(seconds: 60));
    return ScanResult.fromJson(body);
  }

  Future<List<HistoryItem>> history({int limit = 30}) async {
    final body = await _send(
        () => http.get(_uri('/history', {'limit': '$limit'}), headers: _headers));
    return ((body['items'] as List?) ?? const [])
        .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearHistory() =>
      _send(() => http.delete(_uri('/history'), headers: _headers));

  Future<Stats> stats() async =>
      Stats.fromJson(await _send(() => http.get(_uri('/stats'), headers: _headers)));
}
