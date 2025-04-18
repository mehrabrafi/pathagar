import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/book_controller.dart';
import '../../models/book.dart';
import 'DownloadedPdfViewerPage.dart';
import 'dialog/delete_confirmation_dialog.dart';
import 'widgets/book_card_mobile.dart';
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
  late BookController _bookController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bookController = Provider.of<BookController>(context, listen: false);
      _bookController.loadDownloadedBooks();
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
    setState(() => _isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults.clear();
    });
  }

  void _performSearch(String query, List<Book> allBooks) {
    if (query.isEmpty) {
      setState(() => _searchResults.clear());
    } else {
      final queryLower = query.toLowerCase();
      setState(() {
        _searchResults = allBooks.where((book) {
          return book.title.toLowerCase().contains(queryLower) ||
              book.author.toLowerCase().contains(queryLower) ||
              book.category.toLowerCase().contains(queryLower);
        }).toList();
      });
    }
  }

  Future<void> _deleteSelectedBooks() async {
    final shouldDelete = await showDeleteConfirmationDialog(
      context,
      _selectedBooks.length,
    );

    if (shouldDelete == true) {
      for (final bookId in _selectedBooks) {
        await _bookController.removeDownloadedBook(bookId);
      }
      _clearSelection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted ${_selectedBooks.length} book(s)')),
      );
    }
  }

  void _openPdfViewer(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadedPdfViewerScreen(filePath: filePath),
      ),
    );
  }

  Future<void> _handleBookDelete(Book book) async {
    await _bookController.removeDownloadedBook(book.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${book.title}" removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _bookController.downloadBook(book),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching
          ? SearchAppBar(
        controller: _searchController,
        onChanged: (query) => _performSearch(query, _bookController.downloadedBooks),
        onClose: _stopSearch,
      )
          : SelectionAppBar(
        isSelectionMode: _isSelectionMode,
        selectedCount: _selectedBooks.length,
        onSelectAll: () => _selectAllBooks(_bookController.downloadedBooks),
        onDelete: _deleteSelectedBooks,
        onClear: _clearSelection,
        onSearch: _startSearch,
      ),
      body: Consumer<BookController>(
        builder: (context, bookController, child) {
          final booksToDisplay = _isSearching ? _searchResults : bookController.downloadedBooks;

          if (booksToDisplay.isEmpty) {
            return EmptyState(isSearching: _isSearching);
          }

          return RefreshIndicator(
            onRefresh: () => bookController.loadDownloadedBooks(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: booksToDisplay.length,
              itemBuilder: (context, index) {
                final book = booksToDisplay[index];
                return BookCardMobile(
                  key: ValueKey(book.id),
                  book: book,
                  isSelected: _selectedBooks.contains(book.id),
                  isSelectionMode: _isSelectionMode,
                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleSelection(book.id);
                    } else if (book.localPath != null) {
                      _openPdfViewer(book.localPath!);
                    }
                  },
                  onLongPress: () => _toggleSelection(book.id),
                  onDelete: () => _handleBookDelete(book),
                );
              },
            ),
          );
        },
      ),
    );
  }
}