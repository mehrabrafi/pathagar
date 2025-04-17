import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isRendered;
  final bool renderError;
  final bool isFullScreen;
  final PdfViewerController pdfController;
  final double currentZoomLevel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;
  final VoidCallback onToggleFullScreen;
  final VoidCallback onBack;

  const PdfAppBar({
    super.key,
    required this.title,
    required this.isRendered,
    required this.renderError,
    required this.isFullScreen,
    required this.pdfController,
    required this.currentZoomLevel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
    required this.onToggleFullScreen,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: Colors.blueAccent,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ),
      actions: [
        if (isRendered && !renderError && !isFullScreen)
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: onZoomIn,
          ),
        if (isRendered && !renderError && !isFullScreen)
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: onZoomOut,
          ),
        if (isRendered && !renderError && !isFullScreen)
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed: onResetZoom,
          ),
        if (isRendered && !renderError)
          IconButton(
            icon: Icon(
              isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            ),
            onPressed: onToggleFullScreen,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}