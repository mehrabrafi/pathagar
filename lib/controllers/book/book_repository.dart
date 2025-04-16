import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/book.dart';

class BookRepository with ChangeNotifier {
  final List<Book> _books = [];
  List<Book> _filteredBooks = [];
  List<Book> _bookmarkedBooks = [];
  List<Book> _downloadedBooks = [];
  List<Book> _searchResults = [];
  final TextEditingController searchController = TextEditingController();
  final Uuid _uuid = Uuid();
  static const String _bookmarkedBooksKey = 'bookmarked_books';

  List<Book> get books => List.unmodifiable(_books);
  List<Book> get filteredBooks => List.unmodifiable(_filteredBooks);
  List<Book> get bookmarkedBooks => List.unmodifiable(_bookmarkedBooks);
  List<Book> get downloadedBooks => List.unmodifiable(_downloadedBooks);
  List<Book> get searchResults => List.unmodifiable(_searchResults);

  Future<void> loadInitialData() async {
    _books.addAll([
      Book(
        id: _uuid.v4(),
        title: 'হিসাববিজ্ঞান প্রথম পত্র',
        author: 'ক্যামব্রিজ পাবলিকেশন',
        category: 'Class 11-12',
        imageUrl: 'https://i.postimg.cc/DZyg1xhg/b1.png',
        date: '14/08/202',
        pdfUrl: 'https://drive.google.com/uc?export=download&id=1GFN5aXHmAq0-db-5L6Z8SyFo5K0b7KFw',
      ),
      Book(
        id: _uuid.v4(),
        title: 'ICT',
        author: 'NCTB',
        category: 'Class 9-10',
        imageUrl: 'https://i.postimg.cc/nzR12qct/b2.png',
        date: '10/05/2022',
        pdfUrl: 'https://drive.google.com/uc?export=download&id=1zvCB8X7yjR3k4yW8spM-FjAvfTzQ5MjK',
      ),
      Book(
          id: _uuid.v4(),
          title: 'বাংলা সাহিত্য',
          author: 'NCTB',
          category: 'Class 9-10',
          imageUrl: 'https://i.postimg.cc/7hjn8D2s/b3.png',
          date: '22/03/2022',
          pdfUrl: 'https://drive.google.com/uc?export=download&id=1dOQAVB6usKCoZ7_4HXYvPq7Eb16ihi1z'
      ),
      Book(
        id: _uuid.v4(),
        title: 'English For Today',
        author: 'NCTB',
        category: 'Class 1',
        imageUrl: 'https://i.postimg.cc/x8X34qcN/b4.png',
        date: '05/01/2022',
        pdfUrl: 'https://drive.google.com/uc?export=download&id=1vLgwbT2DOz8NoVgdZHoSpWvHzYpPPZ-n',
      ),
      Book(
        id: _uuid.v4(),
        title: 'ব্যবসায় উদ্যোগ',
        author: 'NCTB',
        category: 'Class 9-10',
        imageUrl: 'https://i.postimg.cc/ryHJtGP1/b5.png',
        date: '15/07/2022',
        pdfUrl: 'https://drive.google.com/uc?export=download&id=1dOrs-tzelAox1gZzQ9gcOg3yWlOCETbT',
      ),
      Book(
        id: _uuid.v4(),
        title: 'আমার বাংলা বই',
        author: 'NCTB',
        category: 'Class 1',
        imageUrl: 'https://i.postimg.cc/cLRMjp4h/b6.png',
        date: '30/04/2022',
        pdfUrl: 'https://drive.google.com/uc?export=download&id=1MTbykaBdc1bTfeqNN5_W0RzPNlG_EVak',
      ),
      Book(
        id: _uuid.v4(),
        title: ' গণিত',
        author: 'NCTB',
        category: 'Class 1',
        imageUrl: 'https://i.postimg.cc/nhbG3FZM/b7.png',
        date: '12/09/2021',
        pdfUrl: 'https://drive.google.com/uc?export=download&id=1UZ0x1s4AGar08nVm9ui71cERwv_MB1rk',
      ),
      Book(
        id: _uuid.v4(),
        title: 'আদ্যরসুল আরাবিয়া',
        author: 'BMEB',
        category: 'ইবতেদায়ী Class 1',
        imageUrl: 'https://i.postimg.cc/4Nh1vKDr/b8.png',
        date: '20/11/2021',
        pdfUrl: 'https://drive.google.com/uc?export=download&id=1Vll8p6RZUF9kWOnrG0ZDeU9rPvjevHqK',
      ),
      Book(
        id: _uuid.v4(),
        title: 'কুরআন মাজীদ ও তাজবীদ',
        author: 'BMEB',
        category: 'ইবতেদায়ী Class 1',
        imageUrl: 'https://i.postimg.cc/vmGLd04s/b9.png',
        date: '20/11/2021',
        pdfUrl: 'https://drive.google.com/uc?export=download&id=1RSC_CPs2n5T3L0CPb4YhCOnAgFT3c7Mn',
      ),
    ]);

    _filteredBooks = List.from(_books);
    await _loadBookmarkedBooks();
  }

