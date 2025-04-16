import 'package:flutter/material.dart';

class CategoryAppBar extends StatefulWidget {
  final bool showSearchField;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isTablet;
  final VoidCallback onToggleSearch;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;

  const CategoryAppBar({
    super.key,
    required this.showSearchField,
    required this.searchController,
    required this.searchFocusNode,
    required this.isTablet,
    required this.onToggleSearch,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  State<CategoryAppBar> createState() => _CategoryAppBarState();
}

class _CategoryAppBarState extends State<CategoryAppBar> {
  @override
  void dispose() {
    widget.searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.isTablet ? 26.0 : 22.0;
    final appBarHeight = widget.isTablet ? 80.0 : 64.0;

    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: Colors.blueAccent,
      elevation: 0.3,
      expandedHeight: appBarHeight,
      collapsedHeight: appBarHeight - (widget.isTablet ? 16.0 : 8.0),

      // Don’t reserve space for leading when search field is shown
      leading: null,

      // Full-width title with search or heading
      title: widget.showSearchField ? _buildFullSearchField(iconSize) : _buildTitle(),

      actions: widget.showSearchField ? [] : [_buildSearchButton(iconSize)],

      centerTitle: true,
      titleSpacing: 0,
    );
  }

  // Title widget when search is not active
  Widget _buildTitle() {
    return Text(
      'Categories',
      style: TextStyle(
        color: Colors.white,
        fontSize: widget.isTablet ? 24.0 : 20.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  // Search field widget when active
  Widget _buildFullSearchField(double iconSize) {
    return Container(
      height: kToolbarHeight * 0.9,
      margin: EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        autofocus: true,
        controller: widget.searchController,
        focusNode: widget.searchFocusNode,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search categories...',
          prefixIcon: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
            onPressed: widget.onToggleSearch,
            splashRadius: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: Colors.grey[700]),
            onPressed: () {
              widget.searchController.clear();
              widget.onSearchChanged?.call('');
            },
            splashRadius: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          isDense: true,
        ),
        style: TextStyle(
          fontSize: widget.isTablet ? 16.0 : 14.0,
          color: Colors.black87,
        ),
        onChanged: widget.onSearchChanged,
        onSubmitted: (_) => widget.onSearchSubmitted?.call(),
      ),
    );
  }

  // Search button in the app bar when search is not active
  Widget _buildSearchButton(double iconSize) {
    return IconButton(
      icon: Icon(Icons.search, size: iconSize),
      color: Colors.white,
      onPressed: widget.onToggleSearch,
      splashRadius: 24,
    );
  }
}
