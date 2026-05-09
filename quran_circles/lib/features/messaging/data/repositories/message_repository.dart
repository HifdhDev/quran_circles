import 'package:sembast/sembast.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/store_refs.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/i_message_repository.dart';

class MessageRepository implements IMessageRepository {
  final DatabaseService _db;

  MessageRepository(this._db);

  Future<Database> get _database => _db.database;

  @override
  Future<List<Message>> getInbox(int receiverId) async {
    final db = await _database;
    final records = await StoreRefs.messages.find(db, finder: Finder(
      filter: Filter.equals('receiverId', receiverId),
      sortOrders: [SortOrder('sentAt', false)],
    ));
    return records.map((r) => _fromMap(r.key, r.value)).toList();
  }

  @override
  Future<List<Message>> getSent(int senderId) async {
    final db = await _database;
    final records = await StoreRefs.messages.find(db, finder: Finder(
      filter: Filter.equals('senderId', senderId),
      sortOrders: [SortOrder('sentAt', false)],
    ));
    return records.map((r) => _fromMap(r.key, r.value)).toList();
  }

  @override
  Future<List<Message>> getByCircle(int circleId) async {
    final db = await _database;
    final records = await StoreRefs.messages.find(db, finder: Finder(
      filter: Filter.equals('circleId', circleId),
      sortOrders: [SortOrder('sentAt', false)],
    ));
    return records.map((r) => _fromMap(r.key, r.value)).toList();
  }

  @override
  Future<int> send(Message message) async {
    final db = await _database;
    return StoreRefs.messages.add(db, _toMap(message));
  }

  @override
  Future<void> markAsRead(int messageId) async {
    final db = await _database;
    await StoreRefs.messages.record(messageId).put(db, {
      ...await StoreRefs.messages.record(messageId).get(db) ?? {},
      'isRead': true,
    });
  }

  @override
  Future<void> delete(int id) async {
    final db = await _database;
    await StoreRefs.messages.record(id).delete(db);
  }

  Map<String, dynamic> _toMap(Message m) => {
        'title': m.title,
        'body': m.body,
        'senderId': m.senderId,
        'receiverId': m.receiverId,
        'circleId': m.circleId,
        'priority': m.priority.name,
        'sentAt': m.sentAt.toUtc().toIso8601String(),
        'isRead': m.isRead,
      };

  Message _fromMap(int id, Map<String, dynamic> d) {
    return Message(
      id: id,
      title: d['title'] as String,
      body: d['body'] as String,
      senderId: d['senderId'] as int,
      receiverId: d['receiverId'] as int?,
      circleId: d['circleId'] as int?,
      priority: MessagePriority.values.firstWhere((p) => p.name == d['priority']),
      sentAt: DateTime.parse(d['sentAt'] as String).toLocal(),
      isRead: d['isRead'] as bool? ?? false,
    );
  }
}
