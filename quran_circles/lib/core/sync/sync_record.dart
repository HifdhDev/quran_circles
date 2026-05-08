import 'package:equatable/equatable.dart';

class SyncRecord extends Equatable {
  final int? id;
  final String collection;
  final String recordId;
  final String data;
  final String deviceId;
  final int timestamp;
  final bool isDeleted;
  final String? signature;

  const SyncRecord({
    this.id,
    required this.collection,
    required this.recordId,
    required this.data,
    required this.deviceId,
    required this.timestamp,
    this.isDeleted = false,
    this.signature,
  });

  Map<String, dynamic> toMap() => {
        'collection': collection,
        'recordId': recordId,
        'data': data,
        'deviceId': deviceId,
        'timestamp': timestamp,
        'isDeleted': isDeleted,
        'signature': signature,
      };

  factory SyncRecord.fromMap(Map<String, dynamic> map, {int? id}) =>
      SyncRecord(
        id: id ?? map['id'] as int?,
        collection: map['collection'] as String,
        recordId: map['recordId'] as String,
        data: map['data'] as String,
        deviceId: map['deviceId'] as String,
        timestamp: map['timestamp'] as int,
        isDeleted: map['isDeleted'] as bool? ?? false,
        signature: map['signature'] as String?,
      );

  SyncRecord withId(int newId) => SyncRecord(
        id: newId,
        collection: collection,
        recordId: recordId,
        data: data,
        deviceId: deviceId,
        timestamp: timestamp,
        isDeleted: isDeleted,
        signature: signature,
      );

  @override
  List<Object?> get props =>
      [id, collection, recordId, deviceId, timestamp, isDeleted];
}
