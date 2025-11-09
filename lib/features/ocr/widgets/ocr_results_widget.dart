import 'package:documind/core/theme/app_theme.dart';
import 'package:documind/features/ocr/models/ocr_result.dart';
import 'package:documind/features/ocr/provider/ocr_provider.dart';
import 'package:documind/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'image_preview_widget.dart';

class OcrResultsWidget extends StatelessWidget {
  final bool isWeb;

  const OcrResultsWidget({super.key, this.isWeb = false});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OcrProvider>(context);

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
      child: Column(
        children: [
          // Header
          _buildHeader(provider, context),
          const Divider(height: 1),
          // Content
          Expanded(
            child: provider.currentResult == null
                ? _buildEmptyState()
                : _buildResultsContent(provider, context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(OcrProvider provider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.text_snippet, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.currentResult?.imageName ?? 'No Image Selected',
                  style: TextStyle(
                    fontSize: isWeb ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (provider.currentResult != null)
                  Text(
                    'Extracted ${provider.currentResult!.formattedDate}',
                    style: TextStyle(
                      fontSize: isWeb ? 12 : 10,
                      color: AppTheme.grey,
                    ),
                  ),
              ],
            ),
          ),
          if (provider.currentResult != null) ...[
            IconButton(
              icon: const Icon(Icons.image, size: 20),
              onPressed: () =>
                  _showImagePreview(provider.currentResult!, context),
              tooltip: 'Preview Image',
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () => _copyToClipboard(provider.editedText, context),
              tooltip: 'Copy All Text',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.document_scanner,
              size: isWeb ? 64 : 48,
              color: AppTheme.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No OCR Results',
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an image from history or process a new one',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isWeb ? 14 : 12, color: AppTheme.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent(OcrProvider provider, BuildContext context) {
    final result = provider.currentResult!;
    final isEdited = result.confidence == 1.0;

    return Column(
      children: [
        // Image Info and Stats
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              _buildInfoItem(
                'Confidence',
                '${(result.confidence * 100).toStringAsFixed(1)}%',
              ),
              _buildInfoItem('Language', result.language),
              _buildInfoItem('Dimensions', result.imageInfo.dimensions),
              _buildInfoItem('Size', result.imageInfo.formattedSize),
            ],
          ),
        ),
        // Text Editor
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Editor Header
                Row(
                  children: [
                    Text(
                      'Extracted Text ${isEdited ? '(Edited)' : ''}',
                      style: TextStyle(
                        fontSize: isWeb ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (isEdited)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'EDITED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Text Editor
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: TextEditingController(
                        text: provider.editedText,
                      ),
                      onChanged: provider.updateEditedText,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                        hintText: 'Extracted text will appear here...',
                      ),
                      style: TextStyle(fontSize: isWeb ? 14 : 12, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Save Changes',
                        onPressed: provider.editedText != result.extractedText
                            ? provider.saveEditedText
                            : null,
                        isLoading: provider.isProcessing,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Copy Text',
                        onPressed: () =>
                            _copyToClipboard(provider.editedText, context),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isWeb ? 11 : 9,
              color: AppTheme.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isWeb ? 12 : 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(OcrResult result, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ImagePreviewWidget(
        imagePath: result.imagePath,
        imageName: result.imageName,
        isWeb: isWeb,
      ),
    );
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text))
        .then((_) {
          // Show a snackbar instead of toast for better Flutter web compatibility
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Text copied to clipboard!'),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          // Also call the provider method if it handles any additional logic
          final provider = Provider.of<OcrProvider>(context, listen: false);
          provider.copyToClipboard(text);
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to copy: $error'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
  }
}
