class OcrResult {
  final String imagePath;
  final String imageName;
  final String extractedText;

  const OcrResult({
    required this.imagePath,
    required this.imageName,
    required this.extractedText,
  });
}
