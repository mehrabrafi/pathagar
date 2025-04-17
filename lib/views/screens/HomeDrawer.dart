import 'package:flutter/material.dart';
import '../../Settings/settings.dart';
import '../../Download/DownloadedBooksPage.dart';
import 'HomePageUtils.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Drawer(
      width: 270,
      child: Column(
        children: [
          _buildGradientHeader(context),
          const SizedBox(height: 10),
          Expanded(
            child: _buildDrawerItems(context),
          ),
          _buildFooter(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildDrawerItems(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildDrawerItem(
          context,
          icon: Icons.info,
          title: 'About',
          onTap: () => _navigateAfterPop(context, () => HomePageUtils.showAboutDialog(context)),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.share,
          title: 'Share App',
          onTap: () => _navigateAfterPop(context, () => HomePageUtils.shareApp(context)),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.star_rate,
          title: 'Rate Us',
          onTap: () => _navigateAfterPop(context, () => HomePageUtils.rateApp(context)),
        ),
        // Add this new item for Active Downloads
        _buildDrawerItem(
          context,
          icon: Icons.download,
          title: 'Downloaded Books',
          onTap: () => _pushRouteAfterPop(context, const DownloadedBooksScreen()),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.settings,
          title: 'Settings',
          onTap: () => _pushRouteAfterPop(context, const SettingsPage()),
        ),
      ],
    );
  }
  }

  void _navigateAfterPop(BuildContext context, VoidCallback action) {
    Navigator.pop(context);
    action();
  }

  void _pushRouteAfterPop(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildGradientHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(50),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AppLogo(),
          SizedBox(height: 10),
          _AppTitle(),
          SizedBox(height: 4),
          _AppSubtitle(),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon, size: 24, color: isDarkMode ? Colors.white : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: theme.hoverColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          const Divider(),
          Text(
            'v1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '© 2025 পাঠাগার',
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png', // Replace with your actual asset path
          width: 45,
          height: 45,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'পাঠাগার',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

class _AppSubtitle extends StatelessWidget {
  const _AppSubtitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Explore Knowledge',
      style: TextStyle(fontSize: 14, color: Colors.white70),
    );
  }
}