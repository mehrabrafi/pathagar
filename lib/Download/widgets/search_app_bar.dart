import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;
  final bool isTablet;

  const SearchAppBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClose,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      title: TextField(
        controller: controller,
        autofocus: true,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: isTablet ? 18 : 16,
        ),
        decoration: InputDecoration(
          hintText: 'Search downloaded books...',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.black54,
            fontSize: isTablet ? 18 : 16,
          ),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.close, size: isTablet ? 32 : 24),
          onPressed: () {
            if (controller.text.isEmpty) {
              onClose();
            } else {
              controller.clear();
              onChanged('');
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}