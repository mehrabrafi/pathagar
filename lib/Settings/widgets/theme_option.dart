import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ThemeController/ThemeController.dart';

class ThemeOption extends StatelessWidget {
  final AppThemeMode mode;
  final IconData icon;
  final String title;
  final String subtitle;

  const ThemeOption({
    super.key,
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Provider.of<ThemeController>(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: 12,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
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
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: isTablet ? 14 : 12,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
      trailing: Radio<AppThemeMode>(
        value: mode,
        groupValue: themeController.themeMode,
        onChanged: (value) {
          if (value != null) themeController.updateThemeMode(value);
        },
        activeColor: theme.colorScheme.primary,
      ),
      onTap: () => themeController.updateThemeMode(mode),
    );
  }
}