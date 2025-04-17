import 'package:flutter/material.dart';

class PdfControls extends StatelessWidget {
  final bool isFullScreen;
  final bool isPageLocked;
  final VoidCallback onToggleFullScreen;
  final VoidCallback onToggleLock;

  const PdfControls({
    super.key,
    required this.isFullScreen,
    required this.isPageLocked,
    required this.onToggleFullScreen,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFullScreen) return const SizedBox();

    return Stack(
      children: [
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'unrotate',
            onPressed: onToggleFullScreen,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: const Icon(
              Icons.screen_rotation,
              color: Colors.blueAccent,
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'lock',
            onPressed: onToggleLock,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: Icon(
              isPageLocked ? Icons.lock : Icons.lock_open,
              color: Colors.blueAccent,
            ),
          ),
        ),
      ],
    );
  }
}