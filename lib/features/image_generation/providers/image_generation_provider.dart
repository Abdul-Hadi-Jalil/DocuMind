import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/theme/app_theme.dart';
import '../models/generated_image.dart';

class ImageGenerationProvider with ChangeNotifier {
  final List<GeneratedImage> _generatedImages = [];
  GeneratedImage? _selectedImage;
  bool _isGenerating = false;
  String _errorMessage = '';
  String _currentPrompt = '';
  ImageGenerationParameters _parameters = const ImageGenerationParameters();

  List<GeneratedImage> get generatedImages => _generatedImages;
  GeneratedImage? get selectedImage => _selectedImage;
  bool get isGenerating => _isGenerating;
  String get errorMessage => _errorMessage;
  String get currentPrompt => _currentPrompt;
  ImageGenerationParameters get parameters => _parameters;

  // Mock image URLs for demonstration
  final List<String> _mockImageUrls = [
    'https://images.unsplash.com/photo-1579546929662-711aa81148cf?w=400',
    'https://images.unsplash.com/photo-1551963831-b3b1ca40c98e?w=400',
    'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400',
    'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
    'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?w=400',
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400',
  ];

  Future<void> generateImage(String prompt) async {
    if (prompt.trim().isEmpty) {
      _errorMessage = 'Please enter a prompt';
      notifyListeners();
      return;
    }

    try {
      _isGenerating = true;
      _errorMessage = '';
      _currentPrompt = prompt;
      notifyListeners();

      // Simulate AI image generation delay
      await Future.delayed(const Duration(seconds: 5));

      // Create mock generated image
      final newImage = GeneratedImage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        prompt: prompt,
        imageUrl: _getRandomMockImageUrl(),
        generatedAt: DateTime.now(),
        parameters: _parameters,
      );

      _generatedImages.insert(0, newImage);
      _selectedImage = newImage;

      _showSuccessToast('Image generated successfully!');
    } catch (e) {
      _errorMessage = 'Image generation failed: ${e.toString()}';
      _showErrorToast(_errorMessage);
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  String _getRandomMockImageUrl() {
    final randomIndex = DateTime.now().millisecond % _mockImageUrls.length;
    return '${_mockImageUrls[randomIndex]}&t=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> downloadImage(GeneratedImage image) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _showErrorToast('Storage permission is required to save images');
        return;
      }

      // In a real app, we would download the actual image from the URL
      // For demo, we'll simulate download success
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful download
      final index = _generatedImages.indexWhere((img) => img.id == image.id);
      if (index != -1) {
        final updatedImage = image.copyWith(
          localPath: '/storage/emulated/0/Download/${image.id}.jpg',
        );
        _generatedImages[index] = updatedImage;

        if (_selectedImage?.id == image.id) {
          _selectedImage = updatedImage;
        }
      }

      _showSuccessToast('Image saved to gallery!');
      notifyListeners();
    } catch (e) {
      _showErrorToast('Failed to save image: ${e.toString()}');
    }
  }

  void updateParameters(ImageGenerationParameters newParameters) {
    _parameters = newParameters;
    notifyListeners();
  }

  void updatePrompt(String prompt) {
    _currentPrompt = prompt;
  }

  void selectImage(GeneratedImage image) {
    _selectedImage = image;
    notifyListeners();
  }

  void deleteImage(GeneratedImage image) {
    _generatedImages.remove(image);
    if (_selectedImage?.id == image.id) {
      _selectedImage = null;
    }
    _showSuccessToast('Image deleted');
    notifyListeners();
  }

  void clearAllHistory() {
    _generatedImages.clear();
    _selectedImage = null;
    _currentPrompt = '';
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
