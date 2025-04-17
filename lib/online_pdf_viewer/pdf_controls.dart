import 'package:flutter/material.dart';

class PdfControls extends StatelessWidget {
  final bool isFullScreen;
  final bool isLocked;
  final Future<void> Function() onToggleFullScreen;
  final VoidCallback onToggleLock;
  final VoidCallback? onUnrotate;

  const PdfControls({
    super.key,
    required this.isFullScreen,
    required this.isLocked,
    required this.onToggleFullScreen,
    required this.onToggleLock,
    this.onUnrotate,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onUnrotate != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: FloatingActionButton(
                    heroTag: 'unrotate',
                    onPressed: onUnrotate,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: const Icon(
                      Icons.screen_rotation,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isFullScreen)
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'lock',
              onPressed: onToggleLock,
              backgroundColor: Colors.white.withOpacity(0.9),
              child: Icon(
                isLocked ? Icons.lock : Icons.lock_open,
                color: Colors.blueAccent,
              ),
            ),
          ),
      ],
    );
  }
}