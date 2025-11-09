import 'package:documind/core/theme/app_theme.dart';
import 'package:documind/features/ocr/models/ocr_result.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OcrProvider with ChangeNotifier {
  final List<OcrResult> _ocrHistory = [];
  OcrResult? _currentResult;
  bool _isProcessing = false;
  bool _isUploading = false;
  String _errorMessage = '';
  String _editedText = '';

  List<OcrResult> get ocrHistory => _ocrHistory;
  OcrResult? get currentResult => _currentResult;
  bool get isProcessing => _isProcessing;
  bool get isUploading => _isUploading;
  String get errorMessage => _errorMessage;
  String get editedText => _editedText;

  Future<void> pickAndProcessImage() async {
    try {
      _isUploading = true;
      _errorMessage = '';
      notifyListeners();

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: ${e.toString()}';
      _showErrorToast(_errorMessage);
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> captureAndProcessImage() async {
    try {
      _isUploading = true;
      _errorMessage = '';
      notifyListeners();

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      _errorMessage = 'Failed to capture image: ${e.toString()}';
      _showErrorToast(_errorMessage);
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> _processImage(XFile image) async {
    try {
      _isProcessing = true;
      notifyListeners();

      // Simulate OCR processing delay
      await Future.delayed(const Duration(seconds: 3));

      // Mock image info
      final imageInfo = OcrImageInfo(
        width: 1920,
        height: 1080,
        size: await image.length(),
        format: image.path.split('.').last.toUpperCase(),
      );

      // Mock OCR result with different text based on image name
      final mockText = _generateMockOcrText(image.name);

      final result = OcrResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: image.path,
        imageName: image.name,
        extractedText: mockText,
        processedAt: DateTime.now(),
        confidence:
            0.85 +
            (DateTime.now().millisecond % 100) /
                1000, // Random confidence 0.85-0.95
        language: 'English',
        imageInfo: imageInfo,
      );

      _currentResult = result;
      _editedText = mockText;
      _ocrHistory.insert(0, result);

      _showSuccessToast('Text extracted successfully!');
    } catch (e) {
      _errorMessage = 'OCR processing failed: ${e.toString()}';
      _showErrorToast(_errorMessage);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  String _generateMockOcrText(String imageName) {
    if (imageName.toLowerCase().contains('receipt')) {
      return '''
STORE RECEIPT
=============

SuperMart Grocery Store
123 Main Street, Cityville
Phone: (555) 123-4567

Date: 15/12/2024
Time: 14:30
Receipt #: 789456123

ITEMS:
-------
1. Milk 2L              \$3.99
2. Bread Whole Wheat   \$2.49
3. Eggs Large 12pk      \$4.99
4. Apples 1kg          \$5.99
5. Chicken Breast 500g  \$8.49

SUBTOTAL:              \$25.95
TAX (8%):              \$2.08
TOTAL:                 \$28.03

Payment: Credit Card
Card: **** **** **** 1234

Thank you for shopping with us!
Please keep this receipt for returns.
''';
    } else if (imageName.toLowerCase().contains('document')) {
      return '''
BUSINESS PROPOSAL

To: John Smith, CEO
From: Sarah Johnson, Marketing Director
Date: December 15, 2024

Subject: Q1 2025 Marketing Strategy Proposal

Executive Summary:
This proposal outlines our marketing strategy for Q1 2025, focusing on digital transformation and customer engagement.

Key Objectives:
1. Increase brand awareness by 25%
2. Grow social media following by 15,000
3. Generate 500 qualified leads monthly
4. Improve customer retention by 10%

Budget Allocation:
- Digital Advertising: \$50,000
- Content Marketing: \$25,000
- Social Media: \$15,000
- Analytics Tools: \$5,000
- Contingency: \$5,000

Total Budget: \$100,000

Expected ROI: 3:1

We believe this strategy will position us for significant growth in 2025.
''';
    } else if (imageName.toLowerCase().contains('book')) {
      return '''
Page 42 - The Art of Programming

CHAPTER 3: DATA STRUCTURES

Arrays are the most fundamental data structure in computer science. They provide O(1) access time but have fixed size.

Linked lists offer dynamic sizing but require O(n) access time. They consist of nodes containing data and pointers.

Key Points:
- Use arrays when size is known and random access is needed
- Use linked lists for frequent insertions/deletions
- Consider time and space complexity for each operation

Example Code:

class Node {
  int data;
  Node next;
  
  Node(this.data);
}

void main() {
  Node head = Node(1);
  head.next = Node(2);
  head.next.next = Node(3);
}
''';
    } else {
      return '''
EXTRACTED TEXT FROM IMAGE

This is a sample of text extracted using Optical Character Recognition (OCR) technology. The OCR system has analyzed the image and converted the visual text into editable digital text.

Key Features of OCR:
- Converts images of text into machine-readable text
- Supports multiple languages and fonts
- Maintains text formatting and structure
- Enables text editing and copying

Common Use Cases:
1. Digitizing printed documents
2. Extracting text from photos
3. Automated data entry
4. Document archiving and search

Accuracy may vary based on:
- Image quality and resolution
- Text font and size
- Background complexity
- Language and character set

This extracted text can now be edited, copied, or saved for further use.
''';
    }
  }

  void updateEditedText(String text) {
    _editedText = text;
    notifyListeners();
  }

  void saveEditedText() {
    if (_currentResult != null && _editedText.isNotEmpty) {
      final updatedResult = _currentResult!.copyWith(
        extractedText: _editedText,
        confidence: 1.0, // Mark as manually edited
      );

      _currentResult = updatedResult;

      // Update in history
      final index = _ocrHistory.indexWhere((r) => r.id == _currentResult!.id);
      if (index != -1) {
        _ocrHistory[index] = updatedResult;
      }

      _showSuccessToast('Text saved successfully!');
      notifyListeners();
    }
  }

  void copyToClipboard(String text) {
    // This will be handled by the UI with copy_to_clipboard package
    _showSuccessToast('Text copied to clipboard!');
  }

  void selectResult(OcrResult result) {
    _currentResult = result;
    _editedText = result.extractedText;
    notifyListeners();
  }

  void deleteResult(OcrResult result) {
    _ocrHistory.remove(result);
    if (_currentResult?.id == result.id) {
      _currentResult = null;
      _editedText = '';
    }
    _showSuccessToast('Result deleted');
    notifyListeners();
  }

  void clearAllHistory() {
    _ocrHistory.clear();
    _currentResult = null;
    _editedText = '';
    _showSuccessToast('All history cleared');
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.primaryGreen,
      textColor: AppTheme.white,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: AppTheme.white,
    );
  }
}
