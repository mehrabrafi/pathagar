// import 'package:flutter/material.dart';
// import 'download_manager.dart';
//
// class DownloadsScreen extends StatefulWidget {
//   const DownloadsScreen({super.key});
//
//   @override
//   State<DownloadsScreen> createState() => _DownloadsScreenState();
// }
//
// class _DownloadsScreenState extends State<DownloadsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Downloads'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => Navigator.pop(context),
//           ),
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'clear_history') {
//                 _showClearHistoryDialog(context);
//               }
//             },
//             itemBuilder: (BuildContext context) {
//               return [
//                 const PopupMenuItem<String>(
//                   value: 'clear_history',
//                   child: Text('Clear All History'),
//                 ),
//               ];
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<Map<String, DownloadProgress>>(
//         stream: DownloadManager().progressStream,
//         builder: (context, snapshot) {
//           final downloads = snapshot.data?.values.toList() ?? [];
//           final completedDownloads = DownloadManager().completedDownloads;
//
//           if (downloads.isEmpty && completedDownloads.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.download, size: 48, color: Colors.grey),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No downloads',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return ListView(
//             padding: const EdgeInsets.all(8),
//             children: [
//               if (downloads.isNotEmpty) ...[
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Text(
//                     'Active Downloads',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 ...downloads.map((download) => _buildDownloadItem(download, context)).toList(),
//                 const Divider(height: 32),
//               ],
//               if (completedDownloads.isNotEmpty) ...[
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Row(
//                     children: [
//                       const Text(
//                         'Download History',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const Spacer(),
//                       TextButton(
//                         onPressed: () => _showClearHistoryDialog(context),
//                         child: const Text('Clear All'),
//                       ),
//                     ],
//                   ),
//                 ),
//                 ...completedDownloads.map((download) => _buildHistoryItem(download, context)).toList(),
//               ],
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildDownloadItem(DownloadProgress download, BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               download.title,
//               style: Theme.of(context).textTheme.titleMedium,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 12),
//             LinearProgressIndicator(
//               value: download.progress,
//               minHeight: 6,
//               backgroundColor: Colors.grey[200],
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 Theme.of(context).primaryColor,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${(download.progress * 100).toStringAsFixed(1)}%',
//                   style: Theme.of(context).textTheme.bodySmall,
//                 ),
//                 Text(
//                   _formatSpeed(download.speed),
//                   style: Theme.of(context).textTheme.bodySmall,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.red,
//                 ),
//                 onPressed: () {
//                   DownloadManager().cancelDownload(download.bookId);
//                 },
//                 child: const Text('CANCEL'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHistoryItem(DownloadProgress download, BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               download.title,
//               style: Theme.of(context).textTheme.titleMedium,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 12),
//             LinearProgressIndicator(
//               value: 1.0, // Completed
//               minHeight: 6,
//               backgroundColor: Colors.grey[200],
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 Colors.green,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Completed',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Colors.green,
//                   ),
//                 ),
//                 Text(
//                   _formatFileSize(download.totalBytes),
//                   style: Theme.of(context).textTheme.bodySmall,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.red,
//                 ),
//                 onPressed: () {
//                   DownloadManager().removeFromHistory(download.bookId);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Removed ${download.title} from history')),
//                   );
//                 },
//                 child: const Text('REMOVE'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _formatSpeed(double bytesPerSecond) {
//     if (bytesPerSecond < 1024) {
//       return '${bytesPerSecond.toStringAsFixed(0)} B/s';
//     } else if (bytesPerSecond < 1024 * 1024) {
//       return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
//     } else {
//       return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
//     }
//   }
//
//   String _formatFileSize(int bytes) {
//     if (bytes < 1024) {
//       return '$bytes B';
//     } else if (bytes < 1024 * 1024) {
//       return '${(bytes / 1024).toStringAsFixed(1)} KB';
//     } else {
//       return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
//     }
//   }
//
//   void _showClearHistoryDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Clear Download History'),
//           content: const Text('Are you sure you want to clear all download history?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('CANCEL'),
//             ),
//             TextButton(
//               onPressed: () {
//                 DownloadManager().clearDownloadHistory();
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Download history cleared')),
//                 );
//               },
//               child: const Text('CLEAR', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }