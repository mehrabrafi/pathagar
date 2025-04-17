import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import 'offline pdf viewer/offline_pdf_appbar.dart';
import 'offline pdf viewer/pdf_loading_indicator_offline.dart';
import 'offline pdf viewer/pdf_controls_offline.dart';
import 'offline pdf viewer/pdf_error_view_offline.dart';
import 'offline pdf viewer/pdf_page_indicator_offline.dart';
class DownloadedPdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String? title;

  const DownloadedPdfViewerScreen({
    super.key,
    required this.filePath,
    this.title = 'PDF Viewer',
  });

  @override
  State<DownloadedPdfViewerScreen> createState() => _DownloadedPdfViewerScreenState();
}

class _DownloadedPdfViewerScreenState extends State<DownloadedPdfViewerScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final Completer<PDFViewController> _pdfController = Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  final TextEditingController _pageController = TextEditingController();
  final FocusNode _pageFocusNode = FocusNode();
  bool _showPageInput = false;
  bool _isFullScreen = false;
  bool _isExiting = false;
  double _zoomLevel = 1.0;
  late AnimationController _loadingAnimationController;
  late Animation<double> _loadingAnimation;
  bool _isPageLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadingAnimation = Tween(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageFocusNode.dispose();
    _setNormalOrientation();
    _loadingAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _setNormalOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _toggleFullScreen() async {
    if (_isFullScreen) {
      await _setNormalOrientation();
    } else {
      await _setLandscapeOrientation();
    }
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (!_isFullScreen) {
        _isPageLocked = false;
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (_isExiting) return true;
    if (_isFullScreen) {
      setState(() => _isExiting = true);
      await _setNormalOrientation();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) Navigator.of(context).pop();
      return false;
    }
    return true;
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.2).clamp(0.5, 3.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.2).clamp(0.5, 3.0);
    });
  }

  void _toggleLock() {
    setState(() {
      _isPageLocked = !_isPageLocked;
    });
  }

  void _navigateToPage(PDFViewController controller) {
    final pageText = _pageController.text;
    if (pageText.isEmpty) return;

    final pageNumber = int.tryParse(pageText);
    if (pageNumber == null || pageNumber < 1 || pageNumber > pages!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid page number (1-$pages)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    controller.setPage(pageNumber - 1);
    _pageFocusNode.unfocus();
    setState(() {
      _showPageInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _isFullScreen
            ? null
            : PdfAppBar(
          title: widget.title!,
          pages: pages,
          isReady: isReady,
          errorMessage: errorMessage,
          isFullScreen: _isFullScreen,
          showPageInput: _showPageInput,
          currentPage: currentPage,
          zoomLevel: _zoomLevel,
          onZoomIn: _zoomIn,
          onZoomOut: _zoomOut,
          onToggleFullScreen: _toggleFullScreen,
          onTogglePageInput: () {
            setState(() {
              _showPageInput = !_showPageInput;
              if (_showPageInput) {
                _pageController.text = (currentPage! + 1).toString();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FocusScope.of(context).requestFocus(_pageFocusNode);
                });
              }
            });
          },
          onBack: () async {
            if (_isFullScreen) {
              setState(() => _isExiting = true);
              await _setNormalOrientation();
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        body: Stack(
          children: [
            Stack(
              children: [
                if (errorMessage.isEmpty)
                  Transform.scale(
                    scale: _zoomLevel,
                    child: Center(
                      child: IgnorePointer(
                        ignoring: _isPageLocked,
                        child: PDFView(
                          filePath: widget.filePath,
                          enableSwipe: !_isPageLocked,
                          swipeHorizontal: !_isFullScreen,
                          autoSpacing: true,
                          pageFling: !_isPageLocked,
                          pageSnap: true,
                          defaultPage: currentPage ?? 0,
                          fitPolicy: FitPolicy.BOTH,
                          preventLinkNavigation: false,
                          onRender: (pages) {
                            setState(() {
                              this.pages = pages;
                              isReady = true;
                            });

                          },
                          onError: (error) {
                            setState(() {
                              errorMessage = error.toString();
                            });
                          },
                          onPageError: (page, error) {
                            setState(() {
                              errorMessage = '$page: ${error.toString()}';
                            });
                          },
                          onViewCreated: (PDFViewController pdfViewController) {
                            _pdfController.complete(pdfViewController);
                          },
                          onPageChanged: (int? page, int? total) {
                            if (!_isPageLocked) {
                              setState(() {
                                currentPage = page;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  )
                else
                  PdfErrorView(
                    theme: theme,
                    colorScheme: colorScheme,
                    errorMessage: errorMessage,
                    onRetry: () {
                      setState(() {
                        errorMessage = '';
                      });
                    },
                  ),
                if (!isReady && errorMessage.isEmpty)
                  PdfLoadingIndicator(
                    theme: theme,
                    colorScheme: colorScheme,
                    loadingAnimation: _loadingAnimation,
                  ),
              ],
            ),
            if (_showPageInput && pages != null && !_isFullScreen)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pageController,
                              focusNode: _pageFocusNode,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Page number (1-$pages)',
                                border: const OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _pdfController.future.then(_navigateToPage),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FutureBuilder<PDFViewController>(
                            future: _pdfController.future,
                            builder: (context, snapshot) {
                              return IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: _isPageLocked || !snapshot.hasData
                                    ? null
                                    : () => _navigateToPage(snapshot.data!),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            PdfControls(
              isFullScreen: _isFullScreen,
              isPageLocked: _isPageLocked,
              onToggleFullScreen: _toggleFullScreen,
              onToggleLock: _toggleLock,
            ),
            PdfPageIndicator(
              isFullScreen: _isFullScreen,
              pages: pages,
              currentPage: currentPage,
            ),
          ],
        ),
      ),
    );
  }
}