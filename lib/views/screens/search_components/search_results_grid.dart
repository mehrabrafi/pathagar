import 'package:flutter/material.dart';
import '../../../models/book.dart';
import '../../widgets/homepage_book_card.dart';

class SearchResultsGrid extends StatelessWidget {
  final List<Book> books;
  final bool isDarkMode;

  const SearchResultsGrid({
    required this.books,
    required this.isDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.45
        ,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return BookCard(
          book: books[index],
          width: 150, // Fixed width for grid items
          imageHeight: 150, // Fixed height for images
          isDarkMode: isDarkMode,
          backgroundColor: isDarkMode
              ? colorScheme.surface
              : colorScheme.background,
          textColor: isDarkMode
              ? colorScheme.onSurface
              : colorScheme.onBackground,
        );
      },
    );
  }
}