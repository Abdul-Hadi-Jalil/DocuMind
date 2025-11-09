class OcrResult {
  final String id;
  final String imagePath;
  final String imageName;
  final String extractedText;
  final DateTime processedAt;
  final double confidence;
  final String language;
  final OcrImageInfo imageInfo;

  const OcrResult({
    required this.id,
    required this.imagePath,
    required this.imageName,
    required this.extractedText,
    required this.processedAt,
    required this.confidence,
    required this.language,
    required this.imageInfo,
  });

  String get formattedDate {
    return '${processedAt.day}/${processedAt.month}/${processedAt.year} ${processedAt.hour}:${processedAt.minute.toString().padLeft(2, '0')}';
  }

  OcrResult copyWith({String? extractedText, double? confidence}) {
    return OcrResult(
      id: id,
      imagePath: imagePath,
      imageName: imageName,
      extractedText: extractedText ?? this.extractedText,
      processedAt: processedAt,
      confidence: confidence ?? this.confidence,
      language: language,
      imageInfo: imageInfo,
    );
  }
}

class OcrImageInfo {
  final int width;
  final int height;
  final int size;
  final String format;

  const OcrImageInfo({
    required this.width,
    required this.height,
    required this.size,
    required this.format,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / 1048576).toStringAsFixed(1)} MB';
  }

  String get dimensions => '${width}x$height';
}
