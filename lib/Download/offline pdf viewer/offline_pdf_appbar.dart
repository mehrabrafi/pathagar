import 'package:flutter/material.dart';

class PdfAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int? pages;
  final bool isReady;
  final String errorMessage;
  final bool isFullScreen;
  final bool showPageInput;
  final int? currentPage;
  final double zoomLevel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onToggleFullScreen;
  final VoidCallback onTogglePageInput;
  final VoidCallback onBack;

  const PdfAppBar({
    super.key,
    required this.title,
    required this.pages,
    required this.isReady,
    required this.errorMessage,
    required this.isFullScreen,
    required this.showPageInput,
    required this.currentPage,
    required this.zoomLevel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onToggleFullScreen,
    required this.onTogglePageInput,
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
        if (pages != null && isReady && errorMessage.isEmpty)
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            onPressed: onZoomIn,
          ),
        if (pages != null && isReady && errorMessage.isEmpty)
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            onPressed: onZoomOut,
          ),
        if (pages != null && isReady && errorMessage.isEmpty)
          IconButton(
            icon: Icon(
              isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: onToggleFullScreen,
          ),
        if (pages != null && !showPageInput)
          IconButton(
            icon: const Icon(Icons.pageview, color: Colors.white),
            onPressed: onTogglePageInput,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}