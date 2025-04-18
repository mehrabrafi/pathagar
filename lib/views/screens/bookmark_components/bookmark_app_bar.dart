import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/book_controller.dart';
import '../search_page.dart';
import 'delete_all_dialog.dart';

class BookmarkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BookmarkAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<BookController>(
      builder: (context, bookController, child) {
        return AppBar(
          backgroundColor: Colors.blueAccent,
          title: bookController.isOneByOneDeletionMode
              ? const Text(
            'Tap to delete',
            style: TextStyle(color: Colors.white),
          )
              : const Text(
            'Bookmarks',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: bookController.isOneByOneDeletionMode
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => bookController.disableOneByOneDeletionMode(),
          )
              : null,
          actions: [
            if (!bookController.isOneByOneDeletionMode) ...[
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  SlidePageRoute(page: const SearchPage()),
                ),
              ),
              if (bookController.bookmarkedBooks.isNotEmpty)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: colorScheme.surface,
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.2),
                  surfaceTintColor: colorScheme.primary.withOpacity(0.1),
                  onSelected: (value) {
                    if (value == 'delete_all') {
                      showDialog(
                        context: context,
                        builder: (context) => const DeleteAllDialog(),
                      );
                    } else if (value == 'delete_one_by_one') {
                      bookController.enableOneByOneDeletionMode();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'delete_all',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_forever,
                              color: colorScheme.error,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Delete All',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'delete_one_by_one',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: colorScheme.onSurface.withOpacity(0.8),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Delete One by One',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
            ],
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
  );
}