import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final bool isSearching;
  final bool isTablet;

  const EmptyState({
    super.key,
    required this.isSearching,
    required this.isTablet,
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
            size: isTablet ? 64 : 48,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No results found' : 'No downloaded books yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: isTablet ? 22 : 16,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching ? 'Try a different search term' : 'Books you download will appear here',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}