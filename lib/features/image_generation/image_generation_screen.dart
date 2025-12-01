import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_theme.dart';

class ImageGenerationScreen extends StatefulWidget {
  const ImageGenerationScreen({super.key});

  @override
  State<ImageGenerationScreen> createState() => _ImageGenerationScreenState();
}

class _ImageGenerationScreenState extends State<ImageGenerationScreen> {
  // controller to send the prompt to backend to generate image
  TextEditingController userPrompt = TextEditingController();
  bool _isGenerating = false;
  Uint8List? _generatedImageBytes;

  Future<void> generateImage() async {
    final prompt = userPrompt.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedImageBytes = null; // Clear previous image
    });

    try {
      // Prepare the request body
      final requestBody = {
        'prompt': prompt,
        'width': 1024,
        'height': 1024,
        'num_inference_steps': 28,
        'negative_prompt': "",
        'seed': -1,
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/generate-image/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check response status
      if (response.statusCode == 200) {
        // Parse the response
        final responseData = jsonDecode(response.body);

        // Extract the base64 image data
        if (responseData.containsKey('image_b64')) {
          final base64String = responseData['image_b64'];

          // Handle data URL format if present (data:image/png;base64,...)
          String cleanBase64 = base64String;
          if (base64String.contains(',')) {
            cleanBase64 = base64String.split(',').last;
          }

          // Decode base64 to bytes
          final bytes = base64.decode(cleanBase64);

          setState(() {
            _generatedImageBytes = bytes;
          });

          // Optional: Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Image generated successfully!'),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Show error if image_b64 is missing
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No image data received from server'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Show HTTP error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${response.statusCode}: ${response.body}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show general error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('AI Image Generation'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
      ),
      body: Column(
        children: [
          // Image Display Section - Takes most of the screen
          Expanded(child: _buildImageDisplay()),
          // Prompt Input Section - Fixed at bottom
          _buildPromptInputSection(),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
          const Text(
            'AI Generated Image',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Describe what you want to create',
            style: TextStyle(fontSize: 16, color: AppTheme.grey),
          ),
          const SizedBox(height: 32),

          // Image Container
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isGenerating
                    ? _buildLoadingState()
                    : _buildImageContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    // Check if we have generated image bytes
    if (_generatedImageBytes != null) {
      // Display the generated image
      return Image.memory(
        _generatedImageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // If there's an error displaying the image, show placeholder
          return _buildPlaceholder(
            title: 'Failed to Display Image',
            message: 'The generated image could not be displayed',
          );
        },
      );
    } else {
      // No image generated yet, show placeholder
      return _buildPlaceholder();
    }
  }

  Widget _buildLoadingState() {
    return Container(
      color: AppTheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryGreen),
          const SizedBox(height: 24),
          Text(
            'Generating image...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({String? title, String? message}) {
    return Container(
      color: AppTheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 80,
              color: AppTheme.primaryGreen.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title ?? 'No Image Generated Yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message ??
                  'Type a description below and click the send button to generate your AI image',
              style: const TextStyle(fontSize: 14, color: AppTheme.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: userPrompt,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(color: AppTheme.black),
                      decoration: const InputDecoration(
                        hintText: 'Describe the image you want to generate...',
                        hintStyle: TextStyle(color: AppTheme.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => generateImage(),
                    ),
                  ),
                  if (_isGenerating)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen,
                  AppTheme.primaryGreen.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _isGenerating ? null : generateImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.send_rounded,
                    color: AppTheme.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
