import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_3/providers/category_provider.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // BUG #4: controller terpisah khusus untuk form create di halaman utama
  final TextEditingController _createController = TextEditingController();
  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().getCategory(context);
    });
  }

  @override
  void dispose() {
    _createController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Category Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Form create — pakai _createController & _createFormKey sendiri
            Form(
              key: _createFormKey,
              child: TextFormField(
                controller: _createController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _handleCreate(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
            ),
            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (context, provider, _) {
                  switch (provider.categoryState) {
                    case CategoryState.loading:
                      return const Center(child: CircularProgressIndicator());
                    case CategoryState.noData:
                      return const Center(child: Text('No categories found'));
                    case CategoryState.error:
                      return const Center(
                          child: Text('Error loading categories'));
                    case CategoryState.success:
                      return ListView.builder(
                        itemCount: provider.listCategory.length,
                        itemBuilder: (context, index) {
                          final category = provider.listCategory[index];
                          return ListTile(
                            title: Text(category.name ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showUpdateDialog(
                                      context,
                                      provider,
                                      category.id!,
                                      category.name ?? ''),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => provider.deleteCategory(
                                      context, category.id!),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pakai _createController untuk create, bukan provider.nameController
  Future<void> _handleCreate(BuildContext context) async {
    if (!(_createFormKey.currentState?.validate() ?? false)) return;
    final provider = context.read<CategoryProvider>();
    await provider.createCategoryWithName(
        context, _createController.text.trim());
    _createController.clear();
  }

  void _showUpdateDialog(BuildContext context, CategoryProvider provider,
      int categoryId, String currentName) {
    // Controller terpisah khusus untuk dialog edit
    final editController = TextEditingController(text: currentName);
    final editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Category'),
        content: Form(
          key: editFormKey,
          child: TextFormField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
            ),
            autofocus: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a category name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (editFormKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop();
                provider.updateCategoryWithName(
                    context, categoryId, editController.text.trim());
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    ).then((_) => editController.dispose());
  }
}
