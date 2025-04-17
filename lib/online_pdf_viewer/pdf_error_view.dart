import 'package:flutter/material.dart';

class PdfErrorView extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  final VoidCallback onRetry;

  const PdfErrorView({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load PDF',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.onErrorContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}