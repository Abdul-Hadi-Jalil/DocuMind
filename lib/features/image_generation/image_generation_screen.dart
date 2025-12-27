// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageGenerationPage extends StatefulWidget {
  const ImageGenerationPage({super.key});

  @override
  State<ImageGenerationPage> createState() => _ImageGenerationPageState();
}

class _ImageGenerationPageState extends State<ImageGenerationPage> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  bool _hasImage = false;
  Uint8List? _generatedImageBytes;
  String _currentPrompt = '';

  Future<void> _generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedImageBytes = null;
      _hasImage = false;
    });

    try {
      final requestBody = {
        'prompt': prompt,
        'width': 1024,
        'height': 1024,
        'num_inference_steps': 28,
        'negative_prompt': "",
        'seed': -1,
      };

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/generate-image/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('image_b64')) {
          String cleanBase64 = responseData['image_b64'];
          if (cleanBase64.contains(',')) {
            cleanBase64 = cleanBase64.split(',').last;
          }

          final bytes = base64.decode(cleanBase64);

          setState(() {
            _generatedImageBytes = bytes;
            _hasImage = true;
            _currentPrompt = prompt;
          });

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image generated successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          _showError('No image data received from server');
        }
      } else {
        _showError('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _downloadImage() async {
    if (_generatedImageBytes == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download functionality requires additional setup'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _regenerateImage() {
    if (_promptController.text.trim().isNotEmpty) {
      _generateImage();
    } else {
      _showError('Please enter a description first');
    }
  }

  void _clearImage() {
    setState(() {
      _hasImage = false;
      _generatedImageBytes = null;
      _promptController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Navbar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.95),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF00FF88).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FF88), Color(0xFF00D4FF)],
                  ).createShader(bounds),
                  child: const Text(
                    'Froggy AI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Page Title
                const Text(
                  'Image Generation',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Right side buttons
                Row(
                  children: [
                    // Back to Dashboard Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.05),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back, size: 16),
                          SizedBox(width: 8),
                          Text('Dashboard'),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // User Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00FF88), Color(0xFF00D4FF)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'ES',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Input Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description Input
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _promptController,
                              maxLines: 4,
                              minLines: 3,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText:
                                    'Describe the image you want to generate... '
                                    '(e.g., "A serene mountain landscape at sunset '
                                    'with a crystal clear lake")',
                                hintStyle: TextStyle(color: Color(0xFF666666)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20),
                              ),
                              onSubmitted: (value) {
                                if (!_isGenerating) _generateImage();
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Generate Button
                        SizedBox(
                          height: 120,
                          child: ElevatedButton(
                            onPressed: _isGenerating ? null : _generateImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: _isGenerating
                                    ? const LinearGradient(
                                        colors: [Colors.grey, Colors.grey],
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF00FF88),
                                          Color(0xFF00D4FF),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isGenerating
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF00FF88,
                                          ).withOpacity(0.4),
                                          blurRadius: 25,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                              ),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 120,
                                  minHeight: 88,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _isGenerating ? 'Generating...' : 'Generate',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Display Section
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00FF88).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: _isGenerating
                            ? _buildLoadingState()
                            : _hasImage
                            ? _buildImageContainer()
                            : _buildPlaceholder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder Widget
  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎨', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 24),
        const Text(
          'No Image Generated Yet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter a description above and click Generate to create your image',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  // Loading State Widget
  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF88)),
            strokeWidth: 4,
            backgroundColor: const Color(0xFF00FF88).withOpacity(0.1),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Generating Image...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FF88),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'This may take a few moments',
          style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  // Image Container Widget
  Widget _buildImageContainer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Generated Image
        if (_generatedImageBytes != null)
          Container(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF00FF88).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.memory(
                _generatedImageBytes!,
                fit: BoxFit.contain,

                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Image Prompt
        if (_currentPrompt.isNotEmpty)
          SizedBox(
            width: 800,
            child: Text(
              'Prompt: $_currentPrompt',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF888888)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        const SizedBox(height: 24),

        // Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Download Button
            ElevatedButton(
              onPressed: _downloadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.download, size: 18),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Regenerate Button
            ElevatedButton(
              onPressed: _regenerateImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.refresh, size: 18),
                  SizedBox(width: 8),
                  Text('Regenerate'),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Clear Button
            ElevatedButton(
              onPressed: _clearImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 18),
                  SizedBox(width: 8),
                  Text('Clear'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
