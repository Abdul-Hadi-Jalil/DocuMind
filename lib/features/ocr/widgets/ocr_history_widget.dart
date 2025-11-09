import 'dart:io';

import 'package:documind/core/theme/app_theme.dart';
import 'package:documind/features/ocr/models/ocr_result.dart';
import 'package:documind/features/ocr/provider/ocr_provider.dart';
import 'package:documind/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OcrHistoryWidget extends StatelessWidget {
  final bool isWeb;

  const OcrHistoryWidget({super.key, this.isWeb = false});

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'OCR History',
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${provider.ocrHistory.length} items',
                  style: TextStyle(
                    color: AppTheme.grey,
                    fontSize: isWeb ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Clear All Button
          if (provider.ocrHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: 'Clear All History',
                onPressed: () => _showClearAllDialog(context, provider),
                backgroundColor: Colors.red,
              ),
            ),
          // History List
          Expanded(
            child: provider.ocrHistory.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: provider.ocrHistory.length,
                    itemBuilder: (context, index) {
                      final result = provider.ocrHistory[index];
                      return _buildHistoryItem(result, provider, context);
                    },
                  ),
          ),
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
              Icons.history_toggle_off,
              size: isWeb ? 64 : 48,
              color: AppTheme.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No OCR History',
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Process some images to see them here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isWeb ? 14 : 12, color: AppTheme.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    OcrResult result,
    OcrProvider provider,
    BuildContext context,
  ) {
    final isSelected = provider.currentResult?.id == result.id;
    final isEdited = result.confidence == 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryGreen.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            image: DecorationImage(
              image: FileImage(File(result.imagePath)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          result.imageName,
          style: TextStyle(
            fontSize: isWeb ? 14 : 12,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.text_snippet,
                  size: isWeb ? 12 : 10,
                  color: AppTheme.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${result.extractedText.split(' ').length} words',
                  style: TextStyle(
                    fontSize: isWeb ? 11 : 9,
                    color: AppTheme.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.schedule,
                  size: isWeb ? 12 : 10,
                  color: AppTheme.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  result.formattedDate,
                  style: TextStyle(
                    fontSize: isWeb ? 11 : 9,
                    color: AppTheme.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isEdited ? Colors.orange : AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isEdited
                        ? 'EDITED'
                        : '${(result.confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: isWeb ? 10 : 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  result.language,
                  style: TextStyle(
                    fontSize: isWeb ? 10 : 8,
                    color: AppTheme.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: isWeb ? 10 : 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete, size: 16),
              onPressed: () => _showDeleteDialog(result, provider, context),
              color: Colors.red,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        onTap: () => provider.selectResult(result),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  void _showDeleteDialog(
    OcrResult result,
    OcrProvider provider,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete OCR Result'),
        content: Text('Are you sure you want to delete "${result.imageName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteResult(result);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, OcrProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to clear all OCR history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
