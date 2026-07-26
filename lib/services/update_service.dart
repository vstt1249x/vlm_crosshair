import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../models/app_version.dart';

class UpdateService {
  // Thay đổi URL này thành link 'raw' của file version.json trên GitHub của bạn
  // Ví dụ: https://raw.githubusercontent.com/vstt1249x/vlm_crosshair/main/version.json
  static const String _versionUrl =
      'https://raw.githubusercontent.com/vstt1249x/vlm_crosshair/refs/heads/main/version.json';

  static Future<AppVersion?> fetchRemoteVersion() async {
    try {
      final response = await http.get(Uri.parse(_versionUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AppVersion.fromJson(data);
      }
    } catch (e) {
      print('Lỗi khi kiểm tra cập nhật: $e');
    }
    return null;
  }

  static Future<bool> isUpdateAvailable() async {
    try {
      final remoteVersion = await fetchRemoteVersion();
      if (remoteVersion == null) return false;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 1;
      final remoteBuild = int.tryParse(remoteVersion.buildNumber) ?? 1;

      // So sánh theo buildNumber hoặc version string tùy ý bạn
      return remoteBuild > currentBuild;
    } catch (e) {
      return false;
    }
  }
}