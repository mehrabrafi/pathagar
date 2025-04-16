import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/book_controller.dart';
import '../widgets/settings_header.dart';
import '../widgets/storage_list_item.dart';
import '../dialogs/clear_downloads_dialog.dart';

class StorageSection extends StatelessWidget {
  const StorageSection({super.key});

  Future<String> _getStorageInfo(BookController bookController) async {
    try {
      final totalBooks = bookController.downloadedBooks.length;
      final totalSize = await bookController.calculateTotalStorageUsed();
      return '$totalBooks books (${totalSize.toStringAsFixed(2)} MB)';
    } catch (e) {
      return 'Error calculating storage';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookController = Provider.of<BookController>(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsHeader(title: 'Storage Management'),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
          child: Column(
            children: [
              StorageListItem(
                icon: Icons.delete,
                color: Colors.red,
                title: 'Clear All Downloads',
                subtitle: 'Free up storage space',
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: isTablet ? 28 : 24,
                  ),
                  onPressed: () async => await showClearAllDownloadsDialog(
                    context,
                    bookController,
                    isTablet,
                  ),
                ),
              ),
              const Divider(height: 1, indent: 16),
              StorageListItem(
                icon: Icons.storage,
                color: Colors.green,
                title: 'Storage Information',
                subtitleWidget: FutureBuilder<String>(
                  future: _getStorageInfo(bookController),
                  builder: (context, snapshot) => Text(
                    snapshot.data ?? 'Calculating storage...',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}