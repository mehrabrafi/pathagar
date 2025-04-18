import 'package:flutter/material.dart';
import '../models/book.dart';
import 'book/book_download_service.dart';
import 'book/book_preferences.dart';
import 'book/book_repository.dart';
import 'book/book_storage_service.dart';

class BookController extends ChangeNotifier {
  final BookRepository _repository;
  final BookDownloadService _downloadService;
  final BookStorageService _storageService;
  final BookPreferences _preferences;
  List<Book> _downloadedBooks = [];

  BookController({
    required BookRepository repository,
    required BookDownloadService downloadService,
    required BookStorageService storageService,
    required BookPreferences preferences,
  })  : _repository = repository,
        _downloadService = downloadService,
        _storageService = storageService,
        _preferences = preferences {
    _initialize();
  }

  bool _isOneByOneDeletionMode = false;
  bool get isOneByOneDeletionMode => _isOneByOneDeletionMode;

  void enableOneByOneDeletionMode() {
    _isOneByOneDeletionMode = true;
    notifyListeners();
  }

  void disableOneByOneDeletionMode() {
    _isOneByOneDeletionMode = false;
    notifyListeners();
  }

  List<Book> get books => _repository.books;
  List<Book> get filteredBooks => _repository.filteredBooks;
  List<Book> get bookmarkedBooks => _repository.bookmarkedBooks;
  List<Book> get downloadedBooks => _downloadedBooks;
  List<Book> get searchResults => _repository.searchResults;
  bool get wifiOnlyDownloads => _preferences.wifiOnlyDownloads;
  TextEditingController get searchController => _repository.searchController;

  Future<void> _initialize() async {
    await loadInitialData();
  }

  Future<void> loadInitialData() async {
    await _repository.loadInitialData();
    await _preferences.loadPreferences();
    await loadDownloadedBooks();
    notifyListeners();
  }

  Future<void> loadDownloadedBooks() async {
    _downloadedBooks = await _storageService.getDownloadedBooks();
    notifyListeners();
  }

  Future<Book?> getDownloadedBook(String id) async {
    return await _storageService.getDownloadedBook(id);
  }

  Future<void> downloadBook(
      Book book, {
        Function(int received, int total)? onProgress,
      }) async {
    await _downloadService.downloadBook(
      book,
      onProgress: onProgress,
      onComplete: (_) async {
        await loadDownloadedBooks();
      },
      onError: (e) {
        throw e;
      },
    );
  }

  Future<void> removeDownloadedBook(String id) async {
    await _storageService.removeDownloadedBook(id);
    await loadDownloadedBooks();
  }

  Future<void> clearAllDownloads() async {
    await _storageService.clearAllDownloads();
    await loadDownloadedBooks();
  }

  Future<double> calculateTotalStorageUsed() async {
    return await _storageService.calculateTotalStorageUsed();
  }

  Future<bool> isBookDownloaded(Book book) async {
    return await _storageService.isBookDownloaded(book);
  }

  bool isBookmarked(Book book) => _repository.isBookmarked(book);

  Future<void> toggleBookmark(Book book) async {
    await _repository.toggleBookmark(book);
    notifyListeners();
  }

  void filterBooksByCategory(String category) {
    _repository.filterBooksByCategory(category);
    notifyListeners();
  }

  void searchBooks(String query) {
    _repository.searchBooks(query);
    notifyListeners();
  }

  void clearSearch() {
    _repository.clearSearch();
    notifyListeners();
  }

  Future<void> setWifiOnlyDownloads(bool value) async {
    await _preferences.setWifiOnlyDownloads(value);
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}