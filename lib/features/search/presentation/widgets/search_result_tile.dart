import 'package:flutter/material.dart';

import '../../../../core/design/spacing.dart';
import '../../domain/entities/search_result.dart';

class SearchResultTile extends StatelessWidget {
  final SearchResult result;

  const SearchResultTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _buildLeadingIcon(context),
        title: Text(result.name),
        subtitle: _buildSubtitle(context),
        trailing: _buildTrailing(context),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    final color = result.source == SearchResultSource.fridge
        ? Colors.blue
        : Colors.orange;
    final icon = result.source == SearchResultSource.fridge
        ? Icons.kitchen
        : Icons.inventory_2;

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.2),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final parts = <String>[];

    parts.add(result.sourceLabel);

    if (result.category != null) {
      parts.add(result.category!);
    }

    if (result.expiryDate != null) {
      final formatted =
          '${result.expiryDate!.year}/${result.expiryDate!.month}/${result.expiryDate!.day}';
      parts.add('期限: $formatted');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(parts.join(' • ')),
        const SizedBox(height: 2),
        Row(
          children: [
            if (result.isExpired)
              _buildStatusChip(context, '期限切れ', Colors.red)
            else if (result.isNearExpiry)
              _buildStatusChip(context, '期限間近', Colors.orange),
            if (result.isLowStock)
              _buildStatusChip(context, '在庫不足', Colors.amber),
            if (result.isFrozen == true)
              _buildStatusChip(context, '冷凍', Colors.cyan),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${result.quantity}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          '個',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
