import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Import generated localization
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hplarkquslruqwgbhkvu.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwbGFya3F1c2xydXF3Z2Joa3Z1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0OTA3MzcsImV4cCI6MjEwMDA2NjczN30.Yna-j75FlS8b_nklPhIGzY5bsldYKcaCkslEVguVHQA',
  );

  runApp(const MyApp());
}

// ============================================================
// 📦 MODEL & SERVICE KIỂM TRA CẬP NHẬT TỰ ĐỘNG
// ============================================================
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

class UpdateService {
  // Đường dẫn RAW tới file version.json trên GitHub của bạn
  static const String _versionUrl = 
      'https://raw.githubusercontent.com/vstt1249x/vlm_crosshair/main/version.json';

  static Future<AppVersion?> fetchRemoteVersion() async {
    try {
      final response = await http.get(Uri.parse(_versionUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AppVersion.fromJson(data);
      }
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra cập nhật: $e');
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

      return remoteBuild > currentBuild;
    } catch (e) {
      return false;
    }
  }
}

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
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Đã có phiên bản mới!', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phiên bản: ${appVersion.version} (Build ${appVersion.buildNumber})', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          const Text('Nội dung cập nhật:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          Text(appVersion.releaseNotes, style: const TextStyle(color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () async {
            final uri = Uri.parse(appVersion.downloadUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            if (context.mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: const Text('Tải ngay', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('vi');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language') ?? 'vi';
    if (mounted) {
      setState(() {
        _locale = Locale(langCode);
        _isLoading = false;
      });
    }
  }

  void _changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Kho Tâm Ngắm Valorant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('vi', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: CrosshairHomePage(
        onLanguageChanged: _changeLanguage,
        currentLocale: _locale,
      ),
    );
  }
}

class CrosshairHomePage extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  final Locale currentLocale;

  const CrosshairHomePage({
    super.key,
    required this.onLanguageChanged,
    required this.currentLocale,
  });

  @override
  State<CrosshairHomePage> createState() => _CrosshairHomePageState();
}

class _CrosshairHomePageState extends State<CrosshairHomePage> with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _crosshairs = [];
  List<Map<String, dynamic>> _filteredCrosshairs = [];
  List<Map<String, dynamic>> _hotCrosshairs = [];
  List<String> _favorites = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _currentTab = 0;
  
  bool _isAdmin = false;

  // Biến thống kê
  int _totalUsers = 0;
  int _totalCrosshairs = 0;
  int _totalLikes = 0;
  bool _isLoadingStats = false;

  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFavorites();
    _fetchCrosshairs();
    _checkAdminStatus();
    _loadStats();
    
