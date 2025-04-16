import 'package:flutter/material.dart';

class BookDescription extends StatelessWidget {
  final String description;
  final bool isTablet;

  const BookDescription({
    super.key,
    required this.description,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? screenWidth * 0.03 : screenWidth * 0.04),
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? screenWidth * 0.03 : screenWidth * 0.04,
        vertical: isTablet ? screenHeight * 0.015 : screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor,
          width: isTablet ? 0.8 : 1.0,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 10 : 12),
        color: theme.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: theme.iconTheme.color,
                size: isTablet ? 22 : 20,
              ),
              SizedBox(width: isTablet ? 10 : 8),
              Flexible(
                child: Text(
                  "Book Description",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: isTablet ? screenWidth * 0.03 : screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 10 : 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              fontSize: isTablet ? screenWidth * 0.032 : screenWidth * 0.038,
              height: isTablet ? 1.5 : 1.4,
            ),
          ),
        ],
      ),
    );
  }
}