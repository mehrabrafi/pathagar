import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/book_controller.dart';
import '../../widgets/bookmarkpage_book_card.dart';
import 'delete_dialog.dart';

class BookmarkGridView extends StatelessWidget {
  const BookmarkGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.02,
      ),
      child: Consumer<BookController>(
        builder: (context, bookController, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = screenWidth > 600
                  ? (screenWidth > 900 ? 5 : 4)
                  : 3;

              final mainAxisSpacing = screenHeight * 0.02;
              final crossAxisSpacing = screenWidth * 0.02;

              final horizontalPadding = screenWidth * 0.04;
              final itemWidth = (constraints.maxWidth -
                  ((crossAxisCount - 1) * crossAxisSpacing) -
                  (2 * horizontalPadding)) / crossAxisCount;
              final itemHeight = itemWidth * 1.8;
              final imageHeight = itemWidth * 1.4;

              return GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                  vertical: screenHeight * 0.02,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: bookController.bookmarkedBooks.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: itemWidth / itemHeight,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                ),
                itemBuilder: (context, index) {
                  final book = bookController.bookmarkedBooks[index];
                  return GestureDetector(
                    onLongPress: () => showDialog(
                      context: context,
                      builder: (context) => DeleteDialog(book: book),
                    ),
                    child: BookCard2(
                      book: book,
                      width: itemWidth,
                      imageHeight: imageHeight,
                      itemHeight: itemHeight,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}