    // 🚀 TỰ ĐỘNG KIỂM TRA CẬP NHẬT KHI VÀO TRANG CHỦ
    _checkForUpdates();
  }

  // Hàm kiểm tra cập nhật ứng dụng
  void _checkForUpdates() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hasUpdate = await UpdateService.isUpdateAvailable();
      if (!mounted) return;
      if (hasUpdate) {
        final remoteVersion = await UpdateService.fetchRemoteVersion();
        if (!mounted) return;
        if (remoteVersion != null) {
          UpdateDialog.show(context, remoteVersion);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 👇 HÀM MÃ HÓA MẬT KHẨU BẰNG SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // 👇 HÀM CHUYỂN ĐỔI NGÔN NGỮ
  void _changeLanguage(String langCode) {
    final locale = Locale(langCode);
    widget.onLanguageChanged(locale);
  }

  Future<void> _loadStats() async {
    if (!_isAdmin) return;
    setState(() => _isLoadingStats = true);
    try {
      final crosshairResult = await supabase
          .from('crosshairs')
          .select();
      
      int totalCrosshairs = crosshairResult.length;

      final likesResult = await supabase
          .from('crosshairs')
          .select('likes');
      
      int totalLikes = 0;
      for (var item in likesResult) {
        totalLikes += (item['likes'] ?? 0) as int;
      }

      final favoritesResult = await supabase
          .from('favorites')
          .select('user_id');
      
      int totalUsers = 0;
      final uniqueUsers = <String>{};
      for (var item in favoritesResult) {
        final userId = item['user_id'];
        if (userId != null) {
          uniqueUsers.add(userId.toString());
        }
      }
      totalUsers = uniqueUsers.length;

      if (mounted) {
        setState(() {
          _totalCrosshairs = totalCrosshairs;
          _totalLikes = totalLikes;
          _totalUsers = totalUsers;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isAdmin = prefs.getBool('isAdmin') ?? false;
      });
    }
    if (_isAdmin) {
      _loadStats();
    }
  }

  Future<void> _loginAdmin() async {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool obscureText = true;
    bool isChecking = false;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            title: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.redAccent),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.loginAdmin,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.username,
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: obscureText,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setStateDialog(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.adminOnly,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (isChecking) ...[
                  const SizedBox(height: 8),
                  const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.redAccent,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isChecking ? null : () => Navigator.pop(context, false),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: isChecking
                    ? null
                    : () async {
                        setStateDialog(() {
                          isChecking = true;
                        });

                        final username = usernameController.text.trim();
                        final password = passwordController.text.trim();

                        if (username.isEmpty || password.isEmpty) {
                          setStateDialog(() {
                            isChecking = false;
                          });
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng nhập đầy đủ thông tin!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final hashedPassword = _hashPassword(password);

                        try {
                          final result = await supabase
                              .from('admins')
                              .select()
                              .eq('username', username)
                              .eq('password_hash', hashedPassword)
                              .maybeSingle();

                          if (!mounted) return;
                          setStateDialog(() {
                            isChecking = false;
                          });

                          if (result != null) {
                            final prefs = SharedPreferences.getInstance();
                            prefs.then((value) {
                              value.setBool('isAdmin', true);
                            });
                            if (mounted) {
                              setState(() {
                                _isAdmin = true;
                              });
                            }
                            _loadStats();
                            if (!context.mounted) return;
                            Navigator.pop(context, true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.loginSuccess),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.loginFailed),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          setStateDialog(() {
                            isChecking = false;
                          });
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi kết nối: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.login,
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _logoutAdmin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          AppLocalizations.of(context)!.logoutConfirm,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(context)!.logoutConfirmMessage,
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isAdmin');
      if (mounted) {
        setState(() {
          _isAdmin = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.logoutSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> _toggleFavorite(String code) async {
    final prefs = await SharedPreferences.getInstance();
    
    final item = _crosshairs.firstWhere(
      (item) => item['code'] == code,
      orElse: () => {},
    );
    
    if (item.isNotEmpty) {
      final currentLikes = (item['likes'] ?? 0) as int;
      final isFav = _favorites.contains(code);
      
      try {
        await supabase
            .from('crosshairs')
            .update({'likes': isFav ? currentLikes - 1 : currentLikes + 1})
            .eq('code', code);
      } catch (e) {
        // Bỏ qua lỗi
      }
    }
    
    setState(() {
      if (_favorites.contains(code)) {
        _favorites.remove(code);
      } else {
        _favorites.add(code);
      }
    });
    await prefs.setStringList('favorites', _favorites);
    _fetchCrosshairs();
    if (_isAdmin) _loadStats();
  }

  Future<void> _fetchCrosshairs() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('crosshairs')
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      setState(() {
        _crosshairs = List<Map<String, dynamic>>.from(response);
        _filterCrosshairs();
        _updateHotCrosshairs();
        _isLoading = false;
      });
      if (_isAdmin) _loadStats();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.loadError}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterCrosshairs() {
    if (_searchQuery.isEmpty) {
      _filteredCrosshairs = _crosshairs;
    } else {
      _filteredCrosshairs = _crosshairs.where((item) {
        final name = (item['name'] ?? '').toLowerCase();
        final desc = (item['description'] ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || desc.contains(query);
      }).toList();
    }
  }

  void _updateHotCrosshairs() {
    _hotCrosshairs = List.from(_crosshairs)
      ..sort((a, b) => ((b['likes'] ?? 0) as int).compareTo((a['likes'] ?? 0) as int));
    if (_hotCrosshairs.length > 10) {
      _hotCrosshairs = _hotCrosshairs.sublist(0, 10);
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: const AddCrosshairForm(),
      ),
    ).then((_) {
      if (mounted) _fetchCrosshairs();
    });
  }

  Future<void> _deleteCrosshair(Map<String, dynamic> item) async {
    if (!_isAdmin) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.adminDeleteOnly),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final code = item['code'] ?? '';
    final name = item['name'] ?? 'Không tên';
    final imageUrl = item['image_url'] ?? '';

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          AppLocalizations.of(context)!.deleteConfirm,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '${AppLocalizations.of(context)!.deleteMessage}$name"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await supabase.from('crosshairs').delete().eq('code', code);
        
        if (imageUrl.isNotEmpty) {
          try {
            final fileName = imageUrl.split('/').last;
            await supabase.storage
                .from('crosshair-images')
                .remove([fileName]);
          } catch (e) {
            // Bỏ qua lỗi nếu không xóa được ảnh
          }
        }
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.deleteSuccess),
            backgroundColor: Colors.green,
          ),
        );
        _fetchCrosshairs();
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.uploadError}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCrosshairDetail(Map<String, dynamic> item) {
    final code = item['code'] ?? '';
    final name = item['name'] ?? 'Không tên';
    final desc = item['description'] ?? '';
    final imageUrl = item['image_url'] ?? '';
    final isFav = _favorites.contains(code);
    final likes = item['likes'] ?? 0;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                  if (_isAdmin)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteCrosshair(item);
                      },
                    ),
                ],
              ),
              
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.redAccent),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  // ĐÃ SỬA THÀNH LOGO V THAY VÌ ICON TÂM NGẮM MẶC ĐỊNH
                  child: Center(
                    child: Image.asset(
                      'assets/images/LogoV.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 64, color: Colors.redAccent),
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              if (desc.isNotEmpty)
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '$likes ${AppLocalizations.of(context)!.likes}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        code,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${AppLocalizations.of(context)!.copySuccess}$code'),
                              backgroundColor: Colors.green[700],
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _toggleFavorite(code);
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.white : Colors.redAccent,
                      ),
                      label: Text(
                        isFav 
                          ? '${AppLocalizations.of(context)!.unfavorite} ($likes)' 
                          : '${AppLocalizations.of(context)!.favorite} ($likes)',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFav ? Colors.redAccent : Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${AppLocalizations.of(context)!.copySuccess}$code'),
                              backgroundColor: Colors.green[700],
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy, color: Colors.white),
                      label: Text(
                        AppLocalizations.of(context)!.copyCode,
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[800],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              if (_isAdmin)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.admin_panel_settings, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.adminMode,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          local.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _currentTab = index;
            });
          },
          tabs: [
            Tab(icon: const Icon(Icons.list), text: local.tabList),
            Tab(icon: const Icon(Icons.whatshot), text: local.tabHot),
            Tab(icon: const Icon(Icons.info), text: local.tabInfo),
          ],
          labelColor: Colors.redAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.redAccent,
        ),
        actions: [
          // 🌐 Nút đổi ngôn ngữ
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: _changeLanguage,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'vi',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Tiếng Việt'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('English'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _isAdmin ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined,
              color: _isAdmin ? Colors.redAccent : Colors.grey,
            ),
            onPressed: _isAdmin ? _logoutAdmin : _loginAdmin,
            tooltip: _isAdmin ? local.logout : local.loginAdmin,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCrosshairs,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListTab(),
          _buildHotTab(),
          _buildInfoTab(),
        ],
      ),
      floatingActionButton: _currentTab != 2
          ? FloatingActionButton.extended(
              onPressed: _showAddDialog,
              backgroundColor: Colors.redAccent,
              icon: const Icon(Icons.share, color: Colors.white),
              label: Text(
                local.shareYourCrosshair,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildListTab() {
    final local = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filterCrosshairs();
              });
            },
            decoration: InputDecoration(
              hintText: local.searchHint,
              prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
              : _filteredCrosshairs.isEmpty
                  ? Center(
                      child: Text(
                        local.noData,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredCrosshairs.length,
                      itemBuilder: (context, index) {
                        final item = _filteredCrosshairs[index];
                        final code = item['code'] ?? '';
                        final name = item['name'] ?? 'Không tên';
                        final desc = item['description'] ?? '';
                        final imageUrl = item['image_url'] ?? '';
                        final isFav = _favorites.contains(code);
                        final likes = item['likes'] ?? 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          color: const Color(0xFF1E1E1E),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: InkWell(
                            onTap: () => _showCrosshairDetail(item),
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                          )
                                        : Image.asset(
                                            'assets/images/LogoV.png',
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.contain,
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (desc.isNotEmpty)
                                          Text(
                                            desc,
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '${local.code}: $code',
                                              style: const TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(width: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '$likes',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.redAccent : Colors.grey,
                                      size: 22,
                                    ),
                                    onPressed: () => _toggleFavorite(code),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildHotTab() {
    final local = AppLocalizations.of(context)!;
    
    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
        : _hotCrosshairs.isEmpty
            ? Center(
                child: Text(
                  local.noData,
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _hotCrosshairs.length,
                itemBuilder: (context, index) {
                  final item = _hotCrosshairs[index];
                  final name = item['name'] ?? 'Không tên';
                  final desc = item['description'] ?? '';
                  final imageUrl = item['image_url'] ?? '';
                  final likes = item['likes'] ?? 0;
                  final rank = index + 1;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: rank <= 3 ? Colors.red[900]?.withValues(alpha: 0.3) : const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      side: rank <= 3 
                          ? BorderSide(color: Colors.redAccent.withValues(alpha: 0.5), width: 1.5)
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      onTap: () => _showCrosshairDetail(item),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: rank <= 3 ? Colors.redAccent : Colors.grey[800],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$rank',
                                  style: TextStyle(
                                    color: rank <= 3 ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                    )
                                  : Image.asset(
                                      'assets/images/LogoV.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (desc.isNotEmpty)
                                    Text(
                                      desc,
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$likes ${local.likes}',
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (rank <= 3)
                              const Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
  }

  Widget _buildInfoTab() {
    final local = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.asset(
                'assets/images/LogoV.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.gps_fixed,
                      size: 60,
                      color: Colors.redAccent,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            local.appTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              local.version,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          if (_isAdmin) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics, color: Colors.redAccent, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        local.stats,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 12),
                  
                  if (_isLoadingStats)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.redAccent),
                    )
                  else
                    Column(
                      children: [
                        _buildStatCard(
                          icon: Icons.people,
                          label: local.totalUsers,
                          value: _totalUsers.toString(),
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _buildStatCard(
                          icon: Icons.gps_fixed,
                          label: local.totalCrosshairs,
                          value: _totalCrosshairs.toString(),
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        _buildStatCard(
                          icon: Icons.favorite,
                          label: local.totalLikes,
                          value: _totalLikes.toString(),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _loadStats();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(local.statsUpdated),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                    label: Text(
                      local.refreshStats,
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
          ],
          
          Text(
            local.owner,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(local.name, local.nameOwner),
          _buildInfoRow(local.email, 'vuthanhlich729x@gmail.com'),
          _buildInfoRow(local.zalo, '0378487294'),
          
          const SizedBox(height: 24),
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),
          
          Text(
            local.donate,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Image.asset(
                    'assets/images/donate.jpg',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 250,
                        height: 250,
                        color: Colors.grey[800],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.qr_code_scanner,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              local.noImage,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  local.scanQR,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${local.accountNumber}0378487294',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${local.bank}MOMO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${local.accountHolder}Vũ Tiến Lộc (Vũ Thanh Lịch)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: '0378487294'));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(local.copiedAccount),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy, color: Colors.white, size: 18),
                  label: Text(
                    local.copyAccount,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),
          
          const Text(
            '🙏 Cảm ơn bạn đã sử dụng ứng dụng!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Mọi đóng góp ý kiến vui lòng liên hệ qua email.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 🎯 FORM CHIA SẺ TÂM NGẮM MỚI
// ============================================================
class AddCrosshairForm extends StatefulWidget {
  const AddCrosshairForm({super.key});

  @override
  State<AddCrosshairForm> createState() => _AddCrosshairFormState();
}

class _AddCrosshairFormState extends State<AddCrosshairForm> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _codeController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (pickedFile == null) return;

      try {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cắt ảnh tâm ngắm',
              toolbarColor: Colors.redAccent,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: false,
              showCropGrid: true,
              cropGridColor: Colors.white,
              cropFrameColor: Colors.redAccent,
              activeControlsWidgetColor: Colors.redAccent,
            ),
            IOSUiSettings(
              title: 'Cắt ảnh tâm ngắm',
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _imageFile = File(croppedFile.path);
          });
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã cắt ảnh thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (cropError) {
        if (!mounted) return;
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Không thể crop ảnh, vẫn sử dụng ảnh gốc: $cropError'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadData() async {
    final local = AppLocalizations.of(context)!;
    
    if (_nameController.text.trim().isEmpty || _codeController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(local.fillNameCode),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final existing = await Supabase.instance.client
          .from('crosshairs')
          .select()
          .eq('code', _codeController.text.trim())
          .maybeSingle();

      if (existing != null) {
        if (!mounted) return;
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(local.codeExists),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      String imageUrl = '';
      
      if (_imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.path.split('/').last}';
        
        await Supabase.instance.client.storage
            .from('crosshair-images')
            .upload(fileName, _imageFile!)
            .timeout(const Duration(seconds: 15));

        imageUrl = Supabase.instance.client.storage
            .from('crosshair-images')
            .getPublicUrl(fileName);
      }

      await Supabase.instance.client.from('crosshairs').insert({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'code': _codeController.text.trim(),
        'image_url': imageUrl,
        'likes': 0,
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(local.uploadSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      
      if (e.toString().contains('duplicate key') || e.toString().contains('23505')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(local.codeExists),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${local.uploadError}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              local.shareYourCrosshair,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${local.name} *',
                border: const OutlineInputBorder(),
                hintText: local.enterName,
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: local.description,
                border: const OutlineInputBorder(),
                hintText: local.enterDescription,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: local.crosshairCode,
                      border: const OutlineInputBorder(),
                      hintText: local.enterCode,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final code = _codeController.text.trim();
                    if (code.isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập mã code!')),
                      );
                      return;
                    }
                    
                    try {
                      final existing = await Supabase.instance.client
                          .from('crosshairs')
                          .select()
                          .eq('code', code)
                          .maybeSingle();
                      
                      if (!mounted) return;
                      if (existing != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(local.codeExists),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(local.codeAvailable),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      // Bỏ qua
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  child: Text(
                    local.check,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📸 ${local.image}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickAndCropImage,
                        icon: const Icon(Icons.crop, color: Colors.white),
                        label: Text(
                          local.selectCropImage,
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      if (_imageFile != null)
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              local.imageSelected,
                              style: const TextStyle(color: Colors.green, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                _imageFile!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          local.noImage,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  Text(
                    local.imageHint,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, 
                padding: const EdgeInsets.symmetric(vertical: 14)
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(
                        color: Colors.white, 
                        strokeWidth: 2
                      )
                    )
                  : Text(
                      local.upload,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold
                      )
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}