import 'package:flutter/material.dart';
import 'package:documind/core/theme/app_theme.dart';
import 'package:documind/widgets/custom_button.dart';

// Models
class PdfFile {
  final String name;
  final String content;

  const PdfFile({required this.name, required this.content});
}

class ChatMessage {
  final String content;
  final bool isUser;

  const ChatMessage({required this.content, required this.isUser});
}

// Main Screen
class PdfChatScreen extends StatefulWidget {
  const PdfChatScreen({super.key});

  @override
  State<PdfChatScreen> createState() => _PdfChatScreenState();
}

class _PdfChatScreenState extends State<PdfChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  PdfFile? _selectedPdf;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Dummy PDF content
  final String _dummyPdfContent = '''
Artificial Intelligence (AI) Fundamentals

Chapter 1: Introduction to AI
Artificial Intelligence refers to the simulation of human intelligence in machines. 
These machines are programmed to think like humans and mimic their actions.

Chapter 2: Machine Learning
Machine learning is a subset of AI that enables machines to improve at tasks with experience.
It focuses on the development of algorithms that can access data and use it to learn for themselves.

Chapter 3: Deep Learning
Deep learning is a machine learning technique that teaches computers to do what comes naturally to humans.
It uses neural networks with many layers (deep networks) to learn from large amounts of data.

Key Applications:
- Natural Language Processing
- Computer Vision
- Robotics
- Predictive Analytics
''';

  void _uploadDummyPdf() {
    setState(() {
      _selectedPdf = PdfFile(
        name: 'AI_Fundamentals.pdf',
        content: _dummyPdfContent,
      );

      // Add welcome message
      _messages.add(
        ChatMessage(
          content:
              'PDF "AI_Fundamentals.pdf" uploaded successfully! You can now ask questions about AI fundamentals.',
          isUser: false,
        ),
      );
    });

    _scrollToBottom();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || _selectedPdf == null) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(content: message, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response after delay
    Future.delayed(const Duration(seconds: 1), () {
      final response = _generateResponse(message);
      setState(() {
        _messages.add(ChatMessage(content: response, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }

  String _generateResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('hello') || message.contains('hi')) {
      return 'Hello! I\'m ready to help you understand the AI Fundamentals PDF. What would you like to know?';
    } else if (message.contains('summary') || message.contains('summarize')) {
      return '''Based on the PDF, here's a summary:

The document covers Artificial Intelligence fundamentals across three main chapters:
1. **Introduction to AI** - Basics of AI and human intelligence simulation
2. **Machine Learning** - Algorithms that learn from data and experience  
3. **Deep Learning** - Neural networks with multiple layers

Key applications include Natural Language Processing, Computer Vision, Robotics, and Predictive Analytics.''';
    } else if (message.contains('machine learning') || message.contains('ml')) {
      return '''From Chapter 2 of your PDF:

**Machine Learning** is defined as a subset of AI that enables machines to improve at tasks with experience. It focuses on developing algorithms that can:
- Access and learn from data
- Improve performance over time
- Make predictions or decisions

Unlike traditional programming, ML systems learn patterns from data rather than following explicit instructions.''';
    } else if (message.contains('deep learning') ||
        message.contains('neural')) {
      return '''From Chapter 3 of your PDF:

**Deep Learning** uses neural networks with multiple layers to learn from large amounts of data. Key characteristics:
- Uses deep neural networks (many layers)
- Learns hierarchical representations of data
- Excels at complex pattern recognition
- Powers modern AI applications like image and speech recognition

It's particularly effective for unstructured data like images, audio, and text.''';
    } else if (message.contains('ai') ||
        message.contains('artificial intelligence')) {
      return '''From Chapter 1 of your PDF:

**Artificial Intelligence (AI)** refers to the simulation of human intelligence in machines programmed to:
- Think like humans
- Mimic human actions
- Learn from experience
- Solve complex problems

AI systems can perform tasks that typically require human intelligence, such as visual perception, speech recognition, and decision-making.''';
    } else {
      return '''I've analyzed your question about "$userMessage" in the context of the AI Fundamentals PDF.

The document covers:
• Artificial Intelligence basics and concepts
• Machine Learning methodologies  
• Deep Learning and neural networks
• Real-world AI applications

Would you like me to explain any specific topic from the PDF in more detail?''';
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Chat with PDF'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearChat,
              tooltip: 'Clear Chat',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Upload Section
            _buildUploadSection(),
            const SizedBox(height: 24),
            // Chat Area
            Expanded(child: _buildChatArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
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
                  Icons.picture_as_pdf,
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
                      'Chat with PDF',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Upload a PDF and ask questions about its content',
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
            text: _selectedPdf == null ? 'Load Sample PDF' : 'PDF Loaded ✓',
            onPressed: _selectedPdf == null ? _uploadDummyPdf : null,
            backgroundColor: AppTheme.primaryGreen,
          ),
          if (_selectedPdf != null) ...[
            const SizedBox(height: 16),
            Text(
              'Currently chatting with: ${_selectedPdf!.name}',
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatArea() {
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
          // Chat Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.chat, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedPdf?.name ?? 'No PDF Selected',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${_messages.length} messages',
                  style: const TextStyle(color: AppTheme.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Messages
          Expanded(
            child: _selectedPdf == null
                ? _buildEmptyState()
                : _buildMessagesList(),
          ),
          // Input Area
          if (_selectedPdf != null) _buildInputArea(),
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
            Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.grey),
            const SizedBox(height: 16),
            const Text(
              'No PDF Loaded',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Load a PDF to start chatting',
              style: TextStyle(fontSize: 14, color: AppTheme.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildLoadingMessage();
        }
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: message.isUser ? AppTheme.primaryGreen : Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              message.isUser ? Icons.person : Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Message Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.isUser ? 'You' : 'FrogBase AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: message.isUser ? AppTheme.primaryGreen : Colors.blue,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppTheme.primaryGreen.withOpacity(0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: message.isUser
                          ? AppTheme.primaryGreen.withOpacity(0.3)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FrogBase AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Thinking...',
                        style: TextStyle(
                          color: AppTheme.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask a question about the PDF...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          CustomButton(
            text: 'Send',
            onPressed: _isLoading ? null : _sendMessage,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
