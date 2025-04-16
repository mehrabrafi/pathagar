import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/book.dart';

class BookStorageService {
  final SharedPreferences _prefs;
  static const String _downloadedBooksKey = 'downloaded_books';

  BookStorageService(this._prefs);

  Future<List<Book>> getDownloadedBooks() async {
    final booksJson = _prefs.getStringList(_downloadedBooksKey);
    if (booksJson == null) return [];

    try {
      return booksJson.map((json) => Book.fromMap(jsonDecode(json))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Book?> getDownloadedBook(String id) async {
    final books = await getDownloadedBooks();
    try {
      return books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveDownloadedBook(Book book) async {
    final books = await getDownloadedBooks();
    final existingIndex = books.indexWhere((b) => b.id == book.id);

    if (existingIndex >= 0) {
      books[existingIndex] = book;
    } else {
      books.add(book);
    }

    await _saveBooks(books);
  }

  Future<void> removeDownloadedBook(String id) async {
    final books = await getDownloadedBooks();
    books.removeWhere((book) => book.id == id);
    await _saveBooks(books);
  }

  Future<void> _saveBooks(List<Book> books) async {
    final booksJson = books.map((book) => jsonEncode(book.toMap())).toList();
    await _prefs.setStringList(_downloadedBooksKey, booksJson);
  }

  Future<bool> isBookDownloaded(Book book) async {
    final books = await getDownloadedBooks();
    return books.any((b) => b.id == book.id);
  }

  Future<void> clearAllDownloads() async {
    final books = await getDownloadedBooks();
    for (final book in books) {
      if (book.localPath != null) {
        try {
          final file = File(book.localPath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting file: $e');
        }
      }
    }
    await _prefs.remove(_downloadedBooksKey);
  }

  Future<double> calculateTotalStorageUsed() async {
    final books = await getDownloadedBooks();
    double totalSize = 0;
    for (final book in books) {
      if (book.localPath != null) {
        try {
          final file = File(book.localPath!);
          if (await file.exists()) {
            final size = await file.length();
            totalSize += size;
          }
        } catch (e) {
          print('Error calculating file size: $e');
        }
      }
    }
    return totalSize / (1024 * 1024); // Return in MB
  }
}