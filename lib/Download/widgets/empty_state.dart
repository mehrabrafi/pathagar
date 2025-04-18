import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final bool isSearching;

  const EmptyState({
    super.key,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No results found' : 'No downloaded books yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching ? 'Try a different search term' : 'Books you download will appear here',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}