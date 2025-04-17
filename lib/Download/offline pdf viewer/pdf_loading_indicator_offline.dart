import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:shimmer/shimmer.dart';

class PdfLoadingIndicator extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Animation<double> loadingAnimation;

  const PdfLoadingIndicator({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.loadingAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: loadingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: loadingAnimation.value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.library_books,
                size: 48,
                color: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: colorScheme.primary.withOpacity(0.3),
            highlightColor: colorScheme.primary.withOpacity(0.1),
            child: Text(
              'Loading Book',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}