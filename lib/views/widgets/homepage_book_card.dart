import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book.dart';
import '../screens/book_detail_page.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final double width;
  final double imageHeight;
  final bool isDarkMode;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;
  final bool showDownloadBadge;

  const BookCard({
    super.key,
    required this.book,
    required this.width,
    required this.imageHeight,
    required this.isDarkMode,
    required this.backgroundColor,
    required this.textColor,
    this.onTap,
    this.showDownloadBadge = false,
  });

  String _getShortTitle(String fullTitle) {
    final words = fullTitle.split(' ');
    if (words.length <= 2) return fullTitle;
    return '${words.take(2).join(' ')}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final placeholderColor = isDarkMode
        ? colorScheme.secondaryContainer
        : colorScheme.primaryContainer;

    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookDetailPage(book: book)),
        );
      },
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover image with download badge
            Stack(
              children: [
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: backgroundColor,
                    boxShadow: isDarkMode
                        ? null
                        : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: book.imageUrl,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: colorScheme.secondary,
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 24,
                          color: placeholderColor,
                        ),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (showDownloadBadge && book.localPath != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.download_done,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            // Title only (author is kept in Book model but not displayed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _getShortTitle(book.title),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}