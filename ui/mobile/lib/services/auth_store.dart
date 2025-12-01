import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStore {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _deviceIdKey = 'device_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> loadToken() => _storage.read(key: _tokenKey);

  Future<void> saveUserId(int id) => _storage.write(key: _userIdKey, value: id.toString());
  Future<int?> loadUserId() async {
    final s = await _storage.read(key: _userIdKey);
    if (s == null) return null;
    return int.tryParse(s);
  }

  Future<void> saveDeviceId(String id) => _storage.write(key: _deviceIdKey, value: id);
  Future<String?> loadDeviceId() => _storage.read(key: _deviceIdKey);

  Future<void> clearAll() => _storage.deleteAll();
}
