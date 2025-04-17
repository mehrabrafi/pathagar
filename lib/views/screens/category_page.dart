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
    {
      'title': 'All',
      'icon': Icons.all_inclusive,
      'color': Colors.blueGrey,
      'subcategories': []
    },
    {
      'title': 'Class 11-12',
      'icon': Icons.menu_book,
      'color': Colors.orange,
      'subcategories': [
        {'title': 'Science', 'color': Colors.orange.shade300},
        {'title': 'Commerce', 'color': Colors.orange.shade400},
        {'title': 'Arts', 'color': Colors.orange.shade500},
      ]
    },
    {
      'title': 'Class 9-10',
      'icon': Icons.menu_book,
      'color': Colors.green,
      'subcategories': [
        {'title': 'Science', 'color': Colors.green.shade300},
        {'title': 'General', 'color': Colors.green.shade400},
      ]
    },
    {
      'title': 'Class 1',
      'icon': Icons.menu_book,
      'color': Colors.purple,
      'subcategories': [
        {'title': 'Bangla', 'color': Colors.purple.shade300},
        {'title': 'English', 'color': Colors.purple.shade400},
        {'title': 'Math', 'color': Colors.purple.shade500},
      ]
    },
    {
      'title': 'ইবতেদায়ী Class 1',
      'icon': Icons.menu_book,
      'color': Colors.blue,
      'subcategories': []
    },
    {
      'title': 'Literature',
      'icon': Icons.menu_book,
      'color': Colors.brown,
      'subcategories': [
        {'title': 'Poetry', 'color': Colors.brown.shade300},
        {'title': 'Novels', 'color': Colors.brown.shade400},
        {'title': 'Short Stories', 'color': Colors.brown.shade500},
      ]
    },
    {
      'title': 'Technology',
      'icon': Icons.menu_book,
      'color': Colors.indigo,
      'subcategories': [
        {'title': 'Programming', 'color': Colors.indigo.shade300},
        {'title': 'Networking', 'color': Colors.indigo.shade400},
        {'title': 'Database', 'color': Colors.indigo.shade500},
      ]
    },
    {
      'title': 'Arts',
      'icon': Icons.menu_book,
      'color': Colors.pink,
      'subcategories': []
    },
    {
      'title': 'Business',
      'icon': Icons.menu_book,
      'color': Colors.teal,
      'subcategories': []
    },
  ];

  List<Map<String, dynamic>> _filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchField = false;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Map<String, dynamic>? _expandedCategory;

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

  void _toggleCategoryExpansion(Map<String, dynamic> category) {
    setState(() {
      if (_expandedCategory == category) {
        _expandedCategory = null;
      } else {
        _expandedCategory = category;
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
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final category = _filteredCategories[index];
                    final hasSubcategories = (category['subcategories'] as List).isNotEmpty;

                    return Column(
                      children: [
                        CategoryListItem(
                          title: category['title'],
                          icon: category['icon'],
                          color: category['color'],
                          onTap: () {
                            if (hasSubcategories) {
                              _toggleCategoryExpansion(category);
                            } else {
                              Provider.of<BookController>(context, listen: false)
                                  .filterBooksByCategory(category['title']);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryBooksPage(category: category['title']),
                                ),
                              );
                            }
                          },
                          isTablet: isTablet,
                          hasSubcategories: hasSubcategories,
                          isExpanded: _expandedCategory == category,
                        ),
                        if (_expandedCategory == category && hasSubcategories)
                          ..._buildSubcategories(category, context, isTablet),
                      ],
                    );
                  },
                  childCount: _filteredCategories.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSubcategories(
      Map<String, dynamic> category,
      BuildContext context,
      bool isTablet
      ) {
    return (category['subcategories'] as List).map<Widget>((subcategory) {
      return Padding(
        padding: EdgeInsets.only(
          left: isTablet ? 80.0 : 60.0,
          right: isTablet ? 20.0 : 16.0,
        ),
        child: Material(
          color: Theme.of(context).cardColor,
          child: InkWell(
            onTap: () {
              final fullCategoryName = '${category['title']} - ${subcategory['title']}';
              Provider.of<BookController>(context, listen: false)
                  .filterBooksByCategory(fullCategoryName);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryBooksPage(category: fullCategoryName),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24.0 : 16.0,
                vertical: isTablet ? 18.0 : 14.0,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: subcategory['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: isTablet ? 24 : 16),
                  Expanded(
                    child: Text(
                      subcategory['title'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: isTablet ? 28 : 24,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}