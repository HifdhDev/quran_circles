import 'package:equatable/equatable.dart';

enum MessagePriority { normal, important, urgent }

class Message extends Equatable {
  final int? id;
  final String title;
  final String body;
  final int senderId;
  final int? receiverId;
  final int? circleId;
  final MessagePriority priority;
  final DateTime sentAt;
  final bool isRead;

  const Message({
    this.id,
    required this.title,
    required this.body,
    required this.senderId,
    this.receiverId,
    this.circleId,
    this.priority = MessagePriority.normal,
    required this.sentAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        senderId,
        receiverId,
        circleId,
        priority,
        sentAt,
        isRead,
      ];
}
