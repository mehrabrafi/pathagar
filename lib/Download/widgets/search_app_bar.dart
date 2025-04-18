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
    return AppBar(
      backgroundColor: Colors.blueAccent,
      iconTheme: const IconThemeData(color: Colors.white), // Back arrow icon color
      title: TextField(
        controller: controller,
        autofocus: true,
        cursorColor: Colors.white, // Cursor color
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 18 : 16,
        ),
        decoration: InputDecoration(
          hintText: 'Search downloaded books...',
          hintStyle: TextStyle(
            color: Colors.white70,
            fontSize: isTablet ? 18 : 16,
          ),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.close, size: isTablet ? 32 : 24, color: Colors.white),
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
