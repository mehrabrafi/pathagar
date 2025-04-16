import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ThemeController/ThemeController.dart';
import '../widgets/settings_header.dart';
import '../widgets/theme_option.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsHeader(title: 'Appearance'),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
          child: Column(
            children: [
              ThemeOption(
                mode: AppThemeMode.light,
                icon: Icons.light_mode,
                title: 'Light Mode',
                subtitle: 'Bright and colorful interface',
              ),
              const Divider(height: 1, indent: 16),
              ThemeOption(
                mode: AppThemeMode.dark,
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Easier on the eyes in low light',
              ),
            ],
          ),
        ),
      ],
    );
  }
}