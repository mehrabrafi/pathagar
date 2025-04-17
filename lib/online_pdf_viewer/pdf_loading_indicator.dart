import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PdfLoadingIndicator extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  final double downloadProgress;
  final bool isPreCached;

  const PdfLoadingIndicator({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.downloadProgress,
    required this.isPreCached,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.library_books,
                size: 48,
                color:Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 32),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.blueAccent,
                  highlightColor: Colors.blueAccent,
                  child: Text(
                    'Loading Book',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (downloadProgress > 0)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: downloadProgress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Text(
                        '${(value * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:Colors.blueAccent,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (downloadProgress > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 12,
                  child: LinearProgressIndicator(
                    value: downloadProgress,
                    backgroundColor:Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    minHeight: 12,
                  ),
                ),
              ),
            ),
          if (isPreCached)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:Colors.blueAccent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download_done,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Loaded from cache',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}