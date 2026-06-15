import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_3/providers/product_provider.dart';
import 'package:flutter_application_3/models/product_model.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    // Fetch data setelah frame pertama selesai render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().getProducts(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Product Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<ProductProvider>().getProducts(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          switch (provider.productState) {
            case ProductState.loading:
              return const Center(child: CircularProgressIndicator());

            case ProductState.noData:
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Belum ada produk',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );

            case ProductState.error:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 12),
                    const Text('Gagal memuat data produk'),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      onPressed: () => provider.getProducts(context),
                    ),
                  ],
                ),
              );

            case ProductState.success:
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                itemCount: provider.listProduct.length,
                itemBuilder: (context, index) {
                  final product = provider.listProduct[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          '${product.qty ?? 0}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      title: Text(
                        product.name ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Kategori: ${product.category?.name ?? 'ID ${product.categoryId}'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.blue),
                            tooltip: 'Edit',
                            onPressed: () =>
                                _showProductDialog(context, product: product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            tooltip: 'Hapus',
                            onPressed: () =>
                                _showDeleteDialog(context, provider, product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  void _showProductDialog(BuildContext outerContext, {Data? product}) {
    final provider = outerContext.read<ProductProvider>();

    // Set data jika edit, clear jika tambah baru
    if (product != null) {
      provider.setEditData(product);
    } else {
      provider.clearForm();
    }

    showDialog(
      context: outerContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
        content: Form(
          key: provider.formProduct,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: provider.nameController,
                  decoration: const InputDecoration(labelText: 'Nama Produk *'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: provider.qtyController,
                  decoration: const InputDecoration(labelText: 'Qty *'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Qty wajib diisi';
                    if (int.tryParse(v) == null) return 'Harus berupa angka';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: provider.categoryIdController,
                  decoration: const InputDecoration(labelText: 'Category ID *'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Category ID wajib diisi';
                    }
                    if (int.tryParse(v) == null) return 'Harus berupa angka';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: provider.urlController,
                  decoration:
                      const InputDecoration(labelText: 'URL Gambar (opsional)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // tutup dialog dulu
              // Pakai outerContext — dialogContext sudah di-pop
              if (product == null) {
                provider.createProduct(outerContext);
              } else {
                provider.updateProduct(outerContext, product.id!);
              }
            },
            child: Text(product == null ? 'Tambah' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext outerContext, ProductProvider provider, Data product) {
    showDialog(
      context: outerContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              provider.deleteProduct(
                  outerContext, product.id!); // outer context
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