  // Method to add a new book with auto-generated ID
  void addNewBook(Book book) {
    final newBook = Book(
      id: _uuid.v4(),
      title: book.title,
      author: book.author,
      category: book.category,
      imageUrl: book.imageUrl,
      date: book.date,
      pdfUrl: book.pdfUrl,
    );

    _books.add(newBook);
    _filteredBooks = List.from(_books);
    notifyListeners();
  }

  Future<void> _loadBookmarkedBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedBooksJson = prefs.getStringList(_bookmarkedBooksKey);

      if (bookmarkedBooksJson != null) {
        _bookmarkedBooks = bookmarkedBooksJson.map((json) {
          final bookMap = jsonDecode(json);
          return Book.fromMap(bookMap);
        }).toList();
      }
    } catch (e) {
      throw Exception('Error loading bookmarked books: $e');
    }
  }

  Future<void> _saveBookmarkedBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedBooksJson = _bookmarkedBooks.map((book) {
        return jsonEncode(book.toMap());
      }).toList();

      await prefs.setStringList(_bookmarkedBooksKey, bookmarkedBooksJson);
    } catch (e) {
      throw Exception('Error saving bookmarked books: $e');
    }
  }

  Future<void> addDownloadedBook(Book book) async {
    if (!_downloadedBooks.any((b) => b.id == book.id)) {
      _downloadedBooks.add(book);
      notifyListeners();
    }
  }

  bool isBookDownloaded(Book book) => _downloadedBooks.any((b) => b.id == book.id);
  bool isBookmarked(Book book) => _bookmarkedBooks.any((b) => b.id == book.id);

  Future<void> toggleBookmark(Book book) async {
    if (isBookmarked(book)) {
      _bookmarkedBooks.removeWhere((b) => b.id == book.id);
    } else {
      _bookmarkedBooks.add(book);
    }
    await _saveBookmarkedBooks();
    notifyListeners();
  }

  void filterBooksByCategory(String category) {
    if (category == 'All') {
      _filteredBooks = List.from(_books);
    } else {
      _filteredBooks = _books.where((book) => book.category == category).toList();
    }
    notifyListeners();
  }

  void searchBooks(String query) {
    if (query.isEmpty) {
      _filteredBooks = List.from(_books);
    } else {
      final lowerCaseQuery = query.toLowerCase();
      _filteredBooks = _books.where((book) =>
      book.title.toLowerCase().contains(lowerCaseQuery) ||
          book.author.toLowerCase().contains(lowerCaseQuery) ||
          book.category.toLowerCase().contains(lowerCaseQuery)
      ).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _filteredBooks = List.from(_books);
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}