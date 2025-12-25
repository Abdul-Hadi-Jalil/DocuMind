import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// Model to store OCR result from backend
class OcrResult {
  final String? contentType;
  final String? extractedText;

  OcrResult({this.contentType, this.extractedText});

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      contentType: json['content_type'],
      extractedText: json['extracted_text'],
    );
  }
}

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  // Variables to store image and its bytes
  XFile? selectedImage;
  Uint8List? imageBytes;

  // Variable to store OCR result from backend
  OcrResult? backendResult;

  // Variables for loading states
  bool isLoading = false;
  bool isUploading = false;

  // Function to pick image, convert to bytes, and send to backend
  Future<void> pickAndSendImage() async {
    try {
      // Step 1: Pick image from gallery
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress image for faster upload
      );

      if (pickedFile == null) {
        // User cancelled the picker
        return;
      }

      // Step 2: Update UI with selected image
      setState(() {
        selectedImage = pickedFile;
        imageBytes = null;
        backendResult = null; // Clear previous result
        isLoading = true; // Show loading while converting
      });

      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Image selected successfully'),
            backgroundColor: Color(0xFF00ff88),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Step 3: Convert image to bytes
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        imageBytes = bytes;
        isLoading = false;
        isUploading = true; // Show uploading state
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Image converted to bytes'),
            backgroundColor: Color(0xFF00ff88),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Step 4: Send image to backend
      if (imageBytes != null) {
        // URL of your backend endpoint
        const String backendUrl = "http://127.0.0.1:8000/upload-image/";

        try {
          // Create multipart request
          var request = http.MultipartRequest('POST', Uri.parse(backendUrl));

          // Add image file to the request
          request.files.add(
            http.MultipartFile.fromBytes(
              'file', // Field name (must match backend expectation)
              imageBytes!,
              filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          );

          // Show uploading snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('📤 Sending image to backend...'),
                duration: Duration(seconds: 2),
              ),
            );
          }

          // Send request and get response
          var response = await request.send();
          debugPrint('Response status: ${response.statusCode}');

          // Handle different response statuses
          if (response.statusCode == 200) {
            // Success: Parse the response
            var responseData = await response.stream.bytesToString();
            var jsonResponse = jsonDecode(responseData);

            // Convert JSON to OcrResult object
            OcrResult result = OcrResult.fromJson(jsonResponse);

            // Update UI with OCR result
            setState(() {
              backendResult = result;
              isUploading = false;
            });

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Text extracted successfully!'),
                  backgroundColor: const Color(0xFF00ff88),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'COPY',
                    textColor: Colors.black,
                    onPressed: () {
                      _copyToClipboard(result.extractedText ?? '');
                    },
                  ),
                ),
              );
            }

            // Debug print the results
            debugPrint("Content Type: ${result.contentType}");
            debugPrint(
              "Extracted Text Length: ${result.extractedText?.length ?? 0} characters",
            );
          } else if (response.statusCode == 422) {
            // Validation error (common: wrong field name or file format)
            setState(() {
              isUploading = false;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '❌ Validation error. Check field name or file format.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            }
            debugPrint(
              'Validation error - check field name or backend requirements',
            );
          } else if (response.statusCode == 404) {
            // Endpoint not found
            setState(() {
              isUploading = false;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Backend endpoint not found. Check URL.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            // Other server errors
            setState(() {
              isUploading = false;
            });

            throw Exception(
              'Upload failed with status: ${response.statusCode}',
            );
          }
        } catch (e) {
          // Network or request errors
          setState(() {
            isUploading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Network error: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          debugPrint('Error sending to backend: $e');
        }
      }
    } catch (e) {
      // Handle any errors in the process
      setState(() {
        isLoading = false;
        isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      debugPrint('Error in pickAndSendImage: $e');
    }
  }

  // Function to copy text to clipboard
  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Text copied to clipboard!'),
          backgroundColor: Color(0xFF00ff88),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // Function to remove selected image
  void _removeImage() {
    setState(() {
      selectedImage = null;
      imageBytes = null;
      backendResult = null;
      isLoading = false;
      isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Image removed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Function to calculate text statistics
  Map<String, int> _calculateTextStats(String text) {
    final chars = text.length;
    final words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    final lines = text.split('\n').length;

    return {'chars': chars, 'words': words, 'lines': lines};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.remove_red_eye, color: Color(0xFF00ff88)),
            const SizedBox(width: 10),
            Text(
              'Froggy AI OCR',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF00ff88)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1a1a1a),
                  title: const Text(
                    'How to Use',
                    style: TextStyle(color: Color(0xFF00ff88)),
                  ),
                  content: const Text(
                    '1. Tap "Upload Image" button\n'
                    '2. Select an image from gallery\n'
                    '3. Image will be sent to backend\n'
                    '4. View extracted text\n'
                    '5. Copy text to clipboard',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Color(0xFF00ff88)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Upload Section
            Expanded(
              flex: 2,
              child: Card(
                child: InkWell(
                  onTap: selectedImage == null ? pickAndSendImage : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: selectedImage == null
                          ? Border.all(color: const Color(0xFF00ff88), width: 2)
                          : null,
                    ),
                    child: Center(child: _buildImageSection()),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Extract Button (only show when image is selected)
            if (selectedImage != null && !isUploading)
              ElevatedButton(
                onPressed: () {
                  // Resend the image to backend
                  pickAndSendImage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ff88),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.black),
                          SizedBox(width: 10),
                          Text('Processing Image...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.text_fields),
                          SizedBox(width: 10),
                          Text(
                            'EXTRACT TEXT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),

            // Uploading Indicator
            if (isUploading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF00ff88)),
                    const SizedBox(height: 10),
                    Text(
                      'Uploading to backend...',
                      style: TextStyle(
                        color: const Color(0xFF00ff88),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Results Section
            Expanded(flex: 3, child: _buildResultsSection()),
          ],
        ),
      ),
    );
  }

  // Build the image upload/preview section
  Widget _buildImageSection() {
    if (selectedImage == null) {
      // Show upload placeholder
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload, size: 80, color: Color(0xFF00ff88)),
          SizedBox(height: 16),
          Text(
            'Upload Image',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00ff88),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap to select image from gallery',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 4),
          Text(
            'Supports: JPG, PNG, WEBP',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      );
    } else {
      // Show image preview
      return Stack(
        children: [
          // Image preview
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imageBytes != null
                  ? Image.memory(imageBytes!, fit: BoxFit.contain)
                  : FutureBuilder(
                      future: selectedImage!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
            ),
          ),

          // Remove button
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black.withOpacity(0.7),
              foregroundColor: Colors.white,
              onPressed: _removeImage,
              child: const Icon(Icons.delete),
            ),
          ),

          // Image info overlay
          if (selectedImage != null)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  selectedImage!.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    }
  }

  // Build the results display section
  Widget _buildResultsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Extracted Text',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00ff88),
                  ),
                ),
                if (backendResult != null &&
                    backendResult!.extractedText != null)
                  ElevatedButton.icon(
                    onPressed: () =>
                        _copyToClipboard(backendResult!.extractedText!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1a1a1a),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white24),
                      ),
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('COPY TEXT'),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Results content
            Expanded(child: _buildResultsContent()),

            // Statistics (only show when there's text)
            if (backendResult != null &&
                backendResult!.extractedText != null &&
                backendResult!.extractedText!.isNotEmpty)
              _buildStatistics(),
          ],
        ),
      ),
    );
  }

  // Build the results content area
  Widget _buildResultsContent() {
    if (isUploading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF00ff88)),
            SizedBox(height: 16),
            Text(
              'Extracting text from image...',
              style: TextStyle(color: Color(0xFF00ff88)),
            ),
            SizedBox(height: 8),
            Text(
              'Sending to OCR backend',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (backendResult == null || backendResult!.extractedText == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No text extracted yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Upload an image and click "Extract Text"',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (backendResult!.extractedText!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 80, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'No text found in image',
              style: TextStyle(fontSize: 18, color: Colors.orange),
            ),
            SizedBox(height: 8),
            Text(
              'The OCR backend did not detect any text',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show extracted text
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: SelectableText(
            backendResult!.extractedText!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Build statistics widget
  Widget _buildStatistics() {
    if (backendResult == null || backendResult!.extractedText == null) {
      return const SizedBox();
    }

    final stats = _calculateTextStats(backendResult!.extractedText!);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00ff88).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00ff88).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('📝', 'Characters', stats['chars']?.toString() ?? '0'),
          _buildStatItem('📄', 'Words', stats['words']?.toString() ?? '0'),
          _buildStatItem('↕️', 'Lines', stats['lines']?.toString() ?? '0'),
        ],
      ),
    );
  }

  // Build individual statistic item
  Widget _buildStatItem(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00ff88),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
