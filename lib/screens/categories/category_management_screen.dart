import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends State<CategoryManagementScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  final List<String> _defaultCategories = const [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Education',
    'Entertainment',
    'Other',
  ];

  Future<void> _showCategoryDialog({
    String? existingCategory,
  }) async {
    final categoryName = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryNameDialog(
        existingCategory: existingCategory,
        defaultCategories: _defaultCategories,
      ),
    );

    if (categoryName == null || !mounted) {
      return;
    }

    try {
      if (existingCategory == null) {
        await _firebaseService.addCategory(categoryName);
      } else {
        if (existingCategory == categoryName) {
          return;
        }

        await _firebaseService.updateCategory(
          existingCategory,
          categoryName,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingCategory == null
                ? 'Category added.'
                : 'Category renamed.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save category: $error',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteCategory(String category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete category?'),
          content: Text(
            'Remove "$category" from your custom categories? '
            'Existing expenses will not be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _firebaseService.deleteCategory(category);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category deleted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete category: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: StreamBuilder<List<String>>(
        stream: _firebaseService.getCustomCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load categories.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final customCategories = snapshot.data ?? const <String>[];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Default categories',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'These built-in categories are always available.',
              ),
              const SizedBox(height: 12),
              ..._defaultCategories.map(
                (category) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.label_outline),
                    title: Text(category),
                    trailing: const Icon(
                      Icons.lock_outline,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'My custom categories',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: FilledButton.icon(
                      onPressed: () => _showCategoryDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Custom categories are saved to your account.',
              ),
              const SizedBox(height: 12),
              if (customCategories.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No custom categories yet. Tap Add to create one.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...customCategories.map(
                  (category) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.label_important_outline),
                      title: Text(category),
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Category actions',
                        onSelected: (action) {
                          if (action == 'rename') {
                            _showCategoryDialog(
                              existingCategory: category,
                            );
                          } else if (action == 'delete') {
                            _deleteCategory(category);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'rename',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Rename'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_outline),
                              title: Text('Delete'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog({
    required this.defaultCategories,
    this.existingCategory,
  });

  final String? existingCategory;
  final List<String> defaultCategories;

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.existingCategory ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRenaming = widget.existingCategory != null;

    return AlertDialog(
      title: Text(isRenaming ? 'Rename Category' : 'Add Category'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(
            labelText: 'Category name',
            hintText: 'e.g. Pets, Travel',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            final name = value?.trim() ?? '';

            if (name.isEmpty) {
              return 'Enter a category name.';
            }

            if (name.length > 30) {
              return 'Use 30 characters or fewer.';
            }

            if (widget.defaultCategories.any(
              (category) => category.toLowerCase() == name.toLowerCase(),
            )) {
              return 'That name is already a default category.';
            }

            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isRenaming ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

