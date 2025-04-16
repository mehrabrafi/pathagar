import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookCover extends StatelessWidget {
  final String imageUrl;

  const BookCover({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      width: double.infinity,
      height: isPortrait ? screenHeight * 0.35 : screenHeight * 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          color: theme.cardColor,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.broken_image,
          size: MediaQuery.of(context).size.width * 0.2,
          color: theme.disabledColor,
        ),
      ),
    );
  }
}