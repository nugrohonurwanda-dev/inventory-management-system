import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_3/config/api_config.dart';
import 'package:flutter_application_3/providers/category_provider.dart'
    show alertSuccess, alertFailed;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _passwordController = TextEditingController();

  String _username = '';
  int? _userId;
  String? _imageUrl; // URL gambar dari server
  File? _pickedImage; // file lokal sebelum diupload
  bool _isLoadingPassword = false;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // ── Load data dari SharedPreferences ────────────────────────────────────────
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('id');
      _username = prefs.getString('username') ?? '';
      _imageUrl = prefs.getString('image'); // null jika belum pernah upload
    });
  }

  // ── Update password ──────────────────────────────────────────────────────────
  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      alertFailed(context, 'Password baru tidak boleh kosong');
      return;
    }
    if (_userId == null) return;

    setState(() => _isLoadingPassword = true);
    try {
      final response = await Dio().patch(
        '${ApiConfig.baseUrl}/update-password/$_userId',
        data: {'password': password},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        _passwordController.clear();
        alertSuccess(context, 'Password berhasil diperbarui');
      } else {
        alertFailed(
            context, response.data['error'] ?? 'Gagal memperbarui password');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      alertFailed(context,
          e.response?.data?['error'] ?? 'Tidak dapat terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoadingPassword = false);
    }
  }

  // ── Pilih & upload foto profil ───────────────────────────────────────────────
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() {
      _pickedImage = File(picked.path);
      _isLoadingImage = true;
    });

    if (_userId == null) return;

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          picked.path,
          filename: picked.name,
        ),
      });
      final response = await Dio().patch(
        '${ApiConfig.baseUrl}/update-image/$_userId',
        data: formData,
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        // Simpan nama file ke SharedPreferences supaya persistent
        final prefs = await SharedPreferences.getInstance();
        final filename = response.data['data'] is List
            ? null
            : response.data['data']?['image'];
        if (filename != null) {
          await prefs.setString(
              'image', '${ApiConfig.baseUrl}/images/$filename');
          setState(() => _imageUrl = '${ApiConfig.baseUrl}/images/$filename');
        }
        // ignore: use_build_context_synchronously
        alertSuccess(context, 'Foto profil berhasil diperbarui');
      } else {
        alertFailed(context, 'Gagal mengunggah foto');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      alertFailed(context,
          e.response?.data?['error'] ?? 'Tidak dapat terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoadingImage = false);
    }
  }

  // ── Logout — hapus SharedPreferences, navigasi ke login ─────────────────────
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ── Avatar ──────────────────────────────────────────────────────
              GestureDetector(
                onTap: _isLoadingImage ? null : _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!) as ImageProvider
                          : (_imageUrl != null
                              ? NetworkImage(_imageUrl!)
                              : null),
                      child: (_pickedImage == null && _imageUrl == null)
                          ? Icon(Icons.person,
                              size: 50, color: Colors.grey[700])
                          : null,
                    ),
                    if (_isLoadingImage)
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.black26,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Username ─────────────────────────────────────────────────────
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(_username.isEmpty ? '-' : _username),
                subtitle: const Text('Username'),
              ),
              const SizedBox(height: 20),

              // ── Update password ───────────────────────────────────────────────
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoadingPassword ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: _isLoadingPassword
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Password'),
                ),
              ),
              const SizedBox(height: 30),

              // ── Logout ────────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: _logout,
                  child: const Text('Logout',
                      style: TextStyle(color: Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
