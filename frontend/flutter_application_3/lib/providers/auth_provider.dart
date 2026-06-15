import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_3/config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  final GlobalKey<FormState> formAuthentication = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  String messageError = '';

  void changeObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  // FIX #5: clearError dipanggil saat user buka halaman login/register
  void clearError() {
    messageError = '';
    notifyListeners();
  }

  Future<void> processAuth(BuildContext context, bool isLogin) async {
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      messageError = 'Username dan password wajib diisi';
      notifyListeners();
      return;
    }

    messageError = '';
    notifyListeners();

    try {
      final response = await Dio().post(
        '${ApiConfig.baseUrl}/${isLogin ? 'login' : 'register'}', // FIX #1: pakai ApiConfig
        data: {'username': username, 'password': password},
      );

      // FIX: guard context.mounted setelah async
      if (!context.mounted) return;

      if (isLogin) {
        _handleLoginResponse(context, response);
      } else {
        _handleRegisterResponse(context, response);
      }
    } on DioException catch (e) {
      messageError = e.response?.data?['error'] ??
          'Tidak dapat terhubung ke server.\nPastikan backend berjalan dan IP sudah benar.';
      notifyListeners();
    }
  }

  void _handleLoginResponse(BuildContext context, Response response) {
    if (response.statusCode == 200 &&
        response.data['message'] == 'Login success') {
      saveUserData(response.data['data']);
      // FIX #4: callback agar navigasi terjadi di luar dialog context
      _alertSuccess(context, 'Login berhasil!', onConfirm: () {
        _navigateToMainMenu(context);
      });
    } else {
      _alertFailure(context, response.data['message'] ?? 'Login gagal');
    }
  }

  // FIX #3: register kembali ke login, bukan langsung ke MainMenu
  void _handleRegisterResponse(BuildContext context, Response response) {
    if (response.statusCode == 201 &&
        response.data['message'] == 'User created successfully') {
      _alertSuccess(
        context,
        'Registrasi berhasil!\nSilakan login dengan akun baru kamu.',
        onConfirm: () => _navigateToLogin(context), // ← kembali ke login
      );
    } else {
      _alertFailure(context, response.data['message'] ?? 'Registrasi gagal');
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', userData['id']);
    await prefs.setString('username', userData['username']);
  }

  Future<void> processLogin(BuildContext context) => processAuth(context, true);

  Future<void> processRegister(BuildContext context) =>
      processAuth(context, false);

  // FIX #4: pakai onConfirm callback — navigasi dilakukan setelah dialog ditutup
  // menggunakan dialogContext.pop() dulu, LALU callback dengan outer context
  void _alertSuccess(BuildContext context, String message,
      {required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 50),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // tutup dialog dulu
                onConfirm(); // baru navigasi
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _alertFailure(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToMainMenu(BuildContext context) {
    usernameController.clear();
    passwordController.clear();
    // pushNamedAndRemoveUntil lebih clean dari popUntil + pushReplacement
    Navigator.of(context).pushNamedAndRemoveUntil('/main_menu', (_) => false);
  }

  void _navigateToLogin(BuildContext context) {
    usernameController.clear();
    passwordController.clear();
    messageError = '';
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }
}
