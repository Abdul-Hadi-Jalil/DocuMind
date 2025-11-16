import 'package:documind/core/theme/app_theme.dart';
import 'package:documind/features/pdf_chat/models/pdf_file.dart';
import 'package:documind/features/pdf_chat/providers/pdf_chat_providers.dart';
import 'package:documind/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PdfListWidget extends StatelessWidget {
  final bool isWeb;

  const PdfListWidget({super.key, this.isWeb = false});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PdfChatProvider>(context);

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
                const Icon(Icons.library_books, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Uploaded PDFs',
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${provider.uploadedPdfs.length} files',
                  style: TextStyle(
                    color: AppTheme.grey,
                    fontSize: isWeb ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Upload Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Upload PDF',
              onPressed: provider.isUploading
                  ? null
                  : () => provider.uploadPdf(),
              isLoading: provider.isUploading,
            ),
          ),
          // PDF List
          Expanded(
            child: provider.uploadedPdfs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: provider.uploadedPdfs.length,
                    itemBuilder: (context, index) {
                      final pdf = provider.uploadedPdfs[index];
                      return _buildPdfItem(pdf, provider, context);
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
          children: [],
        ),
      ),
    );
  }

  Widget _buildPdfItem(
    PdfFile pdf,
    PdfChatProvider provider,
    BuildContext context,
  ) {
    final isSelected = provider.selectedPdf?.id == pdf.id;

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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.picture_as_pdf,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
        ),
        title: Text(
          pdf.name,
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
            Text(
              '${pdf.pageCount} pages • ${pdf.formattedSize}',
              style: TextStyle(fontSize: isWeb ? 12 : 10, color: AppTheme.grey),
            ),
            Text(
              'Uploaded ${_formatDate(pdf.uploadDate)}',
              style: TextStyle(fontSize: isWeb ? 11 : 9, color: AppTheme.grey),
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
              onPressed: () => _showDeleteDialog(pdf, provider, context),
              color: Colors.red,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        onTap: () => provider.selectPdf(pdf),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  void _showDeleteDialog(
    PdfFile pdf,
    PdfChatProvider provider,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete PDF'),
        content: Text('Are you sure you want to delete "${pdf.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removePdf(pdf);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
