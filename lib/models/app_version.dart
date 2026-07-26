class AppVersion {
  final String version;
  final String buildNumber;
  final String releaseNotes;
  final String downloadUrl;

  AppVersion({
    required this.version,
    required this.buildNumber,
    required this.releaseNotes,
    required this.downloadUrl,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      version: json['version'] ?? '1.0.0',
      buildNumber: json['buildNumber'] ?? '1',
      releaseNotes: json['releaseNotes'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
    );
  }
}