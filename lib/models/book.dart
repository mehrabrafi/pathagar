class Book {
  final String title;
  final String author;
  final String category;
  final String imageUrl;
  final String date;
  final String pdfUrl;
  String? localPath;
  String? fileSize;
  String id;
  bool isDownloaded;

  Book({
    required this.title,
    required this.author,
    required this.category,
    required this.imageUrl,
    required this.date,
    required this.pdfUrl,
    this.localPath,
    this.fileSize,
    String? id,
    this.isDownloaded = false,
  }) : id = id ?? '${title}_${author}_${DateTime.now().millisecondsSinceEpoch}';

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'category': category,
      'imageUrl': imageUrl,
      'date': date,
      'pdfUrl': pdfUrl,
      'localPath': localPath,
      'fileSize': fileSize,
      'id': id,
      'isDownloaded': isDownloaded,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      title: map['title'],
      author: map['author'],
      category: map['category'],
      imageUrl: map['imageUrl'],
      date: map['date'],
      pdfUrl: map['pdfUrl'],
      localPath: map['localPath'],
      fileSize: map['fileSize'],
      id: map['id'],
      isDownloaded: map['isDownloaded'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Book &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}