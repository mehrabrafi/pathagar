import 'package:flutter/material.dart';
import '../widgets/settings_header.dart';
import '../widgets/about_list_item.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsHeader(title: 'About'),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
          child: Column(
            children: [
              AboutListItem(
                icon: Icons.info,
                color: Colors.blue,
                title: 'About App',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  // Navigate to about page
                },
              ),
              const Divider(height: 1, indent: 16),
              AboutListItem(
                icon: Icons.star,
                color: Colors.amber,
                title: 'Rate App',
                subtitle: 'Share your feedback',
                onTap: () {
                  // Rate app functionality
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}