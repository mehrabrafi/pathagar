// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// class DownloadManager {
//   static final DownloadManager _instance = DownloadManager._internal();
//   factory DownloadManager() => _instance;
//   DownloadManager._internal() {
//     _loadHistory();
//   }
//
//   final Map<String, DownloadProgress> _activeDownloads = {};
//   final List<DownloadProgress> _completedDownloads = [];
//   final StreamController<Map<String, DownloadProgress>> _streamController =
//   StreamController.broadcast();
//
//   Stream<Map<String, DownloadProgress>> get progressStream => _streamController.stream;
//   Map<String, DownloadProgress> get currentDownloads => Map.from(_activeDownloads);
//   List<DownloadProgress> get completedDownloads => List.from(_completedDownloads);
//
//   Future<void> _loadHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     final historyJson = prefs.getString('download_history');
//     if (historyJson != null) {
//       final List<dynamic> historyList = json.decode(historyJson);
//       _completedDownloads.addAll(
//         historyList.map((item) => DownloadProgress.fromJson(item)).toList(),
//       );
//     }
//   }
//
//   Future<void> _saveHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     final historyJson = json.encode(
//       _completedDownloads.map((d) => d.toJson()).toList(),
//     );
//     await prefs.setString('download_history', historyJson);
//   }
//
//   void addDownload(String bookId, String title, {int totalBytes = 0}) {
//     if (!_activeDownloads.containsKey(bookId)) {
//       _activeDownloads[bookId] = DownloadProgress(
//         bookId: bookId,
//         title: title,
//         progress: 0,
//         speed: 0,
//         totalBytes: totalBytes,
//         isDownloading: true,
//       );
//       _streamController.add(Map.from(_activeDownloads));
//     }
//   }
//
//   void updateProgress(String bookId, double progress, double speed, {int? downloadedBytes}) {
//     if (_activeDownloads.containsKey(bookId)) {
//       var current = _activeDownloads[bookId]!;
//       _activeDownloads[bookId] = current.copyWith(
//         progress: progress,
//         speed: speed,
//         downloadedBytes: downloadedBytes ?? current.downloadedBytes,
//       );
//       _streamController.add(Map.from(_activeDownloads));
//     }
//   }
//
//   void completeDownload(String bookId) {
//     if (_activeDownloads.containsKey(bookId)) {
//       final completed = _activeDownloads[bookId]!;
//       _activeDownloads.remove(bookId);
//       _completedDownloads.add(completed.copyWith(
//         isDownloading: false,
//         progress: 1.0,
//         speed: 0,
//       ));
//       _saveHistory();
//       _streamController.add(Map.from(_activeDownloads));
//     }
//   }
//
//   void cancelDownload(String bookId) {
//     if (_activeDownloads.containsKey(bookId)) {
//       _activeDownloads.remove(bookId);
//       _streamController.add(Map.from(_activeDownloads));
//     }
//   }
//
//   void removeFromHistory(String bookId) {
//     _completedDownloads.removeWhere((d) => d.bookId == bookId);
//     _saveHistory();
//   }
//
//   void clearDownloadHistory() {
//     _completedDownloads.clear();
//     _saveHistory();
//   }
//
//   void clearAllDownloads() {
//     _activeDownloads.clear();
//     _streamController.add(Map.from(_activeDownloads));
//   }
// }
//
// class DownloadProgress {
//   final String bookId;
//   final String title;
//   final double progress;
//   final double speed;
//   final bool isDownloading;
//   final int totalBytes;
//   final int downloadedBytes;
//
//   DownloadProgress({
//     required this.bookId,
//     required this.title,
//     required this.progress,
//     required this.speed,
//     required this.isDownloading,
//     this.totalBytes = 0,
//     this.downloadedBytes = 0,
//   });
//
//   factory DownloadProgress.fromJson(Map<String, dynamic> json) {
//     return DownloadProgress(
//       bookId: json['bookId'],
//       title: json['title'],
//       progress: json['progress'],
//       speed: json['speed'],
//       isDownloading: json['isDownloading'],
//       totalBytes: json['totalBytes'],
//       downloadedBytes: json['downloadedBytes'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'bookId': bookId,
//       'title': title,
//       'progress': progress,
//       'speed': speed,
//       'isDownloading': isDownloading,
//       'totalBytes': totalBytes,
//       'downloadedBytes': downloadedBytes,
//     };
//   }
//
//   DownloadProgress copyWith({
//     String? title,
//     double? progress,
//     double? speed,
//     bool? isDownloading,
//     int? totalBytes,
//     int? downloadedBytes,
//   }) {
//     return DownloadProgress(
//       bookId: bookId,
//       title: title ?? this.title,
//       progress: progress ?? this.progress,
//       speed: speed ?? this.speed,
//       isDownloading: isDownloading ?? this.isDownloading,
//       totalBytes: totalBytes ?? this.totalBytes,
//       downloadedBytes: downloadedBytes ?? this.downloadedBytes,
//     );
//   }
// }