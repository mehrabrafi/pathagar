import 'package:flutter/material.dart';

class StorageListItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? trailing;

  const StorageListItem({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: isTablet ? 28 : 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitleWidget ?? (subtitle != null
          ? Text(
        subtitle!,
        style: TextStyle(
          fontSize: isTablet ? 14 : 12,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      )
          : null),
      trailing: trailing,
    );
  }
}