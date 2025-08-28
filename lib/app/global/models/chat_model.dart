import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool seen;

  ChatMessage({
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.seen = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "text": text,
      "timestamp": timestamp,
      "seen": seen,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'],
      text: map['text'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      seen: map['seen'] ?? false,
    );
  }
}
