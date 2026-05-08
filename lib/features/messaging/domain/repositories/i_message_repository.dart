import '../entities/message.dart';

abstract class IMessageRepository {
  Future<List<Message>> getInbox(int receiverId);
  Future<List<Message>> getSent(int senderId);
  Future<List<Message>> getByCircle(int circleId);
  Future<int> send(Message message);
  Future<void> markAsRead(int messageId);
  Future<void> delete(int id);
}
