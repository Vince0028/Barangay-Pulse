import 'package:hive/hive.dart';

part 'mesh_message.g.dart';

@HiveType(typeId: 10)
class MeshMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String from;

  @HiveField(2)
  final String to; // 'broadcast' or specific username

  @HiveField(3)
  final String body;

  @HiveField(4)
  final int timestamp;

  @HiveField(5)
  int ttl;

  @HiveField(6)
  final String senderRole; // 'civilian' or 'admin'

  @HiveField(7)
  final bool isRelayed;

  MeshMessage({
    required this.id,
    required this.from,
    required this.to,
    required this.body,
    required this.timestamp,
    this.ttl = 3,
    required this.senderRole,
    this.isRelayed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'body': body,
      'timestamp': timestamp,
      'ttl': ttl,
      'senderRole': senderRole,
      'isRelayed': isRelayed,
    };
  }

  factory MeshMessage.fromMap(Map<String, dynamic> map) {
    return MeshMessage(
      id: map['id'] as String,
      from: map['from'] as String,
      to: map['to'] as String? ?? 'broadcast',
      body: map['body'] as String,
      timestamp: map['timestamp'] as int,
      ttl: map['ttl'] as int? ?? 3,
      senderRole: map['senderRole'] as String? ?? 'civilian',
      isRelayed: map['isRelayed'] as bool? ?? false,
    );
  }
}
