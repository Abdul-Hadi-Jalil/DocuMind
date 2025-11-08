class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isProcessing;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isProcessing = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isProcessing,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

enum MessageType { user, bot, system }
