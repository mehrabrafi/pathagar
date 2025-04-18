import 'package:flutter/material.dart';
import 'sections/appearance_section.dart';
import 'sections/storage_section.dart';
import 'sections/about_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      appBar:AppBar(
      backgroundColor: Colors.blueAccent,
      iconTheme: const IconThemeData(color: Colors.white), // 👈 back arrow color
      title: Text(
        'Settings',
        style: TextStyle(
          fontSize: isTablet ? 24 : 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? screenWidth * 0.1 : 16,
          vertical: 16,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isTablet
              ? _buildTabletLayout(context)
              : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        AppearanceSection(),
        SizedBox(height: 24),
        StorageSection(),
        SizedBox(height: 24),
        AboutSection(),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return _buildMobileLayout(context); // Optional: customize separately if needed
  }
}
