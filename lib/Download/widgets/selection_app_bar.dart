import 'package:flutter/material.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback onSearch;

  const SelectionAppBar({
    super.key,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDelete,
    required this.onClear,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: isSelectionMode
          ? Text('$selectedCount selected')
          : const Text(
        'Downloaded Books',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: isSelectionMode
          ? isDarkMode
          ? Colors.grey[800]
          : Colors.grey[700]
          : Colors.blueAccent,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (isSelectionMode) ...[
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: onSelectAll,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClear,
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearch,
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}