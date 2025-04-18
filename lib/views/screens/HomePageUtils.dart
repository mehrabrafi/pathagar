import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePageUtils {
  static void showAboutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'About',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            title: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color:Colors.white,
                  size: 28, // Larger icon for better visibility
                ),
                const SizedBox(width: 12),
                Text(
                  'About Book Haven',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Slightly larger font size for the title
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Ebook is your personal library app where you can discover and read thousands of books.',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16, // A more readable font size for content
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Bold and larger version number
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Developed by Mehrab Al Rafi',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14, // Slightly smaller font for developer name
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.blueAccent, // Adds a background color to the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // More padding for a better click area
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, // Bold text on the button
                  ),
                ),
              ),
            ],
          )
          ,
        );
      },
    );
  }

  static void shareApp(BuildContext context) {
    HapticFeedback.lightImpact();
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
      content: Row(
        children: [
          Icon(Icons.share_rounded, color: Theme.of(context).colorScheme.onPrimary),
          const SizedBox(width: 12),
          const Expanded(child: Text('Share functionality coming soon!')),
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void rateApp(BuildContext context) {
    HapticFeedback.lightImpact();
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
      content: Row(
        children: [
          Icon(Icons.star_rate_rounded, color: Colors.amber[300]),
          const SizedBox(width: 12),
          const Expanded(child: Text('Rate us functionality coming soon!')),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void exitApp(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Exit',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              title: Row(
                children: [
                  Icon(Icons.exit_to_app_rounded,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 12),
                  Text(
                    'Exit App',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Are you sure you want to exit?',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.pop(context);
                    SystemNavigator.pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Exit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}