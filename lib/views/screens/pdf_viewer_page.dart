import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../online_pdf_viewer/pdf_app_bar.dart';
import '../../online_pdf_viewer/pdf_controls.dart';
import '../../online_pdf_viewer/pdf_error_view.dart';
import '../../online_pdf_viewer/pdf_loading_indicator.dart';
class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final bool isLocal;
  final bool preCache;

  const PDFViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.isLocal = false,
    this.preCache = false,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> with WidgetsBindingObserver {
  late Future<Uint8List> _pdfFuture;
  double _downloadProgress = 0.0;
  bool _isRendered = false;
  bool _renderError = false;
  final PdfViewerController _pdfController = PdfViewerController();
  bool _isPreCached = false;
  CancelToken? _downloadCancelToken;
  bool _isFullScreen = false;
  bool _isExiting = false;
  double _currentZoomLevel = 1.0;
  PdfScrollDirection _scrollDirection = PdfScrollDirection.horizontal;
  bool _isLocked = false;
  bool _isPortrait = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePdfLoader();
    _checkInitialOrientation();
  }

  Future<void> _checkInitialOrientation() async {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize;
    _isPortrait = size.height > size.width;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollDirection = PdfScrollDirection.horizontal;
  }

  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize;
    final newIsPortrait = size.height > size.width;

    if (newIsPortrait != _isPortrait) {
      setState(() {
        _isPortrait = newIsPortrait;
      });
    }

    if (mounted) {
      _scrollDirection = PdfScrollDirection.horizontal;
      _pdfController.zoomLevel = _currentZoomLevel;
    }
  }

  @override
  void dispose() {
    _downloadCancelToken?.cancel();
    _pdfController.dispose();
    _setNormalOrientation();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _toggleFullScreen() async {
    try {
      // Store current zoom level
      final currentZoom = _pdfController.zoomLevel;

      if (_isFullScreen) {
        // Exit fullscreen
        await _setNormalOrientation();
        // Wait for orientation to complete
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          setState(() {
            _isFullScreen = false;
            _isLocked = false;
          });
        }
      } else {
        // Enter fullscreen
        await _setLandscapeOrientation();
        if (mounted) {
          setState(() => _isFullScreen = true);
        }
      }

      // Restore zoom level after a small delay
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _pdfController.zoomLevel = currentZoom;
        _currentZoomLevel = currentZoom;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFullScreen = false);
      }
      debugPrint('Error toggling fullscreen: $e');
    }
  }

  Future<void> _setLandscapeOrientation() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
    } catch (e) {
      debugPrint('Error setting landscape: $e');
    }
  }

  Future<void> _setNormalOrientation() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    } catch (e) {
      debugPrint('Error setting normal orientation: $e');
    }
  }

  Future<bool> _onWillPop() async {
    if (_isExiting) return true;

    if (_isFullScreen) {
      setState(() => _isExiting = true);
      try {
        await _toggleFullScreen();
        return false; // Don't pop if we just exited fullscreen
      } finally {
        if (mounted) {
          setState(() => _isExiting = false);
        }
      }
    }
    return true; // Allow pop in normal mode
  }

  void _initializePdfLoader() {
    if (!widget.isLocal) {
      if (widget.preCache) {
        _checkCacheAndLoad();
      } else {
        _pdfFuture = _loadPdf();
      }
    } else {
      _pdfFuture = _loadLocalPdf();
    }
  }

  Future<void> _checkCacheAndLoad() async {
    final file = await DefaultCacheManager().getSingleFile(widget.pdfUrl);
    if (await file.exists()) {
      if (mounted) {
        setState(() => _isPreCached = true);
      }
      _pdfFuture = file.readAsBytes();
    } else {
      _pdfFuture = _loadPdf();
    }
  }

  Future<Uint8List> _loadPdf() async {
    try {
      _downloadCancelToken = CancelToken();
      final dio = Dio();
      final response = await dio.get<Uint8List>(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
        cancelToken: _downloadCancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );
      return response.data!;
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        throw Exception('Download cancelled');
      }
      throw Exception('Failed to load PDF: ${e.toString()}');
    }
  }

  Future<Uint8List> _loadLocalPdf() async {
    try {
      final file = File(widget.pdfUrl);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      throw Exception('File not found');
    } catch (e) {
      throw Exception('Failed to load local PDF: ${e.toString()}');
    }
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
          title: widget.title,
          isRendered: _isRendered,
          renderError: _renderError,
          isFullScreen: _isFullScreen,
          pdfController: _pdfController,
          currentZoomLevel: _currentZoomLevel,
          onZoomIn: () {
            setState(() {
              _currentZoomLevel += 0.5;
              _pdfController.zoomLevel = _currentZoomLevel;
            });
          },
          onZoomOut: () {
            if (_currentZoomLevel > 0.5 && mounted) {
              setState(() {
                _currentZoomLevel -= 0.5;
                _pdfController.zoomLevel = _currentZoomLevel;
              });
            }
          },
          onResetZoom: () {
            setState(() {
              _currentZoomLevel = 1.0;
              _pdfController.zoomLevel = _currentZoomLevel;
            });
          },
          onToggleFullScreen: _toggleFullScreen,
          onBack: () async {
            if (_isFullScreen) {
              setState(() => _isExiting = true);
              await _setNormalOrientation();
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                Navigator.of(context).pop();
              }
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        body: Stack(
          children: [
            FutureBuilder<Uint8List>(
              future: _pdfFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return PdfLoadingIndicator(
                    theme: theme,
                    colorScheme: colorScheme,
                    downloadProgress: _downloadProgress,
                    isPreCached: _isPreCached,
                  );
                } else if (snapshot.hasError) {
                  return PdfErrorView(
                    theme: theme,
                    colorScheme: colorScheme,
                    onRetry: () {
                      setState(() {
                        _renderError = false;
                        _isRendered = false;
                        _initializePdfLoader();
                      });
                    },
                  );
                } else if (snapshot.hasData) {
                  return Stack(
                    children: [
                      IgnorePointer(
                        ignoring: _isLocked,
                        child: SfPdfViewer.memory(
                          snapshot.data!,
                          controller: _pdfController,
                          canShowScrollHead: true,
                          canShowScrollStatus: true,
                          pageLayoutMode: PdfPageLayoutMode.single,
                          scrollDirection: _scrollDirection,
                          initialZoomLevel: _currentZoomLevel,
                          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                            if (mounted) {
                              setState(() {
                                _isRendered = true;
                                _pdfController.zoomLevel = _currentZoomLevel;
                              });
                            }
                          },
                          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                            if (mounted) {
                              setState(() => _renderError = true);
                            }
                          },
                        ),
                      ),
                      if (!_isRendered || _renderError)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_renderError)
                                PdfErrorView(
                                  theme: theme,
                                  colorScheme: colorScheme,
                                  onRetry: () {
                                    setState(() {
                                      _renderError = false;
                                      _isRendered = false;
                                      _initializePdfLoader();
                                    });
                                  },
                                )
                              else
                                CircularProgressIndicator(
                                    color: colorScheme.primary),
                            ],
                          ),
                        ),
                      if (_isRendered && !_renderError)
                        PdfControls(
                          isFullScreen: _isFullScreen,
                          isLocked: _isLocked,
                          onToggleFullScreen: _toggleFullScreen,
                          onToggleLock: () {
                            setState(() {
                              _isLocked = !_isLocked;
                            });
                          },
                          onUnrotate: _isFullScreen ? () async {
                            await _setNormalOrientation();
                            setState(() {
                              _isFullScreen = false;
                              _isLocked = false;
                            });
                          } : null,
                        ),
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

