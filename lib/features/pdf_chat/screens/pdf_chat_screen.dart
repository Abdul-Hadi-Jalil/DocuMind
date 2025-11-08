import 'package:documind/core/theme/app_theme.dart';
import 'package:documind/features/pdf_chat/providers/pdf_chat_providers.dart';
import 'package:documind/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/pdf_list_widget.dart';

class PdfChatScreen extends StatefulWidget {
  const PdfChatScreen({super.key});

  @override
  State<PdfChatScreen> createState() => _PdfChatScreenState();
}

class _PdfChatScreenState extends State<PdfChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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

  void _sendMessage() {
    final provider = Provider.of<PdfChatProvider>(context, listen: false);
    final message = _messageController.text.trim();

    if (message.isNotEmpty && provider.selectedPdf != null) {
      provider.sendMessage(message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Chat with PDF'),
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
        child: isDesktop ? _buildWebLayout() : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PDF List Sidebar
        SizedBox(width: 320, child: PdfListWidget(isWeb: true)),
        const SizedBox(width: 24),
        // Chat Area
        Expanded(child: _buildChatArea(isWeb: true)),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // PDF List (Collapsible)
        Expanded(flex: 2, child: PdfListWidget(isWeb: false)),
        const SizedBox(height: 16),
        // Chat Area
        Expanded(flex: 3, child: _buildChatArea(isWeb: false)),
      ],
    );
  }

  Widget _buildChatArea({bool isWeb = false}) {
    return Consumer<PdfChatProvider>(
      builder: (context, provider, child) {
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
              _buildChatHeader(provider, isWeb),
              const Divider(height: 1),
              // Messages Area
              Expanded(child: _buildMessagesList(provider, isWeb)),
              // Input Area
              if (provider.selectedPdf != null)
                _buildInputArea(provider, isWeb),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatHeader(PdfChatProvider provider, bool isWeb) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.chat, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.selectedPdf?.name ?? 'No PDF Selected',
                  style: TextStyle(
                    fontSize: isWeb ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (provider.selectedPdf != null)
                  Text(
                    '${provider.messages.length} messages',
                    style: TextStyle(
                      fontSize: isWeb ? 12 : 10,
                      color: AppTheme.grey,
                    ),
                  ),
              ],
            ),
          ),
          if (provider.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, size: 20),
              onPressed: () => provider.clearChat(),
              tooltip: 'Clear Chat',
            ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(PdfChatProvider provider, bool isWeb) {
    if (provider.selectedPdf == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: isWeb ? 64 : 48,
              color: AppTheme.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a PDF to Start Chatting',
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a PDF from the list to begin asking questions',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: isWeb ? 14 : 12, color: AppTheme.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final message = provider.messages[index];
        return ChatMessageWidget(message: message, isWeb: isWeb);
      },
    );
  }

  Widget _buildInputArea(PdfChatProvider provider, bool isWeb) {
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
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: AppTheme.primaryGreen,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          if (isWeb) ...[
            const SizedBox(width: 12),
            CustomButton(
              text: 'Send',
              onPressed: _sendMessage,
              isLoading: provider.isLoading,
            ),
          ],
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Chat Help'),
        content: const SingleChildScrollView(
          child: Text('''
• Upload a PDF file using the "Upload PDF" button
• Select a PDF from the list to start chatting
• Ask questions about the PDF content
• The AI will analyze the text and provide answers
• You can ask for summaries, explanations, or specific information

Supported questions:
- "Summarize this PDF"
- "Explain machine learning from the document"
- "What does the PDF say about AI?"
- "Tell me about chapter 2"
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
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
