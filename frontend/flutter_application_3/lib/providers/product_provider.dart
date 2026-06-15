import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_3/models/product_model.dart';
import 'package:flutter_application_3/config/api_config.dart';
// Import alertSuccess/alertFailed dari category_provider agar tidak duplikat kode
import 'package:flutter_application_3/providers/category_provider.dart'
    show alertSuccess, alertFailed;

enum ProductState { initial, loading, success, error, noData }

class ProductProvider extends ChangeNotifier {
  final formProduct = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  // GAP #3: pakai selectedCategoryId, bukan text controller
  int? selectedCategoryId;

  ProductState _productState = ProductState.initial;
  List<Data> _listProduct = [];
  int? _userId;

  ProductState get productState => _productState;
  List<Data> get listProduct => _listProduct;

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('id');
  }

  Future<void> getProducts(BuildContext context) async {
    await _loadUserId();
    if (_userId == null) {
      _setState(ProductState.error);
      return;
    }
    try {
      _setState(ProductState.loading);
      final response =
          await Dio().get('${ApiConfig.baseUrl}/products/$_userId');
      final result = ProductModel.fromJson(response.data);
      _listProduct = result.data ?? [];
      _setState(
          _listProduct.isEmpty ? ProductState.noData : ProductState.success);
    } on DioException catch (e) {
      _setState(ProductState.error);
      if (context.mounted) {
        alertFailed(context, 'Error: ${e.message ?? 'Terjadi kesalahan'}');
      }
    }
  }

  Future<void> createProduct(BuildContext context) async {
    await _loadUserId();
    if (_userId == null) return;

    if (!_validateForm()) {
      // ignore: use_build_context_synchronously
      _showAlertFieldEmpty(context);
      return;
    }

    try {
      final requestBody = {
        'name': nameController.text.trim(),
        'qty': int.tryParse(qtyController.text) ?? 0,
        'categoryId': selectedCategoryId,
        if (urlController.text.trim().isNotEmpty)
          'url': urlController.text.trim(),
      };
      final response = await Dio().post(
        '${ApiConfig.baseUrl}/products/$_userId',
        data: requestBody,
      );

      if (!context.mounted) return;

      if (response.statusCode == 201) {
        alertSuccess(context, 'Produk berhasil ditambahkan');
        clearForm();
        await getProducts(context);
      } else {
        alertFailed(
            context, response.data['error'] ?? 'Gagal menambahkan produk');
      }
    } on DioException catch (e) {
      if (context.mounted) {
        alertFailed(context, 'Error: ${e.message ?? 'Terjadi kesalahan'}');
      }
    }
  }

  Future<void> updateProduct(BuildContext context, int id) async {
    if (!_validateForm()) {
      _showAlertFieldEmpty(context);
      return;
    }

    try {
      final requestBody = {
        'name': nameController.text.trim(),
        'qty': int.tryParse(qtyController.text) ?? 0,
        'categoryId': selectedCategoryId,
        if (urlController.text.trim().isNotEmpty)
          'url': urlController.text.trim(),
      };
      final response = await Dio().patch(
        '${ApiConfig.baseUrl}/products/$id',
        data: requestBody,
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        alertSuccess(context, 'Produk berhasil diperbarui');
        clearForm();
        await getProducts(context);
      } else {
        alertFailed(
            context, response.data['error'] ?? 'Gagal memperbarui produk');
      }
    } on DioException catch (e) {
      if (context.mounted) {
        alertFailed(context, 'Error: ${e.message ?? 'Terjadi kesalahan'}');
      }
    }
  }

  Future<void> deleteProduct(BuildContext context, int id) async {
    try {
      final response = await Dio().delete('${ApiConfig.baseUrl}/products/$id');

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        alertSuccess(context, 'Produk berhasil dihapus');
        await getProducts(context);
      } else {
        alertFailed(
            context, response.data['message'] ?? 'Gagal menghapus produk');
      }
    } on DioException catch (e) {
      if (context.mounted) {
        alertFailed(context, 'Error: ${e.message ?? 'Terjadi kesalahan'}');
      }
    }
  }

  void setEditData(Data product) {
    nameController.text = product.name ?? '';
    qtyController.text = product.qty?.toString() ?? '';
    selectedCategoryId = product.categoryId;
    urlController.text = product.url ?? '';
    notifyListeners();
  }

  void clearForm() {
    nameController.clear();
    qtyController.clear();
    selectedCategoryId = null;
    urlController.clear();
    notifyListeners();
  }

  void _setState(ProductState state) {
    _productState = state;
    notifyListeners();
  }

  bool _validateForm() => formProduct.currentState?.validate() ?? false;

  void _showAlertFieldEmpty(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 50),
            SizedBox(height: 8),
            Text('Harap isi semua field yang wajib',
                textAlign: TextAlign.center),
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
