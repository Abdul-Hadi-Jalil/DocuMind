import 'package:flutter/material.dart';
import '../../../models/module_model.dart';

class ModuleData {
  static final List<Module> modules = [
    Module(
      id: '1',
      title: 'Chat with PDF',
      description: 'Upload PDF files and chat with AI about their content',
      icon: '📄',
      color: const Color(0xFF4CAF50), // Primary Green
      route: '/pdf-chat',
    ),
    Module(
      id: '2',
      title: 'OCR Scanner',
      description:
          'Extract text from images using Optical Character Recognition',
      icon: '🔍',
      color: const Color(0xFF2196F3), // Blue
      route: '/ocr',
    ),
    Module(
      id: '3',
      title: 'Image Generation',
      description: 'Create amazing images from text prompts using AI',
      icon: '🎨',
      color: const Color(0xFF9C27B0), // Purple
      route: '/image-generation',
    ),
  ];
}
