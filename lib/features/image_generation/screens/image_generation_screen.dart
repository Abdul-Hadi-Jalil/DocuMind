import 'package:documind/features/image_generation/models/generated_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../providers/image_generation_provider.dart';
import '../widgets/parameters_panel.dart';
import '../widgets/image_gallery_widget.dart';
import '../widgets/image_preview_widget.dart';

class ImageGenerationScreen extends StatefulWidget {
  const ImageGenerationScreen({super.key});

  @override
  State<ImageGenerationScreen> createState() => _ImageGenerationScreenState();
}

class _ImageGenerationScreenState extends State<ImageGenerationScreen> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ImageGenerationProvider>(context, listen: false).clearError();
    });
  }

  void _generateImage() {
    final provider = Provider.of<ImageGenerationProvider>(
      context,
      listen: false,
    );
    final prompt = _promptController.text.trim();
    provider.generateImage(prompt);
  }

  void _showImagePreview(
    GeneratedImage image,
    ImageGenerationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => ImagePreviewWidget(
        imageUrl: image.imageUrl,
        prompt: image.prompt,
        isWeb: ResponsiveBreakpoints.of(context).largerThan(TABLET),
        onDownload: () => provider.downloadImage(image),
        isDownloaded: image.localPath != null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('AI Image Generation'),
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
            // Prompt Input Section
            _buildPromptSection(isDesktop),
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

  Widget _buildPromptSection(bool isDesktop) {
    final provider = Provider.of<ImageGenerationProvider>(context);

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
                  Icons.auto_awesome,
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
                      'Create AI-Generated Images',
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Describe what you want to see and let AI create it for you',
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
          // Prompt Input
          TextField(
            controller: _promptController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Describe the image you want to generate...\nExample: "A majestic dragon flying over a medieval castle at sunset, fantasy art style"',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _generateImage,
                color: AppTheme.primaryGreen,
              ),
            ),
            onChanged: (value) {
              Provider.of<ImageGenerationProvider>(
                context,
                listen: false,
              ).updatePrompt(value);
            },
            onSubmitted: (_) => _generateImage(),
          ),
          const SizedBox(height: 16),
          // Generate Button
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Generate Image',
                  onPressed: provider.isGenerating ? null : _generateImage,
                  isLoading: provider.isGenerating,
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          // Generation Status
          if (provider.isGenerating) ...[
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
                Expanded(
                  child: Text(
                    'Generating image from: "${provider.currentPrompt}"...',
                    style: TextStyle(
                      color: AppTheme.grey,
                      fontSize: isDesktop ? 14 : 12,
                    ),
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
        // Parameters Panel
        SizedBox(width: 300, child: ParametersPanel(isWeb: true)),
        const SizedBox(width: 24),
        // Gallery
        Expanded(child: ImageGalleryWidget(isWeb: true)),
        const SizedBox(width: 24),
        // Selected Image Preview
        SizedBox(width: 400, child: _buildSelectedImagePreview(true)),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Parameters Panel
        Expanded(flex: 2, child: ParametersPanel(isWeb: false)),
        const SizedBox(height: 16),
        // Gallery
        Expanded(flex: 3, child: ImageGalleryWidget(isWeb: false)),
        const SizedBox(height: 16),
        // Selected Image Preview
        Expanded(flex: 2, child: _buildSelectedImagePreview(false)),
      ],
    );
  }

  Widget _buildSelectedImagePreview(bool isWeb) {
    return Consumer<ImageGenerationProvider>(
      builder: (context, provider, child) {
        if (provider.selectedImage == null) {
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_size_select_actual,
                    size: isWeb ? 48 : 32,
                    color: AppTheme.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select an Image to Preview',
                    style: TextStyle(
                      fontSize: isWeb ? 16 : 14,
                      color: AppTheme.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final image = provider.selectedImage!;

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
                    const Icon(Icons.preview, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selected Image',
                        style: TextStyle(
                          fontSize: isWeb ? 16 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in),
                      onPressed: () => _showImagePreview(image, provider),
                      tooltip: 'Full Screen Preview',
                    ),
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => provider.downloadImage(image),
                      tooltip: 'Download Image',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Image Preview
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Image
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(image.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Prompt
                      Text(
                        image.prompt,
                        style: TextStyle(
                          fontSize: isWeb ? 12 : 10,
                          color: AppTheme.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem('Size', image.parameters.size),
                          _buildInfoItem('Model', image.parameters.model),
                          _buildInfoItem('Date', image.formattedDate),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Image Generation Help'),
        content: const SingleChildScrollView(
          child: Text('''
How to Generate AI Images:

1. **Write a Detailed Prompt**: Be specific about what you want to see. Include details about style, composition, colors, and mood.

2. **Adjust Parameters**:
   - **Model**: Choose the AI model (each has different strengths)
   - **Size**: Select output image dimensions
   - **Steps**: More steps = higher quality but slower generation
   - **Guidance Scale**: How closely to follow your prompt (7-12 is typical)
   - **Sampler**: Algorithm used for generation

3. **Generate & Review**: Click generate and wait for your image. You can then:
   - Preview in full screen
   - Download to your device
   - Generate variations

Tips for Better Results:
- Be descriptive and specific
- Mention art style (photorealistic, anime, oil painting, etc.)
- Include lighting and mood descriptions
- Specify composition and perspective
- Add details about colors and textures

Example Prompts:
- "A serene lake at sunrise with mist, photorealistic"
- "Cyberpunk city street with neon lights, anime style"
- "Majestic wolf howling at full moon, digital art"
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

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
