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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().getCategory(context);
    });
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
            Form(
              key: context.read<CategoryProvider>().formCategory,
              child: Consumer<CategoryProvider>(
                builder: (context, provider, _) => TextFormField(
                  controller: provider.nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => provider.createCategory(context),
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
                                      context, provider, category.id!),
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

  void _showUpdateDialog(
      BuildContext context, CategoryProvider provider, int categoryId) {
    provider.detailCategory(context, categoryId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Category'),
        content: TextFormField(
          controller: provider.nameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a category name';
            }
            return null;
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (provider.formCategory.currentState?.validate() ?? false) {
                provider.updateCategory(context, categoryId);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
