class PdfFile {
  final String id;
  final String name;
  final String path;
  final int size;
  final DateTime uploadDate;
  final String? extractedText;
  final int pageCount;

  const PdfFile({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.uploadDate,
    this.extractedText,
    required this.pageCount,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / 1048576).toStringAsFixed(1)} MB';
  }
}
