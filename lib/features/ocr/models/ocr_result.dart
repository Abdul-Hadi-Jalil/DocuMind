class OcrResult {
  final String extractedText;
  final String contentType;

  OcrResult({required this.extractedText, required this.contentType});

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      extractedText: json['extracted_text'] ?? '',
      contentType: json['content_type'] ?? '',
    );
  }
}
