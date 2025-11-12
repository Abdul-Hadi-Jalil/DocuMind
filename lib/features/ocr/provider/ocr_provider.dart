import 'package:flutter/foundation.dart';
import '../models/ocr_result.dart';

class OcrProvider with ChangeNotifier {
  OcrResult? _currentResult;
  bool _isProcessing = false;
  bool _isUploading = false;

  OcrResult? get currentResult => _currentResult;
  bool get isProcessing => _isProcessing;
  bool get isUploading => _isUploading;

  Future<void> pickAndProcessImage() async {
    _isUploading = true;
    notifyListeners();

    // TODO: Implement actual image picker
    await Future.delayed(const Duration(seconds: 1));

    _isUploading = false;
    _isProcessing = true;
    notifyListeners();

    // TODO: Implement actual OCR processing
    await Future.delayed(const Duration(seconds: 2));

    // Mock result - replace with actual implementation
    _currentResult = OcrResult(
      imagePath: 'mock_path',
      imageName: 'sample_image.jpg',
      extractedText: 'This is sample extracted text from the image.',
    );

    _isProcessing = false;
    notifyListeners();
  }

  void clearResult() {
    _currentResult = null;
    notifyListeners();
  }
}
