import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/image_generation_provider.dart';
import '../models/generated_image.dart';

class ImageGalleryWidget extends StatelessWidget {
  final bool isWeb;

  const ImageGalleryWidget({super.key, this.isWeb = false});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ImageGenerationProvider>(context);

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
                const Icon(Icons.photo_library, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Generated Images',
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${provider.generatedImages.length} images',
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
          if (provider.generatedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildClearAllButton(provider, context),
            ),
          // Gallery Grid
          Expanded(
            child: provider.generatedImages.isEmpty
                ? _buildEmptyState()
                : _buildGalleryGrid(provider, context),
          ),
        ],
      ),
    );
  }

  Widget _buildClearAllButton(
    ImageGenerationProvider provider,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: TextButton(
        onPressed: () => _showClearAllDialog(context, provider),
        child: Text(
          'Clear All History',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w500,
            fontSize: isWeb ? 14 : 12,
          ),
        ),
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
              Icons.photo_library_outlined,
              size: isWeb ? 64 : 48,
              color: AppTheme.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Generated Images',
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate some images to see them here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isWeb ? 14 : 12, color: AppTheme.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryGrid(
    ImageGenerationProvider provider,
    BuildContext context,
  ) {
    final crossAxisCount = isWeb ? 4 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: provider.generatedImages.length,
      itemBuilder: (context, index) {
        final image = provider.generatedImages[index];
        return _buildImageCard(image, provider, context);
      },
    );
  }

  Widget _buildImageCard(
    GeneratedImage image,
    ImageGenerationProvider provider,
    BuildContext context,
  ) {
    final isSelected = provider.selectedImage?.id == image.id;

    return GestureDetector(
      onTap: () => provider.selectImage(image),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: CachedNetworkImage(
                imageUrl: image.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            // Download Badge
            if (image.localPath != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.download_done,
                    color: Colors.white,
                    size: isWeb ? 16 : 12,
                  ),
                ),
              ),
            // Prompt Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(11),
                    bottomRight: Radius.circular(11),
                  ),
                ),
                child: Text(
                  image.prompt,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWeb ? 10 : 8,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Selection Indicator
            if (isSelected)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: isWeb ? 16 : 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    ImageGenerationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Images'),
        content: const Text(
          'Are you sure you want to clear all generated images? This action cannot be undone.',
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
