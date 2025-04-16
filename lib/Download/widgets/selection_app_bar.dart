import 'package:flutter/material.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback onSearch;
  final bool isTablet;

  const SelectionAppBar({
    super.key,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDelete,
    required this.onClear,
    required this.onSearch,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: isSelectionMode
          ? Text('$selectedCount selected')
          : Text(
        'Downloaded Books',
        style: TextStyle(fontSize: isTablet ? 24 : 20, color: Colors.white),
      ),
      backgroundColor: isSelectionMode
          ? isDarkMode ? Colors.grey[800] : Colors.grey[700]
          : Colors.blueAccent,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (isSelectionMode) ...[
          IconButton(
            icon: Icon(Icons.select_all, size: isTablet ? 32 : 24),
            onPressed: onSelectAll,
          ),
          IconButton(
            icon: Icon(Icons.delete, size: isTablet ? 32 : 24),
            onPressed: onDelete,
          ),
          IconButton(
            icon: Icon(Icons.close, size: isTablet ? 32 : 24),
            onPressed: onClear,
          ),
        ] else ...[
          IconButton(
            icon: Icon(Icons.search, size: isTablet ? 32 : 24),
            onPressed: onSearch,
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}