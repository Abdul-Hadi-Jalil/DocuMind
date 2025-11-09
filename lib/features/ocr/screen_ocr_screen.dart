import 'package:documind/features/ocr/provider/ocr_provider.dart';
import 'package:documind/features/ocr/widgets/ocr_history_widget.dart';
import 'package:documind/features/ocr/widgets/ocr_results_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  @override
  void initState() {
    super.initState();
    // Clear any previous errors when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OcrProvider>(context, listen: false).clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('OCR Scanner'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      body: Padding(
        padding: isDesktop
            ? const EdgeInsets.all(24)
            : const EdgeInsets.all(16),
        child: Column(
          children: [
            // Upload Section
            _buildUploadSection(isDesktop),
            const SizedBox(height: 24),
            // Main Content
            Expanded(
              child: isDesktop ? _buildWebLayout() : _buildMobileLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection(bool isDesktop) {
    final provider = Provider.of<OcrProvider>(context);

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extract Text from Images',
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload images containing text and convert them to editable digital text',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Upload Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Upload from Gallery',
                  onPressed: provider.isUploading || provider.isProcessing
                      ? null
                      : () => provider.pickAndProcessImage(),
                  isLoading: provider.isUploading,
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Capture with Camera',
                  onPressed: provider.isUploading || provider.isProcessing
                      ? null
                      : () => provider.captureAndProcessImage(),
                  isLoading: provider.isUploading,
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
          // Processing Indicator
          if (provider.isProcessing) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Processing image and extracting text...',
                  style: TextStyle(
                    color: AppTheme.grey,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // History Sidebar
        SizedBox(width: 320, child: OcrHistoryWidget(isWeb: true)),
        const SizedBox(width: 24),
        // Results Area
        Expanded(child: OcrResultsWidget(isWeb: true)),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // History
        Expanded(flex: 2, child: OcrHistoryWidget(isWeb: false)),
        const SizedBox(height: 16),
        // Results
        Expanded(flex: 3, child: OcrResultsWidget(isWeb: false)),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OCR Scanner Help'),
        content: const SingleChildScrollView(
          child: Text('''
How to use OCR Scanner:

1. **Upload Images**: Use "Upload from Gallery" to select images from your device or "Capture with Camera" to take new photos.

2. **Process Text**: The AI will automatically extract text from your images. Processing takes a few seconds.

3. **Review Results**: View extracted text in the editor. The system shows confidence scores for accuracy.

4. **Edit Text**: You can manually edit the extracted text if needed.

5. **Save & Copy**: Save your edits or copy the text to clipboard for use in other apps.

Supported Image Types:
- JPEG, PNG, WebP
- Maximum size: 10MB
- Clear, well-lit images work best

Tips for Better Results:
- Use high-resolution images
- Ensure text is clearly visible
- Avoid shadows and glare
- Straighten crooked images
'''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
