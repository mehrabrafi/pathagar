import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final bool isLocal;
  final bool preCache;

  const PDFViewerPage({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.isLocal = false,
    this.preCache = false,
  });

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> with WidgetsBindingObserver {
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
  late ConfettiController _confettiController;
  PdfScrollDirection _scrollDirection = PdfScrollDirection.horizontal;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _initializePdfLoader();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollDirection = PdfScrollDirection.horizontal;
  }

  @override
  void didChangeMetrics() {
    if (mounted) {
      _scrollDirection = PdfScrollDirection.horizontal;
      _pdfController.zoomLevel = _currentZoomLevel;
    }
  }

  @override
  void dispose() {
    _downloadCancelToken?.cancel();
    _pdfController.dispose();
    _confettiController.dispose();
    _setNormalOrientation();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
    });
  }

  Future<void> _toggleFullScreen() async {
    final currentZoom = _pdfController.zoomLevel;

    if (_isFullScreen) {
      await _setNormalOrientation();
    } else {
      await _setLandscapeOrientation();
    }

    if (mounted) {
      setState(() {
        _isFullScreen = !_isFullScreen;
        if (!_isFullScreen) {
          _isLocked = false;
        }
      });
    }

    await Future.delayed(const Duration(milliseconds: 300));
    _pdfController.zoomLevel = currentZoom;
    _currentZoomLevel = currentZoom;
  }

  Future<void> _setLandscapeOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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

  Future<bool> _onWillPop() async {
    if (_isExiting) return true;

    if (_isFullScreen) {
      setState(() => _isExiting = true);
      await _setNormalOrientation();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        Navigator.of(context).pop();
      }
      return false;
    }
    return true;
  }

  void _zoomIn() {
    if (mounted) {
      setState(() {
        _currentZoomLevel += 0.5;
        _pdfController.zoomLevel = _currentZoomLevel;
      });
    }
  }

  void _zoomOut() {
    if (_currentZoomLevel > 0.5 && mounted) {
      setState(() {
        _currentZoomLevel -= 0.5;
        _pdfController.zoomLevel = _currentZoomLevel;
      });
    }
  }

  void _resetZoom() {
    if (mounted) {
      setState(() {
        _currentZoomLevel = 1.0;
        _pdfController.zoomLevel = _currentZoomLevel;
      });
    }
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

  Widget _buildLoadingIndicator(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: colorScheme.primary.withOpacity(0.3),
                  highlightColor: colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    'Loading Document',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_downloadProgress > 0)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _downloadProgress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Text(
                        '${(value * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_downloadProgress > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 12,
                  child: LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 12,
                  ),
                ),
              ),
            ),
          if (_isPreCached)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.secondary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download_done,
                        color: colorScheme.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Loaded from cache',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load PDF',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.onErrorContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                setState(() {
                  _renderError = false;
                  _isRendered = false;
                  _initializePdfLoader();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnrotateButton() {
    if (!_isFullScreen) return const SizedBox();

    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'unrotate',
        onPressed: _toggleFullScreen,
        backgroundColor: Colors.white.withOpacity(0.9),
        child: Icon(
          Icons.screen_rotation,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildLockButton() {
    if (!_isFullScreen) return const SizedBox();

    return Positioned(
      top: 20,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'lock',
        onPressed: _toggleLock,
        backgroundColor: Colors.white.withOpacity(0.9),
        child: Icon(
          _isLocked ? Icons.lock : Icons.lock_open,
          color: Colors.blueAccent,
        ),
      ),
    );
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
            : AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
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
          actions: [
            if (_isRendered && !_renderError && !_isFullScreen)
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: _zoomIn,
              ),
            if (_isRendered && !_renderError && !_isFullScreen)
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: _zoomOut,
              ),
            if (_isRendered && !_renderError && !_isFullScreen)
              IconButton(
                icon: const Icon(Icons.zoom_out_map),
                onPressed: _resetZoom,
              ),
            if (_isRendered && !_renderError)
              IconButton(
                icon: Icon(
                  _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                ),
                onPressed: _toggleFullScreen,
              ),
          ],
        ),
        body: Stack(
          children: [
            FutureBuilder<Uint8List>(
              future: _pdfFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator(theme, colorScheme);
                } else if (snapshot.hasError) {
                  return _buildErrorView(theme, colorScheme);
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
                          scrollDirection: PdfScrollDirection.horizontal,
                          initialZoomLevel: _currentZoomLevel,
                          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                            if (mounted) {
                              setState(() {
                                _isRendered = true;
                                _pdfController.zoomLevel = _currentZoomLevel;
                              });
                              _confettiController.play();
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
                                _buildErrorView(theme, colorScheme)
                              else
                                CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      if (_isRendered && !_renderError) _buildUnrotateButton(),
                      if (_isRendered && !_renderError) _buildLockButton(),
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
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                createParticlePath: drawStar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);
    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}