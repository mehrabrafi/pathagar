class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final String imageUrl;
  final String date;
  final String pdfUrl;
  final String? localPath;
  final String? fileSize;
  final bool isDownloaded;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.imageUrl,
    required this.date,
    required this.pdfUrl,
    this.localPath,
    this.fileSize,
    this.isDownloaded = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category': category,
      'imageUrl': imageUrl,
      'date': date,
      'pdfUrl': pdfUrl,
      'localPath': localPath,
      'fileSize': fileSize,
      'isDownloaded': isDownloaded,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      category: map['category'],
      imageUrl: map['imageUrl'],
      date: map['date'],
      pdfUrl: map['pdfUrl'],
      localPath: map['localPath'],
      fileSize: map['fileSize'],
      isDownloaded: map['isDownloaded'] ?? false,
    );
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? category,
    String? imageUrl,
    String? date,
    String? pdfUrl,
    String? localPath,
    String? fileSize,
    bool? isDownloaded,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      localPath: localPath ?? this.localPath,
      fileSize: fileSize ?? this.fileSize,
      isDownloaded: isDownloaded ?? this.isDownloaded,
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