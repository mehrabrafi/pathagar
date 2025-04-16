import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:shimmer/shimmer.dart';
import 'package:confetti/confetti.dart';

class DownloadedPdfViewerPage extends StatefulWidget {
  final String filePath;
  final String? title;

  const DownloadedPdfViewerPage({
    super.key,
    required this.filePath,
    this.title = 'PDF Viewer',
  });

  @override
  State<DownloadedPdfViewerPage> createState() => _DownloadedPdfViewerPageState();
}

class _DownloadedPdfViewerPageState extends State<DownloadedPdfViewerPage>
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
  late ConfettiController _confettiController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _loadingAnimation;
  bool _isPageLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
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
    _confettiController.dispose();
    _loadingAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (mounted) {
      setState(() {});
    }
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

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
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

  Widget _buildLoadingIndicator(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _loadingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _loadingAnimation.value,
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
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: colorScheme.primary.withOpacity(0.3),
            highlightColor: colorScheme.primary.withOpacity(0.1),
            child: Text(
              'Preparing Document',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
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
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load PDF',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                setState(() {
                  errorMessage = '';
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenControls() {
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
          _isPageLocked ? Icons.lock : Icons.lock_open,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    if (pages == null || _isFullScreen) return const SizedBox();

    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${currentPage! + 1}/$pages',
            style: const TextStyle(color: Colors.white),
          ),
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
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
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
            widget.title!,
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
                if (mounted) Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (pages != null && isReady && errorMessage.isEmpty)
              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.white),
                onPressed: _zoomIn,
              ),
            if (pages != null && isReady && errorMessage.isEmpty)
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.white),
                onPressed: _zoomOut,
              ),
            if (pages != null && isReady && errorMessage.isEmpty)
              IconButton(
                icon: Icon(
                  _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: _toggleFullScreen,
              ),
            if (pages != null && !_showPageInput)
              IconButton(
                icon: const Icon(Icons.pageview, color: Colors.white),
                onPressed: () {
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
              ),
          ],
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
                            _confettiController.play();
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
                  _buildErrorView(theme, colorScheme),
                if (!isReady && errorMessage.isEmpty)
                  _buildLoadingIndicator(theme, colorScheme),
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
            _buildFullScreenControls(),
            _buildLockButton(),
            _buildPageIndicator(),
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
}