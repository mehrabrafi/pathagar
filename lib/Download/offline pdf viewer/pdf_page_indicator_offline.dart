import 'package:flutter/material.dart';

class PdfPageIndicator extends StatelessWidget {
  final bool isFullScreen;
  final int? pages;
  final int? currentPage;

  const PdfPageIndicator({
    super.key,
    required this.isFullScreen,
    required this.pages,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    if (pages == null || isFullScreen) return const SizedBox();

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
}