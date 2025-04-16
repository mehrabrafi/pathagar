import 'package:flutter/material.dart';
import '../../controllers/book_controller.dart';

Future<void> showClearAllDownloadsDialog(
    BuildContext context,
    BookController bookController,
    bool isTablet,
    ) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        titlePadding: EdgeInsets.all(isTablet ? 24 : 16),
        contentPadding: EdgeInsets.fromLTRB(
          isTablet ? 24 : 16,
          12,
          isTablet ? 24 : 16,
          16,
        ),
        actionsPadding: EdgeInsets.all(isTablet ? 16 : 8),
        title: Text(
          'Clear All Downloads',
          style: TextStyle(fontSize: isTablet ? 22 : 18),
        ),
        content: Text(
          'Are you sure you want to delete all downloaded books? This action cannot be undone.',
          style: TextStyle(fontSize: isTablet ? 16 : 14),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.red,
              ),
            ),
            onPressed: () async {
              await bookController.clearAllDownloads();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}