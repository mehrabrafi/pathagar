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
    if (!_isConnected) {
      return _buildNoInternetContent(context);
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Text(
          'All Books',
          style: TextStyle(
            fontSize: 20,
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
        final screenHeight = constraints.maxHeight;
        final isPortrait = screenHeight > screenWidth;

        // Calculate cross axis count based on screen width
        final crossAxisCount = screenWidth < 400 ? 2 : 3;

        // Calculate spacing and padding as percentages of screen width
        final horizontalPadding = screenWidth * 0.04; // 4% of screen width
        final spacing = screenWidth * 0.03; // 3% of screen width

        // Calculate available width and item dimensions
        final availableWidth = screenWidth - (2 * horizontalPadding) - ((crossAxisCount - 1) * spacing);
        final itemWidth = availableWidth / crossAxisCount;

        // Calculate aspect ratio based on screen size and orientation
        final aspectRatio = isPortrait
            ? (screenHeight < 700 ? 0.6 : 0.55) // Taller screens get slightly squarer cards
            : 0.7; // Landscape always uses 0.7

        // Calculate image height as a percentage of item width
        final imageHeight = itemWidth * (isPortrait ? 1.5 : 1.3);

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
                childAspectRatio: aspectRatio,
                mainAxisSpacing: isPortrait ? screenHeight * 0.03 : screenHeight * 0.02,
                crossAxisSpacing: spacing,
              ),
              itemBuilder: (context, index) {
                final book = _displayedBooks[index];
                return _buildBookCard(
                  context,
                  book,
                  itemWidth,
                  imageHeight,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookCard(
      BuildContext context,
      Book book,
      double width,
      double imageHeight,
      ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return BookCard(
      key: ValueKey(book.id),
      book: book,
      width: width,
      imageHeight: imageHeight,
      isDarkMode: isDarkMode,
      backgroundColor: isDarkMode ? theme.colorScheme.surface : Colors.white,
      textColor: isDarkMode ? theme.colorScheme.onSurface : Colors.black,
    );
  }
}