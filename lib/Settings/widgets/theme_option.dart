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
    final isDarkMode = theme.brightness == Brightness.dark;

    // Set icon color based on theme mode
    final iconColor = mode == AppThemeMode.light
        ? Colors.amber // Amber for light mode
        : isDarkMode
        ? Colors.white // White for dark theme
        : Colors.white; // Black for light theme

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: 12,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor, // Use the determined icon color
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
        activeColor:Colors.blueAccent,
      ),
      onTap: () => themeController.updateThemeMode(mode),
    );
  }
}