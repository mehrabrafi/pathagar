import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../controllers/book_controller.dart';
import 'catagory_component/category_app_bar.dart';
import 'catagory_component/category_list.dart';
import 'category_books_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<Map<String, dynamic>> _allCategories = [
    {'title': 'All', 'icon': Icons.all_inclusive, 'color': Colors.blueGrey},
    {'title': 'Class 11-12', 'icon': Icons.menu_book, 'color': Colors.orange},
    {'title': 'Class 9-10', 'icon': Icons.menu_book, 'color': Colors.green},
    {'title': 'Class 1', 'icon': Icons.menu_book, 'color': Colors.purple},
    {'title': 'ইবতেদায়ী Class 1', 'icon': Icons.menu_book, 'color': Colors.blue},
    {'title': 'Literature', 'icon': Icons.menu_book, 'color': Colors.brown},
    {'title': 'Technology', 'icon': Icons.menu_book, 'color': Colors.indigo},
    {'title': 'Arts', 'icon': Icons.menu_book, 'color': Colors.pink},
    {'title': 'Business', 'icon': Icons.menu_book, 'color': Colors.teal},
  ];

  List<Map<String, dynamic>> _filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchField = false;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _filteredCategories = List.from(_allCategories);
    _searchController.addListener(_filterCategories);
    _initConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _isConnected = !result.contains(ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories.where((category) {
        return category['title'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _showSearchField = !_showSearchField;
      if (_showSearchField) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _filterCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CategoryAppBar(
            showSearchField: _showSearchField,
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
            onToggleSearch: _toggleSearch,
            isTablet: isTablet,
          ),
          if (!_isConnected)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 60,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Content not available offline',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _initConnectivity,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (isTablet && isLandscape)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? screenWidth * 0.05 : 0,
                vertical: isTablet ? 8.0 : 0,
              ),
              sliver: CategoryList(
                categories: _filteredCategories,
                onCategoryTap: (category) {
                  Provider.of<BookController>(context, listen: false)
                      .filterBooksByCategory(category['title']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryBooksPage(category: category['title']),
                    ),
                  );
                },
                isTablet: isTablet,
              ),
            ),
          ],
        ],
      ),
    );
  }
}