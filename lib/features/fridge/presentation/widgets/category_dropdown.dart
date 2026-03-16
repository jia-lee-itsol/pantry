import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/category_provider.dart';

class CategoryDropdown extends ConsumerWidget {
  final String? selectedCategory;
  final void Function(String?) onChanged;

  const CategoryDropdown({
    super.key,
    this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        return DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          decoration: const InputDecoration(
            labelText: 'カテゴリ',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('選択しない')),
            ...categories.map(
              (category) => DropdownMenuItem<String>(
                value: category.name,
                child: Text(category.name),
              ),
            ),
          ],
          onChanged: onChanged,
        );
      },
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'カテゴリ',
          border: OutlineInputBorder(),
        ),
        child: SizedBox(
          height: 24,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (error, stack) => DropdownButtonFormField<String>(
        initialValue: null,
        decoration: const InputDecoration(
          labelText: 'カテゴリ',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem<String>(value: null, child: Text('読み込み失敗')),
        ],
        onChanged: null,
      ),
    );
  }
}
