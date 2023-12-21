enum ChatMessageType { user, bot }

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.chatMessageType,
    required this.time,
  });

  final String text,time;
  final ChatMessageType chatMessageType;
}
