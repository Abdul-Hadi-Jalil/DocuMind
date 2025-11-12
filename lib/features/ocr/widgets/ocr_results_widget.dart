import 'package:documind/features/ocr/provider/ocr_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';

class OcrResultsWidget extends StatelessWidget {
  const OcrResultsWidget({super.key});

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
      child: provider.currentResult == null
          ? _buildEmptyState()
          : _buildResultsContent(provider),
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
                color: AppTheme.grey,
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

  Widget _buildResultsContent(OcrProvider provider) {
    final result = provider.currentResult!;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.text_snippet, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.imageName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: provider.clearResult,
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
                result.extractedText,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
