import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/category_model.dart';
import 'package:flutter_application_3/config/api_config.dart'; // FIX #1

// Fungsi top-level ini juga dipakai oleh product_provider
void alertSuccess(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
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
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void alertFailed(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
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
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

enum CategoryState { initial, loading, success, error, noData }

class CategoryProvider extends ChangeNotifier {
  final String baseUrl = ApiConfig.baseUrl; // FIX #1: tidak hardcoded lagi

  final formCategory = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  CategoryState _categoryState = CategoryState.initial;
  List<Data> _listCategory = [];

  CategoryState get categoryState => _categoryState;
  List<Data> get listCategory => _listCategory;

  Future<void> getCategories(BuildContext context) async {
    try {
      _setState(CategoryState.loading);
      final response = await Dio().get('$baseUrl/categories');
      final result = CategoryModel.fromJson(response.data);
      _listCategory = result.data ?? [];
      _setState(
          _listCategory.isEmpty ? CategoryState.noData : CategoryState.success);
    } on DioException catch (e) {
      _setState(CategoryState.error);
      if (context.mounted) {
        alertFailed(context, 'Error: ${e.message ?? 'Terjadi kesalahan'}');
      }
    }
  }

  Future<void> createCategory(BuildContext context) async {
    if (!_validateForm()) {
      _showAlertFieldEmpty(context);
      return;
    }
    try {
      final response = await Dio().post(
        '$baseUrl/categories',
        data: {'name': nameController.text.trim()},
      );
      if (!context.mounted) return;
      if (response.statusCode == 201 && response.data['message'] == 'Success') {
        alertSuccess(context, 'Kategori berhasil ditambahkan');
        nameController.clear();
        await getCategories(context);
      } else {
        alertFailed(
            context, response.data['error'] ?? 'Gagal menambahkan kategori');
      }
    } on DioException catch (e) {
      if (context.mounted) {
        alertFailed(context, 'Error: ${e.message ?? 'Terjadi kesalahan'}');
      }
    }
  }

  Future<void> updateCategory(BuildContext context, int id) async {
    if (!_validateForm()) {
      _showAlertFieldEmpty(context);
      return;
    }
    try {
      final response = await Dio().patch(
        '$baseUrl/categories/$id',
        data: {'name': nameController.text.trim()},
      );
      if (!context.mounted) return;
      if (response.statusCode == 200 && response.data['message'] == 'Success') {
        alertSuccess(context, 'Kategori berhasil diperbarui');
        nameController.clear();
        await getCategories(context);
      } else {
        alertFailed(
            context, response.data['error'] ?? 'Gagal memperbarui kategori');
      }
    } on DioException catch (e) {
      if (context.mounted) {
        alertFailed(context, 'Error: ${e.message ?? 'Terjadi kesalahan'}');
      }
    }
  }

  Future<void> deleteCategory(BuildContext context, int id) async {
    try {
      final response = await Dio().delete('$baseUrl/categories/$id');
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        alertSuccess(context, 'Kategori berhasil dihapus');
        await getCategories(context);
      } else {
        alertFailed(
            context, response.data['message'] ?? 'Gagal menghapus kategori');
      }
    } on DioException catch (e) {
      if (context.mounted) {
        alertFailed(context, 'Error: ${e.message ?? 'Terjadi kesalahan'}');
      }
    }
  }

  void setEditData(Data category) {
    nameController.text = category.name ?? '';
  }

  // ─── Backward-compat aliases (dipanggil dari category_page.dart) ────────────

  /// Alias untuk getCategories — category_page.dart masih pakai nama ini.
  Future<void> getCategory(BuildContext context) => getCategories(context);

  /// Pre-fill nameController dari data yang sudah ada di _listCategory,
  /// sehingga form edit langsung terisi tanpa perlu round-trip ke backend.
  void detailCategory(BuildContext context, int id) {
    final category = _listCategory.firstWhere(
      (c) => c.id == id,
      orElse: () => Data(),
    );
    setEditData(category);
  }

  // ─── Internal helpers ─────────────────────────────────────────────────────

  void _setState(CategoryState state) {
    _categoryState = state;
    notifyListeners();
  }

  bool _validateForm() => formCategory.currentState?.validate() ?? false;

  void _showAlertFieldEmpty(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 50),
            SizedBox(height: 8),
            Text('Harap isi semua field', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
