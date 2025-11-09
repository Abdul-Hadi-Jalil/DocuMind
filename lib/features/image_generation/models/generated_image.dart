class GeneratedImage {
  final String id;
  final String prompt;
  final String imageUrl;
  final DateTime generatedAt;
  final ImageGenerationParameters parameters;
  final String? localPath;

  const GeneratedImage({
    required this.id,
    required this.prompt,
    required this.imageUrl,
    required this.generatedAt,
    required this.parameters,
    this.localPath,
  });

  String get formattedDate {
    return '${generatedAt.day}/${generatedAt.month}/${generatedAt.year} ${generatedAt.hour}:${generatedAt.minute.toString().padLeft(2, '0')}';
  }

  GeneratedImage copyWith({String? localPath}) {
    return GeneratedImage(
      id: id,
      prompt: prompt,
      imageUrl: imageUrl,
      generatedAt: generatedAt,
      parameters: parameters,
      localPath: localPath ?? this.localPath,
    );
  }
}

class ImageGenerationParameters {
  final String model;
  final String size;
  final int steps;
  final double guidanceScale;
  final String sampler;
  final int seed;

  const ImageGenerationParameters({
    this.model = 'stable-diffusion',
    this.size = '1024x1024',
    this.steps = 20,
    this.guidanceScale = 7.5,
    this.sampler = 'DPMSolver',
    this.seed = -1,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'size': size,
      'steps': steps,
      'guidance_scale': guidanceScale,
      'sampler': sampler,
      'seed': seed,
    };
  }

  ImageGenerationParameters copyWith({
    String? model,
    String? size,
    int? steps,
    double? guidanceScale,
    String? sampler,
    int? seed,
  }) {
    return ImageGenerationParameters(
      model: model ?? this.model,
      size: size ?? this.size,
      steps: steps ?? this.steps,
      guidanceScale: guidanceScale ?? this.guidanceScale,
      sampler: sampler ?? this.sampler,
      seed: seed ?? this.seed,
    );
  }
}
