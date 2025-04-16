import 'package:flutter/material.dart';

class SearchEmptyState extends StatelessWidget {
  final String text;
  final bool isDarkMode;

  const SearchEmptyState({
    required this.text,
    required this.isDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: isDarkMode
              ? Colors.white.withOpacity(0.6)
              : Colors.black.withOpacity(0.6),
          fontSize: 16,
        ),
      ),
    );
  }
}