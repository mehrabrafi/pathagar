import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Function(Map<String, dynamic>) onCategoryTap;
  final bool isTablet;

  const CategoryList({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final category = categories[index];
          return CategoryListItem(
            title: category['title'],
            icon: category['icon'],
            color: category['color'],
            onTap: () => onCategoryTap(category),
            isTablet: isTablet,
          );
        },
        childCount: categories.length,
      ),
    );
  }
}

class CategoryListItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isTablet;

  const CategoryListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isTablet,
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