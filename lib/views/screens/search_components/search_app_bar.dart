import 'package:flutter/material.dart';
import '../../../controllers/book_controller.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final BookController bookController;
  final VoidCallback onBackPressed;

  const SearchAppBar({
    super.key,
    required this.isDarkMode,
    required this.bookController,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blueAccent,
      elevation: 1,
      automaticallyImplyLeading: false,
      title: TextField(
        controller: bookController.searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search by title or author...',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.white,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: bookController.searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            onPressed: bookController.clearSearch,
          )
              : null,
        ),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        cursorColor: isDarkMode ? Colors.white : Colors.white,
        onChanged: (query) => bookController.searchBooks(query),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDarkMode ? Colors.white : Colors.white,
        ),
        onPressed: onBackPressed,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}