import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/book_controller.dart';
import '../../models/book.dart';
import 'DownloadedPdfViewerPage.dart';
import 'dialog/delete_confirmation_dialog.dart';
import 'widgets/book_card_mobile.dart';
import 'widgets/book_card_tablet.dart';
import 'widgets/empty_state.dart';
import 'widgets/search_app_bar.dart';
import 'widgets/selection_app_bar.dart';

class DownloadedBooksScreen extends StatefulWidget {
  const DownloadedBooksScreen({super.key});

  @override
  State<DownloadedBooksScreen> createState() => _DownloadedBooksScreenState();
}

class _DownloadedBooksScreenState extends State<DownloadedBooksScreen> {
  final Set<String> _selectedBooks = {};
  bool _isSelectionMode = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Book> _searchResults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookController>(context, listen: false).loadDownloadedBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String bookId) {
    setState(() {
      if (_selectedBooks.contains(bookId)) {
        _selectedBooks.remove(bookId);
      } else {
        _selectedBooks.add(bookId);
      }
      _isSelectionMode = _selectedBooks.isNotEmpty;
    });
  }

  void _selectAllBooks(List<Book> books) {
    setState(() {
      if (_selectedBooks.length == books.length) {
        _selectedBooks.clear();
      } else {
        _selectedBooks.addAll(books.map((book) => book.id));
      }
      _isSelectionMode = _selectedBooks.isNotEmpty;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedBooks.clear();
      _isSelectionMode = false;
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults.clear();
    });
  }

  void _performSearch(String query, List<Book> allBooks) {
    setState(() {
      if (query.isEmpty) {
        _searchResults.clear();
      } else {
        _searchResults = allBooks.where((book) {
          return book.title.toLowerCase().contains(query.toLowerCase()) ||
              book.author.toLowerCase().contains(query.toLowerCase()) ||
              book.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _deleteSelectedBooks(BuildContext context) async {
    final bookController = Provider.of<BookController>(context, listen: false);
    final shouldDelete = await showDeleteConfirmationDialog(
      context,
      _selectedBooks.length,
    );

    if (shouldDelete == true) {
      for (final bookId in _selectedBooks) {
        await bookController.removeDownloadedBook(bookId);
      }
      _clearSelection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted ${_selectedBooks.length} book(s)'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      appBar: _isSearching
          ? SearchAppBar(
        controller: _searchController,
        onChanged: (query) {
          final bookController = Provider.of<BookController>(context, listen: false);
          _performSearch(query, bookController.downloadedBooks);
        },
        onClose: _stopSearch,
        isTablet: isTablet,
      )
          : SelectionAppBar(
        isSelectionMode: _isSelectionMode,
        selectedCount: _selectedBooks.length,
        onSelectAll: () {
          final bookController = Provider.of<BookController>(context, listen: false);
          _selectAllBooks(bookController.downloadedBooks);
        },
        onDelete: () => _deleteSelectedBooks(context),
        onClear: _clearSelection,
        onSearch: _startSearch,
        isTablet: isTablet,
      ),
      body: Consumer<BookController>(
        builder: (context, bookController, child) {
          final booksToDisplay = _isSearching ? _searchResults : bookController.downloadedBooks;

          if (booksToDisplay.isEmpty) {
            return EmptyState(
              isSearching: _isSearching,
              isTablet: isTablet,
            );
          }

          return RefreshIndicator(
            onRefresh: () => bookController.loadDownloadedBooks(),
            child: isTablet
                ? _buildTabletGrid(booksToDisplay, context)
                : _buildMobileList(booksToDisplay, context),
          );
        },
      ),
    );
  }

  Widget _buildMobileList(List<Book> books, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCardMobile(
          book: book,
          isSelected: _selectedBooks.contains(book.id),
          isSelectionMode: _isSelectionMode,
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(book.id);
            } else if (book.localPath != null) {
              _openPdfViewer(context, book.localPath!);
            }
          },
          onLongPress: () => _toggleSelection(book.id),
          onDelete: () async {
            await Provider.of<BookController>(context, listen: false)
                .removeDownloadedBook(book.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${book.title}" removed'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    Provider.of<BookController>(context, listen: false)
                        .downloadBook(book);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabletGrid(List<Book> books, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 900 ? 4 : 3;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCardTablet(
          book: book,
          isSelected: _selectedBooks.contains(book.id),
          isSelectionMode: _isSelectionMode,
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(book.id);
            } else if (book.localPath != null) {
              _openPdfViewer(context, book.localPath!);
            }
          },
          onLongPress: () => _toggleSelection(book.id),
        );
      },
    );
  }

  void _openPdfViewer(BuildContext context, String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadedPdfViewerScreen(filePath: filePath),
      ),
    );
  }
}