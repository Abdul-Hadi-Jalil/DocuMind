import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart'; // Add this import

import '../../../core/theme/app_theme.dart';
import '../models/chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isWeb;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.isWeb = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          _buildAvatar(),
          const SizedBox(width: 12),
          // Message Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with timestamp
                _buildMessageHeader(context),
                const SizedBox(height: 4),
                // Message content
                _buildMessageContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    Color avatarColor;
    IconData avatarIcon;

    switch (message.type) {
      case MessageType.user:
        avatarColor = AppTheme.primaryGreen;
        avatarIcon = Icons.person;
        break;
      case MessageType.bot:
        avatarColor = Colors.blue;
        avatarIcon = Icons.smart_toy;
        break;
      case MessageType.system:
        avatarColor = Colors.orange;
        avatarIcon = Icons.info;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
      child: Icon(avatarIcon, color: Colors.white, size: 20),
    );
  }

  Widget _buildMessageHeader(BuildContext context) {
    String roleText;
    Color roleColor;

    switch (message.type) {
      case MessageType.user:
        roleText = 'You';
        roleColor = AppTheme.primaryGreen;
        break;
      case MessageType.bot:
        roleText = 'FrogBase AI';
        roleColor = Colors.blue;
        break;
      case MessageType.system:
        roleText = 'System';
        roleColor = Colors.orange;
        break;
    }

    return Row(
      children: [
        Text(
          roleText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: roleColor,
            fontSize: isWeb ? 14 : 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTimestamp(message.timestamp),
          style: TextStyle(color: AppTheme.grey, fontSize: isWeb ? 12 : 10),
        ),
        const Spacer(),
        if (message.type != MessageType.user)
          IconButton(
            icon: Icon(
              Icons.content_copy,
              size: isWeb ? 16 : 14,
              color: AppTheme.grey,
            ),
            onPressed: () => _copyToClipboard(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content)).then((_) {
      // Show a snackbar instead of toast for better web compatibility
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  Widget _buildMessageContent() {
    if (message.isProcessing) {
      return Container(
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
            Text(
              message.content,
              style: TextStyle(
                color: AppTheme.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getMessageBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getMessageBorderColor(), width: 1),
      ),
      child: MarkdownBody(
        data: message.content,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            fontSize: isWeb ? 14 : 12,
            height: 1.5,
            color: _getMessageTextColor(),
          ),
          strong: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getMessageTextColor(),
          ),
          code: TextStyle(
            backgroundColor: Colors.grey[100],
            color: Colors.black,
            fontSize: isWeb ? 12 : 10,
          ),
          blockquote: TextStyle(
            fontStyle: FontStyle.italic,
            color: AppTheme.grey,
          ),
        ),
      ),
    );
  }

  Color _getMessageBackgroundColor() {
    switch (message.type) {
      case MessageType.user:
        return AppTheme.primaryGreen.withOpacity(0.1);
      case MessageType.bot:
        return Colors.white;
      case MessageType.system:
        return Colors.orange.withOpacity(0.1);
    }
  }

  Color _getMessageBorderColor() {
    switch (message.type) {
      case MessageType.user:
        return AppTheme.primaryGreen.withOpacity(0.3);
      case MessageType.bot:
        return Colors.grey[200]!;
      case MessageType.system:
        return Colors.orange.withOpacity(0.3);
    }
  }

  Color _getMessageTextColor() {
    switch (message.type) {
      case MessageType.user:
        return AppTheme.black;
      case MessageType.bot:
        return AppTheme.black;
      case MessageType.system:
        return Colors.orange[800]!;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
