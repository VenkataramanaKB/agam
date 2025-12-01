class LoginResponse {
  final String message;
  final int userId;

  LoginResponse({required this.message, required this.userId});

  factory LoginResponse.fromJson(Map<String, dynamic> j) => LoginResponse(
        message: j['message'] ?? '',
        userId: j['user_id'] ?? 0,
      );
}

class VerifyOTPResponse {
  final String token;
  final int userId;
  final String name;
  final String email;

  VerifyOTPResponse({required this.token, required this.userId, required this.name, required this.email});

  factory VerifyOTPResponse.fromJson(Map<String, dynamic> j) => VerifyOTPResponse(
        token: j['token'] ?? '',
        userId: j['user_id'] ?? 0,
        name: j['name'] ?? '',
        email: j['email'] ?? '',
      );
}

class Vault {
  final String id;
  final String name;
  final String type;

  Vault({required this.id, required this.name, required this.type});

  factory Vault.fromJson(Map<String, dynamic> j) => Vault(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        type: j['type'] ?? '',
      );
}

class ThumbnailItem {
  final String fileId;
  final String thumbnailUrl;

  ThumbnailItem({required this.fileId, required this.thumbnailUrl});

  factory ThumbnailItem.fromJson(Map<String, dynamic> j) => ThumbnailItem(
      fileId: j['fileID']?.toString() ?? j['fileId']?.toString() ?? j['FileID']?.toString() ?? j['file_id']?.toString() ?? j['id']?.toString() ?? j['ID']?.toString() ?? '',
      thumbnailUrl: j['ThumbnailURL']?.toString() ?? j['thumbnailURL']?.toString() ?? j['thumbnail']?.toString() ?? j['Thumbnail']?.toString() ?? '',
      );
}
