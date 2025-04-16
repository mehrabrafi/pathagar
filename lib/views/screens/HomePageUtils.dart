import 'package:flutter/material.dart';

class HomePageUtils {
  static void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Book Haven'),
        content: const Text(
          'My Ebook is your personal library app where you can discover and read thousands of books. '
              'Version 1.0.0\n\n'
              'Developed by Mehrab Al Rafi',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void shareApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  static void rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rate us functionality coming soon!')),
    );
  }

  static void openSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings page coming soon!')),
    );
  }

  static void exitApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Future.delayed(Duration.zero, () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              });
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}