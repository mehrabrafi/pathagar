import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pathagar/views/screens/search_components/search_empty_state.dart';
import 'package:pathagar/views/screens/search_components/search_results_grid.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'search_components/search_app_bar.dart';
import '../../controllers/book_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _isConnected = !result.contains(ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bookController = Provider.of<BookController>(context);

    if (!_isConnected) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 60,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 20),
              Text(
                'Search not available offline',
                style: TextStyle(
                  fontSize: 18,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkConnectivity,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: SearchAppBar(
        isDarkMode: isDarkMode,
        bookController: bookController,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SearchBody(
        isDarkMode: isDarkMode,
        bookController: bookController,
      ),
    );
  }
}

class SearchBody extends StatelessWidget {
  final bool isDarkMode;
  final BookController bookController;

  const SearchBody({
    required this.isDarkMode,
    required this.bookController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
      child: Consumer<BookController>(
        builder: (context, bookController, child) {
          if (bookController.searchController.text.isEmpty) {
            return SearchEmptyState(
              text: 'Start typing to search books',
              isDarkMode: isDarkMode,
            );
          }

          if (bookController.filteredBooks.isEmpty) {
            return SearchEmptyState(
              text: 'No books found',
              isDarkMode: isDarkMode,
            );
          }

          return SearchResultsGrid(
            books: bookController.filteredBooks,
            isDarkMode: isDarkMode,
          );
        },
      ),
    );
  }
}