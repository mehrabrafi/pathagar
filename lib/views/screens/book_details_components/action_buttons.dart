import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../controllers/book_controller.dart';
import '../../../models/book.dart';
import '../pdf_viewer_page.dart';

class DownloadTracker {
  static final DownloadTracker _instance = DownloadTracker._internal();
  factory DownloadTracker() => _instance;
  DownloadTracker._internal();

  final Map<String, double> _activeDownloads = {};
  final StreamController<Map<String, double>> _progressController =
  StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get progressStream => _progressController.stream;

  void startDownload(String bookId) {
    _activeDownloads[bookId] = 0;
    _progressController.add(Map.from(_activeDownloads));
  }

  void updateProgress(String bookId, double progress) {
    _activeDownloads[bookId] = progress;
    _progressController.add(Map.from(_activeDownloads));
  }

  void completeDownload(String bookId) {
    _activeDownloads.remove(bookId);
    _progressController.add(Map.from(_activeDownloads));
  }

  double? getProgress(String bookId) => _activeDownloads[bookId];
}

class ActionButtons extends StatefulWidget {
  final Book book;
  final BookController bookController;

  const ActionButtons({
    Key? key,
    required this.book,
    required this.bookController,
  }) : super(key: key);

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool _isBookmarked = false;
  bool _isDownloaded = false;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<Map<String, double>>? _downloadSubscription;
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadBookStatus();
    _initConnectivity();
    _initDownloadListener();
  }

  Future<void> _initConnectivity() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOnline = !result.contains(ConnectivityResult.none);
      });
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = !connectivityResult.contains(ConnectivityResult.none);
    });
  }

  Future<void> _loadBookStatus() async {
    final bookmarked = widget.bookController.isBookmarked(widget.book);
    final isDownloaded = await widget.bookController.isBookDownloaded(widget.book);
    final downloadedBook = await widget.bookController.getDownloadedBook(widget.book.id);

    if (mounted) {
      setState(() {
        _isBookmarked = bookmarked;
        _isDownloaded = isDownloaded;
        _downloadProgress = DownloadTracker().getProgress(widget.book.id) ?? 0;
      });
    }
  }

  void _initDownloadListener() {
    _downloadSubscription = DownloadTracker().progressStream.listen((downloads) {
      if (mounted && downloads.containsKey(widget.book.id)) {
        setState(() {
          _downloadProgress = downloads[widget.book.id]!;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _downloadSubscription?.cancel();
    super.dispose();
  }

  Future<void> _downloadBook() async {
    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot download while offline'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    DownloadTracker().startDownload(widget.book.id);

    try {
      await widget.bookController.downloadBook(
        widget.book,
        onProgress: (received, total) {
          final progress = total <= 0 ? 0.0 : received.toDouble() / total.toDouble();
          DownloadTracker().updateProgress(widget.book.id, progress);
        },
      );

      if (mounted) {
        setState(() {
          _isDownloaded = true;
        });
        DownloadTracker().completeDownload(widget.book.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.book.title} downloaded successfully!'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Open',
              textColor: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewerScreen(
                      pdfUrl: widget.book.pdfUrl,
                      title: widget.book.title,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      DownloadTracker().completeDownload(widget.book.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleDownloadAction() {
    if (_isDownloaded) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(
            pdfUrl: widget.book.pdfUrl,
            title: widget.book.title,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download will start now. Please wait...'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        _downloadBook();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDownloading = _downloadProgress > 0 && _downloadProgress < 1;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (!_isOnline)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 16,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Offline mode',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBookmarkButton(),
              _buildReadButton(),
              _buildDownloadButton(isDownloading, theme, colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return Tooltip(
      message: _isBookmarked ? 'Remove bookmark' : 'Add bookmark',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 28,
            ),
            color: _isBookmarked
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodyLarge?.color,
            onPressed: () async {
              await widget.bookController.toggleBookmark(widget.book);
              setState(() => _isBookmarked = !_isBookmarked);
            },
          ),
          Text(
            _isBookmarked ? 'Saved' : 'Save',
            style: TextStyle(
              fontSize: 12,
              color: _isBookmarked
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadButton() {
    return Tooltip(
      message: 'Read book',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.menu_book, size: 28),
            color: Theme.of(context).textTheme.bodyLarge?.color,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(
                    pdfUrl: widget.book.pdfUrl,
                    title: widget.book.title,
                  ),
                ),
              );
            },
          ),
          const Text(
            'Read',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(bool isDownloading, ThemeData theme, ColorScheme colorScheme) {
    return Tooltip(
      message: _isDownloaded
          ? 'Open downloaded book'
          : isDownloading
          ? 'Download in progress'
          : 'Download book',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isDownloading)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: _downloadProgress,
                    strokeWidth: 3,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blueAccent,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  _isDownloaded
                      ? Icons.download_done
                      : isDownloading
                      ? Icons.downloading
                      : Icons.download,
                  size: 28,
                ),
                color: _isDownloaded
                    ? Colors.green
                    : isDownloading
                    ? Colors.blueAccent
                    : theme.textTheme.bodyLarge?.color,
                onPressed: isDownloading || !_isOnline ? null : _handleDownloadAction,
              ),
            ],
          ),
          Text(
            _isDownloaded ? 'Downloaded' : 'Download',
            style: TextStyle(
              fontSize: 12,
              color: _isDownloaded
                  ? Colors.green
                  : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}