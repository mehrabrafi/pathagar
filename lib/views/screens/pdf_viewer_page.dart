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

class _PDFViewerScreenState extends State<PDFViewerScreen>
    with WidgetsBindingObserver {
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
  bool _isLocked = false;
  Orientation? _currentOrientation;
  DateTime _lastProgressUpdate = DateTime.now();
  double _lastProgressValue = 0.0;
  Uint8List? _pdfData;
  final PdfScrollDirection _scrollDirection = PdfScrollDirection.horizontal;
  Timer? _zoomDebounceTimer;
  double _lastScale = 1.0;
  bool _isPinching = false;

  // Zoom constraints
  static const double _minZoomLevel = 0.5;
  static const double _maxZoomLevel = 5.0;
  static const double _zoomStep = 0.25;
  static const double _pinchZoomBuffer = 0.2; // 20% buffer beyond min/max

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePdfLoader();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateOrientation());
    _currentZoomLevel = _currentZoomLevel.clamp(_minZoomLevel, _maxZoomLevel);
  }

  void _updateOrientation() {
    if (!mounted) return;
    final newOrientation = MediaQuery.of(context).orientation;
    if (newOrientation != _currentOrientation) {
      setState(() => _currentOrientation = newOrientation);
    }
  }

  @override
  void didChangeMetrics() {
    _updateOrientation();
    if (mounted) {
      _pdfController.zoomLevel = _currentZoomLevel;
    }
  }

  @override
  void dispose() {
    _downloadCancelToken?.cancel();
    _pdfController.dispose();
    _setNormalOrientation();
    WidgetsBinding.instance.removeObserver(this);
    _zoomDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _toggleFullScreen() async {
    final currentZoom = _pdfController.zoomLevel;

    try {
      if (_isFullScreen) {
        await _setNormalOrientation();
        if (mounted && _isFullScreen) {
          setState(() => _isFullScreen = _isLocked = false);
        }
      } else {
        await _setLandscapeOrientation();
        if (mounted && !_isFullScreen) {
          setState(() => _isFullScreen = true);
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pdfController.zoomLevel = currentZoom;
          _currentZoomLevel = currentZoom;
        }
      });
    } catch (e) {
      if (mounted) setState(() => _isFullScreen = false);
      debugPrint('Fullscreen error: $e');
    }
  }

  Future<void> _setLandscapeOrientation() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (e) {
      debugPrint('Landscape error: $e');
    }
  }

  Future<void> _setNormalOrientation() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      debugPrint('Portrait error: $e');
    }
  }

  Future<bool> _onWillPop() async {
    if (_isExiting) return true;
    if (!_isFullScreen) return true;

    setState(() => _isExiting = true);
    await _toggleFullScreen();
    if (mounted) setState(() => _isExiting = false);
    return false;
  }

  void _initializePdfLoader() {
    if (widget.isLocal) {
      _pdfFuture = _loadLocalPdf();
    } else {
      widget.preCache ? _checkCacheAndLoad() : _pdfFuture = _loadPdf();
    }
  }

  Future<void> _checkCacheAndLoad() async {
    final file = await DefaultCacheManager().getSingleFile(widget.pdfUrl);
    if (await file.exists()) {
      if (mounted) setState(() => _isPreCached = true);
      _pdfFuture = file.readAsBytes();
    } else {
      _pdfFuture = _loadPdf();
    }
  }

  Future<Uint8List> _loadPdf() async {
    if (_pdfData != null) return _pdfData!;

    try {
      _downloadCancelToken = CancelToken();
      final dio = Dio();
      final response = await dio.get<Uint8List>(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
        cancelToken: _downloadCancelToken,
        onReceiveProgress: _handleProgressUpdate,
      );
      return _pdfData = response.data!;
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        throw Exception('Download cancelled');
      }
      throw Exception('PDF load failed: ${e.toString()}');
    }
  }

  void _handleProgressUpdate(int received, int total) {
    if (total == -1 || !mounted) return;

    final now = DateTime.now();
    final progress = received / total;
    if (now.difference(_lastProgressUpdate).inMilliseconds > 100 ||
        (progress - _lastProgressValue).abs() > 0.01) {
      setState(() => _downloadProgress = progress);
      _lastProgressUpdate = now;
      _lastProgressValue = progress;
    }
  }

  Future<Uint8List> _loadLocalPdf() async {
    if (_pdfData != null) return _pdfData!;

    try {
      final file = File(widget.pdfUrl);
      if (await file.exists()) return _pdfData = await file.readAsBytes();
      throw Exception('File not found');
    } catch (e) {
      throw Exception('Local PDF error: ${e.toString()}');
    }
  }

  void _handleZoomIn() {
    final newZoom = (_currentZoomLevel + _zoomStep).clamp(_minZoomLevel, _maxZoomLevel);
    _updateZoomLevel(newZoom);
  }

  void _handleZoomOut() {
    final newZoom = (_currentZoomLevel - _zoomStep).clamp(_minZoomLevel, _maxZoomLevel);
    _updateZoomLevel(newZoom);
  }

  void _updateZoomLevel(double newZoom) {
    _zoomDebounceTimer?.cancel();

    // Apply buffer during pinch zoom
    final effectiveMin = _isPinching ? _minZoomLevel * (1 - _pinchZoomBuffer) : _minZoomLevel;
    final effectiveMax = _isPinching ? _maxZoomLevel * (1 + _pinchZoomBuffer) : _maxZoomLevel;

    newZoom = newZoom.clamp(effectiveMin, effectiveMax);

    _zoomDebounceTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted && newZoom != _currentZoomLevel) {
        try {
          _pdfController.zoomLevel = newZoom;
          setState(() => _currentZoomLevel = newZoom);
        } catch (e) {
          debugPrint('Zoom error: $e');
          _pdfController.zoomLevel = _currentZoomLevel;
        }
      }
    });
  }

  void _handlePinchStart() {
    _isPinching = true;
    _lastScale = 1.0;
  }

  void _handlePinchUpdate(ScaleUpdateDetails details) {
    if (!_isPinching) return;

    final scale = details.scale;
    if (scale == 1.0) return;

    final scaleFactor = scale / _lastScale;
    _lastScale = scale;

    _updateZoomLevel(_currentZoomLevel * scaleFactor);
  }

  void _handlePinchEnd() {
    _isPinching = false;
    // Snap back to constrained zoom level if beyond bounds
    if (_currentZoomLevel < _minZoomLevel || _currentZoomLevel > _maxZoomLevel) {
      _updateZoomLevel(_currentZoomLevel.clamp(_minZoomLevel, _maxZoomLevel));
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
          onZoomIn: _handleZoomIn,
          onZoomOut: _handleZoomOut,
          onToggleFullScreen: _toggleFullScreen,
          onBack: () => Navigator.of(context).pop(),
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
                }

                if (snapshot.hasError) {
                  return PdfErrorView(
                    theme: theme,
                    colorScheme: colorScheme,
                    onRetry: () => setState(() {
                      _renderError = false;
                      _isRendered = false;
                      _pdfData = null;
                      _downloadCancelToken?.cancel();
                      _initializePdfLoader();
                    }),
                  );
                }

                if (snapshot.hasData) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onScaleStart: (_) => _handlePinchStart(),
                        onScaleUpdate: _handlePinchUpdate,
                        onScaleEnd: (_) => _handlePinchEnd(),
                        child: IgnorePointer(
                          ignoring: _isLocked,
                          child: SfPdfViewer.memory(
                            snapshot.data!,
                            controller: _pdfController,
                            canShowScrollHead: true,
                            canShowScrollStatus: true,
                            pageLayoutMode: PdfPageLayoutMode.single,
                            scrollDirection: _scrollDirection,
                            initialZoomLevel: _currentZoomLevel,
                            enableDocumentLinkAnnotation: false,
                            enableTextSelection: false,
                            onDocumentLoaded: (_) {
                              if (mounted) setState(() => _isRendered = true);
                            },
                            onDocumentLoadFailed: (_) {
                              if (mounted) setState(() => _renderError = true);
                            },
                          ),
                        ),
                      ),
                      if (_renderError)
                        Center(child: PdfErrorView(
                          theme: theme,
                          colorScheme: colorScheme,
                          onRetry: () => setState(() {
                            _renderError = false;
                            _isRendered = false;
                            _pdfData = null;
                            _initializePdfLoader();
                          }),
                        )),
                      if (_isRendered && !_renderError)
                        PdfControls(
                          isFullScreen: _isFullScreen,
                          isLocked: _isLocked,
                          onToggleFullScreen: _toggleFullScreen,
                          onToggleLock: () => setState(() => _isLocked = !_isLocked),
                          onUnrotate: _isFullScreen ? () async {
                            await _setNormalOrientation();
                            if (mounted) setState(() => _isFullScreen = false);
                          } : null,
                        ),
                    ],
                  );
                }

                return Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}