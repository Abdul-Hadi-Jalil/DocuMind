import 'dart:io';
import 'package:documind/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewWidget extends StatelessWidget {
  final String imagePath;
  final String imageName;
  final VoidCallback? onClose;
  final bool isWeb;

  const ImagePreviewWidget({
    super.key,
    required this.imagePath,
    required this.imageName,
    this.onClose,
    this.isWeb = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: isWeb ? const EdgeInsets.all(40) : const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image, color: AppTheme.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      imageName,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.white),
                    onPressed: onClose ?? () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Image
            Expanded(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: isWeb ? 600 : 400),
                child: PhotoView(
                  imageProvider: Image.file(
                    // For web, we'd use a different approach, but for demo:
                    // ignore: unnecessary_cast
                    (imagePath.startsWith('http')
                            ? NetworkImage(imagePath) as ImageProvider
                            : FileImage(imagePath as File))
                        as File,
                  ).image,
                  backgroundDecoration: const BoxDecoration(
                    color: AppTheme.white,
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
