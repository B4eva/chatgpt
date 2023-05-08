enum ChatMessageType { user, bot }

class ChatMessage {
  final String text;
  final ChatMessageType chatMessageType;

  ChatMessage({required this.chatMessageType, required this.text});
}
