import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book.dart';

class BookCardMobile extends StatelessWidget {
  final Book book;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Future<void> Function() onDelete;

  const BookCardMobile({
    super.key,
    required this.book,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(book.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (isSelectionMode) return false;
        try {
          await onDelete();
          return true; // Return true to confirm dismissal
        } catch (e) {
          return false; // Return false to cancel dismissal
        }
      },
      onDismissed: (direction) => onDelete(),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: isSelected
            ? isDarkMode
            ? Colors.blue[900]
            : Colors.blue[50]
            : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap(),
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (isDarkMode) return Colors.blue[200]!;
                        return Colors.blue;
                      },
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: book.imageUrl,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 80,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: const Icon(Icons.book, size: 30),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 80,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(
                        Icons.broken_image,
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected && isDarkMode ? Colors.white : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected && isDarkMode
                              ? Colors.white.withOpacity(0.8)
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (book.fileSize != null)
                        Text(
                          book.fileSize!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected && isDarkMode
                                ? Colors.white.withOpacity(0.6)
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isSelectionMode)
                  Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'Downloaded',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.green),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}