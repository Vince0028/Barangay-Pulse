import 'package:hive_flutter/hive_flutter.dart';
import '../models/mesh_message.dart';

class MeshStorage {
  static const _boxName = 'mesh_messages';
  static Box<MeshMessage>? _box;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(MeshMessageAdapter());
    }
    _box = await Hive.openBox<MeshMessage>(_boxName);
  }

  static Box<MeshMessage> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('MeshStorage not initialized. Call initialize() first.');
    }
    return _box!;
  }

  static Future<void> saveMessage(MeshMessage message) async {
    await box.put(message.id, message);
  }

  static List<MeshMessage> getMessages() {
    final messages = box.values.toList();
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  static Future<void> clearMessages() async {
    await box.clear();
  }

  static bool hasMessage(String id) {
    return box.containsKey(id);
  }
}
