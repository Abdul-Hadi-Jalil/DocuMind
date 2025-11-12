import 'package:documind/features/ocr/provider/ocr_provider.dart';
import 'package:documind/features/ocr/widgets/ocr_results_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';

class OcrScreen extends StatelessWidget {
  const OcrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('OCR Scanner'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Upload Section
            _UploadSection(),
            SizedBox(height: 24),
            // Results Area
            Expanded(child: OcrResultsWidget()),
          ],
        ),
      ),
    );
  }
}

class _UploadSection extends StatelessWidget {
  const _UploadSection();

  @override
  Widget build(BuildContext context) {
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
            text: 'Upload Image',
            onPressed: provider.isUploading || provider.isProcessing
                ? null
                : () => provider.pickAndProcessImage(),
            isLoading: provider.isUploading || provider.isProcessing,
            backgroundColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}
