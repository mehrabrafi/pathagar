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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      children: [

        // Drawer items with animations
        _buildDrawerItem(
          context,
          icon: Icons.info_outline_rounded,
          title: 'About',
          iconColor: Colors.blueAccent,
          onTap: () => _navigateAfterPop(context, () => HomePageUtils.showAboutDialog(context)),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.share_rounded,
          title: 'Share App',
          iconColor: Colors.green,
          onTap: () => _navigateAfterPop(context, () => HomePageUtils.shareApp(context)),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.star_rate_rounded,
          title: 'Rate Us',
          iconColor: Colors.amber,
          onTap: () => _navigateAfterPop(context, () => HomePageUtils.rateApp(context)),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.download_rounded,
          title: 'Downloaded Books',
          iconColor: Colors.purpleAccent,
          onTap: () => _pushRouteAfterPop(context, const DownloadedBooksScreen()),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.settings_rounded,
          title: 'Settings',
          iconColor: colorScheme.primary,
          onTap: () => _pushRouteAfterPop(context, const SettingsPage()),
        ),

      ],
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        Color? iconColor,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          splashColor: colorScheme.primary.withOpacity(0.2),
          highlightColor: colorScheme.primary.withOpacity(0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }  }

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
      'জ্ঞান এখন সবার হাতের মুঠোয়',
      style: TextStyle(fontSize: 14, color: Colors.white70),
    );
  }
}