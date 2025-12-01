import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/models.dart';

class Api {
  final String baseUrl;
  Api({required this.baseUrl});

  Future<LoginResponse> login(String email, String password) async {
    final resp = await http.post(Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));

    if (resp.statusCode != 200) {
      throw Exception('login failed: ${resp.body}');
    }

    return LoginResponse.fromJson(jsonDecode(resp.body));
  }

  Future<VerifyOTPResponse> verifyOtp(String email, String otp) async {
    final resp = await http.post(Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}));

    if (resp.statusCode != 200) {
      throw Exception('verify otp failed: ${resp.body}');
    }

    return VerifyOTPResponse.fromJson(jsonDecode(resp.body));
  }

  Future<List<Vault>> listVaults(String token, int userId) async {
    final uri = Uri.parse('$baseUrl/vaults?user_id=$userId');
    final resp = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (resp.statusCode != 200) {
      throw Exception('list vaults failed: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as List;
    return data.map((e) => Vault.fromJson(e)).toList();
  }

  Future<Vault> createVault(String token, String name, String type, int userId) async {
    final uri = Uri.parse('$baseUrl/vaults/create');
    final resp = await http.post(uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'name': name, 'type': type, 'userID': userId}));
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('create vault failed: ${resp.body}');
    }
    return Vault.fromJson(jsonDecode(resp.body));
  }

  Future<String> registerDevice(String token, String name, int userId) async {
    final uri = Uri.parse('$baseUrl/devices/register');
    final resp = await http.post(uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'name': name, 'userID': userId}));
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('register device failed: ${resp.body}');
    }
    final j = jsonDecode(resp.body);
    if (j is Map<String, dynamic>) {
      // Try common key variants that the server might return
      final possible = [
        j['id'],
        j['ID'],
        j['Id'],
        j['identity'],
      ];
      for (final p in possible) {
        if (p != null) return p.toString();
      }
    }
    return '';
  }

  Future<List<ThumbnailItem>> getThumbnails(String token, int userId, String vaultId) async {
    final uri = Uri.parse('$baseUrl/thumbnail?userId=$userId&vaultId=$vaultId&emulator=1');
    final resp = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (resp.statusCode != 200) {
      throw Exception('get thumbnails failed: ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    final List<ThumbnailItem> items = [];

    if (data is Map) {
      final groups = data['Thumbnails'] ?? data['thumbnails'] ?? data['Thumbnails'];
      if (groups is List) {
        for (final g in groups) {
          if (g is Map) {
            final objects = g['Objects'] ?? g['objects'] ?? g['Objects'];
            if (objects is List) {
              for (final o in objects) {
                if (o is Map) {
                  final raw = ThumbnailItem.fromJson(Map<String, dynamic>.from(o));
                  items.add(raw);
                }
              }
            }
          }
        }
      }
    } else if (data is List) {
      for (final e in data) {
        if (e is Map) {
          final raw = ThumbnailItem.fromJson(Map<String, dynamic>.from(e));
          items.add(raw);
        }
      }
    }

    return items;
  }

  Future<String> getFileUrl(String token, int userId, String fileId) async {
    final uri = Uri.parse('$baseUrl/files/download?user_id=$userId&file_id=$fileId&emulator=1');
    final resp = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (resp.statusCode != 200) {
      throw Exception('get file url failed: ${resp.body}');
    }
    final j = jsonDecode(resp.body);
    if (j is Map && j['url'] != null) return j['url'].toString();
    throw Exception('unexpected response');
  }

  // Fetch file bytes via server streaming endpoint (authenticated)
  Future<List<int>> fetchFileBytes(String token, int userId, String fileId, {bool thumbnail = false}) async {
    final thumbFlag = thumbnail ? '&thumbnail=1' : '';
    final uri = Uri.parse('$baseUrl/files/stream?user_id=$userId&file_id=$fileId$thumbFlag');
    final resp = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    if (resp.statusCode != 200) {
      throw Exception('fetch file failed: ${resp.statusCode} ${resp.body}');
    }
    return resp.bodyBytes;
  }

  // Rewrite localhost/127.0.0.1 hostnames to the Android emulator host alias
  // so Image.network and http clients inside the emulator can reach the
  // development server running on the host machine.
  String _rewriteEmulatorUrl(String url) {
    if (url.isEmpty) return url;
    try {
      final u = Uri.parse(url);
      // If it's a file:// URL, return as-is (caller will handle) but it's
      // probably not what we want for remote files.
      if (u.scheme == 'file') return url;

      String host = u.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        final replaced = url.replaceFirst(host, '10.0.2.2');
        return replaced;
      }
      return url;
    } catch (e) {
      return url;
    }
  }

  // deviceId should be the device UUID string registered for the user.
  Future<void> uploadFile(String token, String deviceId, String vaultId, File file) async {
    final uri = Uri.parse('$baseUrl/files/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['vault_id'] = vaultId;
    request.fields['device_id'] = deviceId;
    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('upload failed: ${resp.body}');
    }
    return;
  }
}
