import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/book_controller.dart';
import '../../../models/book.dart';

class DeleteDialog extends StatelessWidget {
  final Book book;

  const DeleteDialog({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

      title: Row(
        children: [
          Icon(Icons.bookmark_remove_rounded, color: Colors.redAccent, size: screenWidth * 0.06),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Remove Bookmark',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.grey[800],
            ),
            children: [
              const TextSpan(text: 'Are you sure you want to remove '),
              TextSpan(
                text: '"${book.title}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' from your bookmarks?'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () {
            Provider.of<BookController>(context, listen: false).toggleBookmark(book);
            Navigator.pop(context);
          },
          child: Text(
            'Remove',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
