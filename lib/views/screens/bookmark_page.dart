import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../controllers/book_controller.dart';
import 'bookmark_components/bookmark_app_bar.dart';
import 'bookmark_components/bookmark_empty_state.dart';
import 'bookmark_components/bookmark_grid_view.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkConnectivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bookmarks')),
            body: const Center(
              child: Text('You need to be online to view bookmarks'),
            ),
          );
        }

        return Scaffold(
          appBar: const BookmarkAppBar(),
          body: SafeArea(
            child: Consumer<BookController>(
              builder: (context, bookController, child) {
                if (bookController.bookmarkedBooks.isEmpty) {
                  return const BookmarkEmptyState();
                }
                return const BookmarkGridView();
              },
            ),
          ),
        );
      },
    );
  }
}