import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

// Gemini API Service
class GeminiService {
  static const String _systemPrompt = '''
You are **DocuBot**, a smart, friendly AI assistant that helps users understand and explore the content of an uploaded file.

Use the uploaded file's content as your primary knowledge source to answer the user's questions clearly and accurately.

If the question is completely unrelated to the file, respond kindly:
"The uploaded file doesn't contain any information about that topic, but I can still help you understand it if you'd like."
''';

  static const String apiKey = 'AIzaSyC-WrzKEAmIETrxZnmyjF7iDJJNJ5RKEGE';

  static Future<String> getResponse(
    String userPrompt,
    String? fileContent,
    String? fileName,
  ) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-pro',
        apiKey: apiKey,
        systemInstruction: Content.text(_systemPrompt),
      );

      final prompt =
          '''
Here is the content of the uploaded file named "$fileName":
---
$fileContent
---

User's question:
"$userPrompt"
''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "I didn't get a response. Please try again.";
    } catch (e) {
      return "Service is temporarily unavailable. Please try again shortly.";
    }
  }
}

// File Helper
class FileHelper {
  static Future<Map<String, dynamic>?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['txt', 'pdf'],
      type: FileType.custom,
    );

    if (result == null) return null;

    final file = result.files.first;
    String? content;

    if (file.extension == "txt" && file.bytes != null) {
      content = utf8.decode(file.bytes!);
    } else if (file.extension == "pdf") {
      content = "[PDF content would be extracted here]";
    }

    if (content != null && content.isNotEmpty) {
      return {'content': content, 'name': file.name, 'size': file.size};
    }

    return null;
  }
}

// Message Model
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Main Chat Screen
class SimpleChatScreen extends StatefulWidget {
  const SimpleChatScreen({super.key});

  @override
  State<SimpleChatScreen> createState() => _SimpleChatScreenState();
}

class _SimpleChatScreenState extends State<SimpleChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final uuid = const Uuid();

  String? _fileName;
  String? _fileContent;
  bool _isTyping = false;
  int _availablePrompts = 5;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        id: uuid.v4(),
        text: _fileName != null
            ? "Hello! I'm DocuBot. I can help you understand and explore the content of '$_fileName'. What would you like to know?"
            : "Hello! I'm DocuBot. Please upload a file first to start chatting about its content.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    setState(() {});
  }

  Future<void> _pickFile() async {
    final fileInfo = await FileHelper.pickFile();
    if (fileInfo != null) {
      setState(() {
        _fileName = fileInfo['name'];
        _fileContent = fileInfo['content'];
        _messages.clear();
      });
      _addWelcomeMessage();
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (_fileContent == null) {
      _addMessage("Please upload a file first to start chatting.", false);
      _textController.clear();
      return;
    }

    if (_availablePrompts <= 0) {
      _showNoPromptsDialog();
      return;
    }

    // Add user message
    _addMessage(text, true);
    _textController.clear();

    // Use one prompt
    setState(() {
      _availablePrompts--;
      _isTyping = true;
    });

    // Get AI response
    try {
      final response = await GeminiService.getResponse(
        text,
        _fileContent,
        _fileName,
      );
      setState(() {
        _isTyping = false;
      });
      _addMessage(response, false);
    } catch (e) {
      setState(() {
        _isTyping = false;
      });
      _addMessage("Error: Please try again.", false);
    }
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(
        ChatMessage(
          id: uuid.v4(),
          text: text,
          isUser: isUser,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showNoPromptsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Prompts Available'),
        content: const Text('You have used all your available prompts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('D', style: TextStyle(color: Colors.white)),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text('D', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedDot(0),
                const SizedBox(width: 4),
                _buildAnimatedDot(200),
                const SizedBox(width: 4),
                _buildAnimatedDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int delay) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_fileName ?? 'Document Chat'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _pickFile,
            tooltip: 'Upload File',
          ),
        ],
      ),
      body: Column(
        children: [
          // Prompt counter
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  '$_availablePrompts ${_availablePrompts == 1 ? 'prompt' : 'prompts'} available',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessageBubble(_messages[index]);
                } else {
                  return _buildTypingIndicator();
                }
              },
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    controller: _textController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(),
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
