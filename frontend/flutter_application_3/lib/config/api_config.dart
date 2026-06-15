class ApiConfig {
  /// Ganti sesuai environment yang kamu pakai:
  ///
  /// Android Emulator (AVD)  → 'http://10.0.2.2:3000'
  /// Genymotion              → 'http://10.0.3.2:3000'
  /// Device fisik (LAN)      → 'http://192.168.1.xxx:3000'  ← IP laptop kamu
  /// iOS Simulator           → 'http://localhost:3000'
  static const String baseUrl = 'http://192.168.110.71:3000';
}
