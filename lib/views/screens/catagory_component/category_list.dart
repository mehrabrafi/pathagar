import 'package:flutter/material.dart';

class CategoryListItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isTablet;
  final bool hasSubcategories;
  final bool isExpanded;

  const CategoryListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isTablet,
    this.hasSubcategories = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: isDark ? Colors.grey[900] : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? screenWidth * 0.04 : 24,
            vertical: isTablet ? 20 : 16,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 14 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isTablet ? 28 : 24,
                ),
              ),
              SizedBox(width: isTablet ? 24 : 20),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? screenWidth * 0.03 : null,
                  ),
                ),
              ),
              if (hasSubcategories)
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: isTablet ? 28 : 24,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                )
              else
                Icon(
                  Icons.chevron_right,
                  size: isTablet ? 28 : 24,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}