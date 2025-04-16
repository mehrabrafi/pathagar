import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../controllers/book_controller.dart';
import '../../models/book.dart';
import '../screens/book_detail_page.dart';

class BookCard2 extends StatelessWidget {
  final Book book;
  final double width;
  final double imageHeight;
  final double itemHeight;

  const BookCard2({
    super.key,
    required this.book,
    required this.width,
    required this.imageHeight,
    required this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final placeholderColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
    final bookController = Provider.of<BookController>(context);

    return GestureDetector(
      onTap: () {
        if (bookController.isOneByOneDeletionMode) {
          _showDeleteConfirmation(context, book);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookDetailPage(book: book)),
          );
        }
      },
      child: SizedBox(
        width: width,
        height: itemHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: placeholderColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: book.imageUrl,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.broken_image,
                        size: 24,
                        color: Colors.grey,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (bookController.isOneByOneDeletionMode)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Bookmark'),
        content: Text('Remove "${book.title}" from bookmarks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<BookController>(context, listen: false)
                  .toggleBookmark(book);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed ${book.title}'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      Provider.of<BookController>(context, listen: false)
                          .toggleBookmark(book);
                    },
                  ),
                ),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}