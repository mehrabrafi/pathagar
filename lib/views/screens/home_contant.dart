import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../controllers/book_controller.dart';
import '../../models/book.dart';
import '../widgets/homepage_book_card.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;
  late Timer _rotationTimer;
  List<Book> _displayedBooks = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startRotationTimer();
    _initConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _startRotationTimer() {
    // Rotate books every 30 seconds
    _rotationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _rotateBooks();
        });
      }
    });
  }

  void _rotateBooks() {
    final books = context.read<BookController>().books;
    if (books.isEmpty) return;

    // Create a new shuffled list while keeping some books in similar positions
    final newDisplayOrder = List<Book>.from(_displayedBooks.isNotEmpty ? _displayedBooks : books);

    // Perform a partial shuffle - swap 3 random pairs
    for (var i = 0; i < 3; i++) {
      final index1 = _random.nextInt(newDisplayOrder.length);
      final index2 = _random.nextInt(newDisplayOrder.length);
      if (index1 != index2) {
        final temp = newDisplayOrder[index1];
        newDisplayOrder[index1] = newDisplayOrder[index2];
        newDisplayOrder[index2] = temp;
      }
    }

    setState(() {
      _displayedBooks = newDisplayOrder;
    });
  }

  @override
  void dispose() {
    _rotationTimer.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (mounted) {
      setState(() {
        _isConnected = !result.contains(ConnectivityResult.none);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth >= 600;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    if (!_isConnected) {
      return _buildNoInternetContent(context);
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isTablet, isPortrait, screenWidth),
          Expanded(child: _buildBookGrid()),
        ],
      ),
    );
  }

  Widget _buildNoInternetContent(BuildContext context) {
    return Center(
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
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet, bool isPortrait, double screenWidth) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isTablet ? screenWidth * 0.05 : screenWidth * 0.04,
          isTablet ? 20 : 12,
          isTablet ? screenWidth * 0.05 : screenWidth * 0.04,
          isTablet ? 16 : 8,
        ),
        child: Text(
          'All Books',
          style: TextStyle(
            fontSize: isTablet
                ? (isPortrait ? screenWidth * 0.04 : screenWidth * 0.035)
                : (isPortrait ? screenWidth * 0.045 : screenWidth * 0.03),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
    );
  }

  Widget _buildBookGrid() {
    final books = context.watch<BookController>().books;

    // Initialize if empty
    if (_displayedBooks.isEmpty && books.isNotEmpty) {
      _displayedBooks = List.from(books)..shuffle(_random);
    }

    if (_displayedBooks.isEmpty) {
      return Center(
        child: Text(
          'No books available',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth >= 600;
        final isPortrait = constraints.maxHeight > constraints.maxWidth;
        final horizontalPadding = isTablet ? screenWidth * 0.05 : screenWidth * 0.04;
        final crossAxisCount = _getCrossAxisCount(screenWidth, isPortrait, isTablet);
        final spacing = isTablet ? screenWidth * 0.04 : screenWidth * 0.03;
        final availableWidth = screenWidth - (2 * horizontalPadding) - ((crossAxisCount - 1) * spacing);
        final itemWidth = availableWidth / crossAxisCount;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Padding(
            key: ValueKey(_displayedBooks.hashCode),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _displayedBooks.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: isTablet
                    ? (isPortrait ? 0.55 : 0.65)
                    : (isPortrait ? 0.52 : 0.7),
                mainAxisSpacing: isTablet
                    ? (isPortrait ? screenWidth * 0.06 : screenWidth * 0.04)
                    : (isPortrait ? screenWidth * 0.08 : screenWidth * 0.05),
                crossAxisSpacing: spacing,
              ),
              itemBuilder: (context, index) {
                final book = _displayedBooks[index];
                return _buildBookCard(context, book, isTablet, isPortrait, itemWidth);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, bool isTablet, bool isPortrait, double itemWidth) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BookCard(
      key: ValueKey(book.id),
      book: book,
      width: itemWidth,
      imageHeight: isTablet
          ? (isPortrait ? itemWidth * 1.5 : itemWidth * 1.3)
          : (isPortrait ? itemWidth * 1.4 : itemWidth * 1.2),
      isDarkMode: isDarkMode,
      backgroundColor: isDarkMode ? theme.colorScheme.surface : Colors.white,
      textColor: isDarkMode ? theme.colorScheme.onSurface : Colors.black,
    );
  }

  int _getCrossAxisCount(double screenWidth, bool isPortrait, bool isTablet) {
    if (isTablet) {
      if (screenWidth < 900) return isPortrait ? 4 : 6;
      if (screenWidth < 1200) return isPortrait ? 5 : 7;
      return isPortrait ? 6 : 8;
    }
    return 3;
  }
}