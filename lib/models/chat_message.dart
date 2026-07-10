class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isSystemAction;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isSystemAction = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isSystemAction': isSystemAction,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      isSystemAction: json['isSystemAction'] ?? false,
    );
  }
}
