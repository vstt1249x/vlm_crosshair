import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_version.dart';

class UpdateDialog extends StatelessWidget {
  final AppVersion appVersion;

  const UpdateDialog({super.key, required this.appVersion});

  static void show(BuildContext context, AppVersion appVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(appVersion: appVersion),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đã có phiên bản mới!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phiên bản: ${appVersion.version} (Build ${appVersion.buildNumber})'),
          const SizedBox(height: 10),
          const Text('Nội dung cập nhật:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(appVersion.releaseNotes),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Để sau'),
        ),
        ElevatedButton(
          onPressed: () async {
            final uri = Uri.parse(appVersion.downloadUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Tải ngay'),
        ),
      ],
    );
  }
}