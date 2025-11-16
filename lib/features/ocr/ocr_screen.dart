import 'package:documind/core/theme/app_theme.dart';
import 'package:documind/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  bool _showResults = false;

  void _toggleResults() {
    setState(() {
      _showResults = !_showResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('OCR Scanner'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Upload Section
            _buildUploadSection(),
            const SizedBox(height: 24),
            // Results Area
            Expanded(child: _buildResultsContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
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
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.document_scanner,
                  color: AppTheme.primaryGreen,
                  size: 32,
                ),
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
                        color: AppTheme.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Upload images containing text and convert them to editable digital text',
                      style: TextStyle(fontSize: 16, color: AppTheme.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Upload Button
          CustomButton(
            text: _showResults ? 'Upload New Image' : 'Upload Image',
            onPressed: _toggleResults,
            backgroundColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _showResults ? _buildResultsDisplay() : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner, size: 64, color: AppTheme.grey),
            const SizedBox(height: 16),
            Text(
              'No OCR Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.black, // Changed to black for visibility
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload an image to extract text',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsDisplay() {
    const String dummyText = '''
INVOICE #: INV-2024-001
DATE: December 15, 2024
COMPANY: Tech Solutions Inc.

ITEMS:
1. Web Development Services - \$2,500.00
2. Mobile App Development - \$3,200.00
3. UI/UX Design - \$1,800.00

SUBTOTAL: \$7,500.00
TAX (10%): \$750.00
TOTAL: \$8,250.00

Thank you for your business!
This is a demonstration of extracted text from an image.
''';

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.text_snippet, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'sample_image.jpg',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black, // Changed to black
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Text extracted successfully!',
                      style: TextStyle(fontSize: 12, color: AppTheme.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppTheme.black,
                ), // Changed to black
                onPressed: _toggleResults,
                tooltip: 'Clear Results',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Text Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Text(
                dummyText,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppTheme.black, // Explicitly set to black
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
