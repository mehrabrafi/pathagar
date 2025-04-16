import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/book_controller.dart';
import '../widgets/bookmarkpage_book_card.dart';
import 'search_page.dart';

class CategoryBooksPage extends StatelessWidget {
  final String category;

  const CategoryBooksPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          category,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // This makes back arrow white
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Consumer<BookController>(
          builder: (context, bookController, child) {
            if (bookController.filteredBooks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No books in $category',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later or explore other categories',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = 14.0;
                final itemWidth = (constraints.maxWidth - (2 * horizontalPadding) - 20) / 3;
                final itemHeight = itemWidth * 1.8;
                final imageHeight = itemWidth * 1.4;

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: bookController.filteredBooks.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: itemWidth / itemHeight,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final book = bookController.filteredBooks[index];
                    return BookCard2(
                      book: book,
                      width: itemWidth,
                      imageHeight: imageHeight,
                      itemHeight: itemHeight,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}