import 'dart:convert';
import 'dart:typed_data';
import 'package:documind/features/ocr/models/ocr_result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  // varaibles used in pickAndSendImage funcition
  XFile? selectedImage;
  Uint8List? imageBytes;
  OcrResult? backendResult;

  // function to pick image convert to bytes and send to backend
  Future<void> pickAndSendImage() async {
    try {
      final picker = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picker != null) {
        setState(() {
          selectedImage = picker;
          imageBytes = null; // Reset bytes when new image is selected
        });

        // Use mounted check before using context
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image is successfully selected'),
              duration: Duration(milliseconds: 500),
            ),
          );
        }

        final bytes = await selectedImage!.readAsBytes();
        setState(() {
          imageBytes = bytes;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image is converted to bytes'),
              duration: Duration(milliseconds: 500),
            ),
          );
        }
        if (imageBytes != null) {
          // url of backend
          const String backendUrl = "http://127.0.0.1:8000/upload-image/";

          // Create multipart request
          var request = http.MultipartRequest('POST', Uri.parse(backendUrl));

          // Add image file
          request.files.add(
            http.MultipartFile.fromBytes(
              'file', // Field name (should match your backend expectation)
              imageBytes!,
              filename:
                  'image_${DateTime.now().millisecondsSinceEpoch}.jpg', // this line is important to run the code
            ),
          );

          var response = await request.send();

          debugPrint('Response status: ${response.statusCode}');

          if (response.statusCode == 200) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Upload successful!'),
                  duration: Duration(seconds: 1),
                ),
              );
              // display the extracted text
              var responseData = await response.stream.bytesToString();
              var jsonResponse = jsonDecode(responseData);

              OcrResult result = OcrResult.fromJson(jsonResponse);

              debugPrint("Content Type: ${result.contentType}");
              debugPrint("Extracted Text: ${result.extractedText}");

              setState(() {
                backendResult = result;
              });
            }
          } else if (response.statusCode == 422) {
            // Validation error - might be wrong field name
            debugPrint('Validation error - check field name');

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wrong field name? Check backend.'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          } else {
            throw Exception(
              'Upload failed with status: ${response.statusCode}',
            );
          }

          // message to show if image is successfully sended to backend
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sending image to backend...'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Upload Section
            _buildUploadSection(),
            const SizedBox(height: 24),

            // Results Area
            _buildResultArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: const Icon(Icons.document_scanner, size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extract Text from Images',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Upload images containing text and convert them to editable digital text',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Upload Button
        ],
      ),
    );
  }

  Widget _buildResultArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SelectableText(
        backendResult?.extractedText ?? "No Extracted Text",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
