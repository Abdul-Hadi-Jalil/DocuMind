// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Gemini API Service
class GeminiService {
  static const String _systemPrompt = '''
You are **DocuBot**, a smart, friendly AI assistant that helps users understand and explore the content of an uploaded file.

Use the uploaded file's content as your primary knowledge source to answer the user's questions clearly and accurately.

If the question is completely unrelated to the file, respond kindly:
"The uploaded file doesn't contain any information about that topic, but I can still help you understand it if you'd like."
''';

  static final String apiKey = dotenv.env["API_KEY"] ?? "No key found";

  static Future<String> getResponse(
    String userPrompt,
    String? fileContent,
    String? fileName,
  ) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
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
      return "Service is temporarily unavailable. Please try again shortly. Error: ${e.toString()}";
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

class PDFChatScreen extends StatefulWidget {
  const PDFChatScreen({super.key});

  @override
  State<PDFChatScreen> createState() => _PDFChatScreenState();
}

class _PDFChatScreenState extends State<PDFChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  String? _fileContent;
  String? _fileName;
  int? _fileSize;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add initial bot message
    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm ready to help you with your PDF. Upload a document and ask me anything about it!",
        isUser: false,
      ),
    );
  }

  Future<void> _pickFile() async {
    final fileData = await FileHelper.pickFile();

    if (fileData != null) {
      setState(() {
        _fileContent = fileData['content'];
        _fileName = fileData['name'];
        _fileSize = fileData['size'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File uploaded: $_fileName'),
          backgroundColor: const Color(0xFF00D9C0),
          duration: const Duration(seconds: 2),
        ),
      );

      // Add a welcome message about the uploaded file
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "Great! I've loaded your file '$_fileName'. Feel free to ask me anything about it!",
            isUser: false,
          ),
        );
      });

      _scrollToBottom();
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Get AI response from Gemini
    final botResponse = await GeminiService.getResponse(
      userMessage,
      _fileContent,
      _fileName,
    );

    setState(() {
      _messages.add(ChatMessage(text: botResponse, isUser: false));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Navbar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.95),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF00FF88).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FF88), Color(0xFF00D4FF)],
                  ).createShader(bounds),
                  child: const Text(
                    'Froggy AI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Page Title
                const Text(
                  'Chat with PDF',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Right side buttons
                Row(
                  children: [
                    // Back to Dashboard Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.05),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back, size: 16),
                          SizedBox(width: 8),
                          Text('Dashboard'),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // User Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00FF88), Color(0xFF00D4FF)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'ES',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Upload PDF Section
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF00D9C0).withOpacity(0.3),
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _fileName != null
                        ? Icons.check_circle
                        : Icons.insert_drive_file_outlined,
                    color: _fileName != null
                        ? const Color(0xFF00D9C0)
                        : Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fileName ?? 'Upload PDF',
                        style: const TextStyle(
                          color: Color(0xFF00D9C0),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fileName != null
                            ? 'File uploaded successfully${_fileSize != null ? " • ${(_fileSize! / 1024).toStringAsFixed(1)} KB" : ""}'
                            : 'Click to browse or drag & drop',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9C0),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _fileName != null ? 'Change File' : 'Choose File',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.android,
                            color: Color(0xFF00D9C0),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF00D9C0),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Thinking...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ask a question about your PDF...',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    backgroundColor: const Color(0xFF00D9C0),
                    child: const Icon(Icons.send, color: Colors.black),
                  ),
                ],
              ),
            ),
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

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.android,
                color: Color(0xFF00D9C0),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF00D9C0).withOpacity(0.1)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: const Color(0xFF00D9C0),
              radius: 20,
              child: const Text(
                'JD',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
