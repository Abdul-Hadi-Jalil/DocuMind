import 'package:documind/features/pdf_chat/models/chat_message.dart';
import 'package:documind/features/pdf_chat/models/pdf_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class PdfChatProvider with ChangeNotifier {
  List<PdfFile> _uploadedPdfs = [];
  PdfFile? _selectedPdf;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String _errorMessage = '';

  List<PdfFile> get uploadedPdfs => _uploadedPdfs;
  PdfFile? get selectedPdf => _selectedPdf;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String get errorMessage => _errorMessage;

  // Mock PDF text extraction (in real app, use pdf package)
  Future<void> uploadPdf() async {
    try {
      _isUploading = true;
      _errorMessage = '';
      notifyListeners();

      // For web, we'll use file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        // Simulate PDF processing
        await Future.delayed(const Duration(seconds: 2));

        final newPdf = PdfFile(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: result.files.single.name,
          path: result.files.single.path!,
          size: result.files.single.size,
          uploadDate: DateTime.now(),
          extractedText: _generateMockPdfText(result.files.single.name),
          pageCount: 5, // Mock page count
        );

        _uploadedPdfs.add(newPdf);
        _selectedPdf = newPdf;

        // Add welcome message
        _addSystemMessage(
          'PDF "${newPdf.name}" uploaded successfully! You can now ask questions about its content.',
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to upload PDF: ${e.toString()}';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  String _generateMockPdfText(String fileName) {
    return '''
This is a mock extracted text from "$fileName". In a real application, this text would be extracted from the actual PDF file using the pdf package.

Sample Content:
Chapter 1: Introduction to AI
Artificial Intelligence (AI) refers to the simulation of human intelligence in machines that are programmed to think like humans and mimic their actions. The term may also be applied to any machine that exhibits traits associated with a human mind such as learning and problem-solving.

Chapter 2: Machine Learning
Machine learning is a method of data analysis that automates analytical model building. It is a branch of artificial intelligence based on the idea that systems can learn from data, identify patterns and make decisions with minimal human intervention.

Chapter 3: Deep Learning
Deep learning is part of a broader family of machine learning methods based on artificial neural networks with representation learning. Learning can be supervised, semi-supervised or unsupervised.

This PDF contains valuable information about artificial intelligence and its various subfields. You can ask questions about any specific topic mentioned in this document.
''';
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty || _selectedPdf == null) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);

    // Add loading message
    final loadingMessage = ChatMessage(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      content: 'Thinking...',
      type: MessageType.bot,
      timestamp: DateTime.now(),
      isProcessing: true,
    );
    _messages.add(loadingMessage);

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate AI processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Remove loading message
      _messages.removeWhere((msg) => msg.isProcessing);

      // Add AI response
      final aiResponse = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _generateAiResponse(message, _selectedPdf!.extractedText!),
        type: MessageType.bot,
        timestamp: DateTime.now(),
      );
      _messages.add(aiResponse);
    } catch (e) {
      // Remove loading message on error
      _messages.removeWhere((msg) => msg.isProcessing);

      final errorMessage = ChatMessage(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        content: 'Sorry, I encountered an error while processing your request.',
        type: MessageType.system,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateAiResponse(String userMessage, String pdfText) {
    // Simple mock AI response based on keywords
    final message = userMessage.toLowerCase();

    if (message.contains('summary') || message.contains('summarize')) {
      return '''
Based on the PDF content, here's a summary:

The document covers three main chapters:
1. **Introduction to AI** - Covers the basics of artificial intelligence and its simulation of human intelligence.
2. **Machine Learning** - Focuses on data analysis automation and pattern recognition.
3. **Deep Learning** - Discusses neural networks and different learning approaches.

The PDF provides a comprehensive overview of artificial intelligence concepts and technologies.
''';
    } else if (message.contains('machine learning') || message.contains('ml')) {
      return '''
From Chapter 2 of your PDF:

**Machine Learning** is defined as a method of data analysis that automates analytical model building. It's a branch of artificial intelligence based on systems learning from data, identifying patterns, and making decisions with minimal human intervention.

Key points:
- Automates analytical model building
- Learns from data and identifies patterns
- Makes decisions with minimal human input
- Branch of artificial intelligence
''';
    } else if (message.contains('deep learning') ||
        message.contains('neural')) {
      return '''
From Chapter 3 of your PDF:

**Deep Learning** is part of the machine learning family based on artificial neural networks with representation learning. It can involve:
- Supervised learning
- Semi-supervised learning  
- Unsupervised learning

Deep learning uses neural networks with multiple layers to learn representations of data with multiple levels of abstraction.
''';
    } else if (message.contains('ai') ||
        message.contains('artificial intelligence')) {
      return '''
From Chapter 1 of your PDF:

**Artificial Intelligence (AI)** refers to the simulation of human intelligence in machines programmed to think like humans and mimic their actions. Key characteristics include:
- Simulation of human intelligence
- Thinking and mimicking human actions
- Learning capabilities
- Problem-solving abilities

AI systems can exhibit traits associated with the human mind such as learning and problem-solving.
''';
    } else {
      return '''
I've analyzed your question about "$userMessage" in the context of the uploaded PDF.

The document discusses artificial intelligence, including machine learning and deep learning. Based on the content, I can provide information about:

• AI fundamentals and concepts
• Machine learning methodologies  
• Deep learning and neural networks
• General overview of the document structure

Would you like me to elaborate on any specific topic from the PDF or provide a summary of particular sections?
''';
    }
  }

  void selectPdf(PdfFile pdf) {
    _selectedPdf = pdf;
    _messages.clear();

    // Add welcome message for selected PDF
    _addSystemMessage(
      'Now chatting about "${pdf.name}". Ask me anything about this document!',
    );
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void _addSystemMessage(String content) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.system,
      timestamp: DateTime.now(),
    );
    _messages.add(message);
    notifyListeners();
  }

  void removePdf(PdfFile pdf) {
    _uploadedPdfs.remove(pdf);
    if (_selectedPdf?.id == pdf.id) {
      _selectedPdf = null;
      _messages.clear();
    }
    notifyListeners();
  }
}
