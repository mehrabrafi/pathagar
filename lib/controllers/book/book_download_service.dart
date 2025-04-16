import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/book.dart';
import 'book_storage_service.dart';

class BookDownloadService {
  final BookStorageService _storageService;

  BookDownloadService(this._storageService);

  Future<void> downloadBook(
      Book book, {
        Function(int received, int total)? onProgress,
        Function(String)? onComplete,
        Function(Object)? onError,
      }) async {
    try {
      final isDownloaded = await _storageService.isBookDownloaded(book);
      if (isDownloaded) {
        final downloadedBook = await _storageService.getDownloadedBook(book.id);
        if (downloadedBook?.localPath != null) {
          final file = File(downloadedBook!.localPath!);
          if (await file.exists()) {
            if (onComplete != null) onComplete(downloadedBook.localPath!);
            return;
          }
        }
      }

      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${book.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${dir.path}/$fileName';

      await dio.download(
        book.pdfUrl,
        filePath,
        onReceiveProgress: onProgress,
      );

      final file = File(filePath);
      final size = await file.length();
      final sizeInMB = (size / (1024 * 1024)).toStringAsFixed(2);

      final downloadedBook = Book(
        id: book.id,
        title: book.title,
        author: book.author,
        category: book.category,
        imageUrl: book.imageUrl,
        date: book.date,
        pdfUrl: book.pdfUrl,
        localPath: filePath,
        fileSize: '${sizeInMB} MB',
        isDownloaded: true,
      );

      await _storageService.saveDownloadedBook(downloadedBook);
      if (onComplete != null) onComplete(filePath);
    } catch (e) {
      if (onError != null) onError(e);
      rethrow;
    }
  }
}