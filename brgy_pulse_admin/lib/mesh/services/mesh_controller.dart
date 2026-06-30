import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/mesh_message.dart';
import 'mesh_storage.dart';

/// Packet types for the mesh protocol
enum MeshPacketType {
  message,    // 0 - chat message
  ping,       // 1 - keepalive
  pong,       // 2 - keepalive response
  peerInfo,   // 3 - peer name/role exchange
}

/// A connected peer in the mesh
class MeshPeer {
  final String endpointId;
  String displayName;
  bool isConnected;
  DateTime lastSeen;
  String? deviceModel;
  String? role; // 'civilian' or 'admin'

  MeshPeer({
    required this.endpointId,
    required this.displayName,
    this.isConnected = false,
    DateTime? lastSeen,
    this.deviceModel,
    this.role,
  }) : lastSeen = lastSeen ?? DateTime.now();
}

/// Wrapper for mesh packets
class MeshPacket {
  final int type;
  final Map<String, dynamic> payload;

  MeshPacket({required this.type, required this.payload});

  Map<String, dynamic> toMap() => {'type': type, 'payload': payload};

  factory MeshPacket.fromMap(Map<String, dynamic> map) {
    return MeshPacket(
      type: map['type'] as int,
      payload: Map<String, dynamic>.from(map['payload'] as Map),
    );
  }
}

/// Core mesh networking controller for offline chat
class MeshController extends ChangeNotifier {
  static const String _serviceId = 'com.brgypulse.mesh';
  static const Strategy _strategy = Strategy.P2P_CLUSTER;
  static const int _defaultTtl = 3;
  static const _uuid = Uuid();

  final String username;
  final String userRole; // 'civilian' or 'admin'

  // Connected peers
  final Map<String, MeshPeer> _peers = {};
  List<MeshPeer> get connectedPeers =>
      _peers.values.where((p) => p.isConnected).toList();
  int get peerCount => connectedPeers.length;

  // Mesh state
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  // Message deduplication
  final Set<String> _seenMessageIds = {};

  // Stream for new messages (UI listens to this)
  final _messageController = StreamController<MeshMessage>.broadcast();
  Stream<MeshMessage> get onMessage => _messageController.stream;

  // Stream for peer count changes
  final _peerCountController = StreamController<int>.broadcast();
  Stream<int> get onPeerCountChanged => _peerCountController.stream;

  // Device info
  String _deviceModel = 'Unknown';

  // Ping timer
  Timer? _pingTimer;

  MeshController({
    required this.username,
    required this.userRole,
  });

  /// Get device model string
  Future<void> _getDeviceModel() async {
    try {
      final info = DeviceInfoPlugin();
      final androidInfo = await info.androidInfo;
      _deviceModel = '${androidInfo.brand} ${androidInfo.model}';
    } catch (e) {
      _deviceModel = 'Unknown Device';
    }
  }

  /// Start the mesh network (dual-loop: advertise + discover)
  Future<bool> startMesh() async {
    if (_isRunning) return true;
    if (kIsWeb) return false; // Nearby Connections not available on web

    await _getDeviceModel();

    try {
      // Start advertising ("I'm here")
      await Nearby().startAdvertising(
        username,
        _strategy,
        onConnectionInitiated: _onConnectionInit,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: _serviceId,
      );

      // Start discovery ("Who's nearby?")
      await Nearby().startDiscovery(
        username,
        _strategy,
        onEndpointFound: (endpointId, endpointName, serviceId) {
          // Anti-collision: random jitter before requesting
          final jitter = 500 + Random().nextInt(1500);
          Future.delayed(Duration(milliseconds: jitter), () {
            if (!_peers.containsKey(endpointId) ||
                !_peers[endpointId]!.isConnected) {
              _attemptConnection(endpointId, endpointName);
            }
          });
        },
        onEndpointLost: (endpointId) {
          debugPrint('[Mesh] Endpoint lost: $endpointId');
        },
        serviceId: _serviceId,
      );

      _isRunning = true;
      _startPingTimer();
      notifyListeners();
      debugPrint('[Mesh] Started as $username ($userRole)');
      return true;
    } catch (e) {
      debugPrint('[Mesh] Start error: $e');
      return false;
    }
  }

  /// Attempt to connect to a discovered peer
  Future<void> _attemptConnection(String endpointId, String name) async {
    try {
      await Nearby().requestConnection(
        username,
        endpointId,
        onConnectionInitiated: _onConnectionInit,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      debugPrint('[Mesh] Connection request failed: $e');
    }
  }

  /// Connection initiated callback
  void _onConnectionInit(String endpointId, ConnectionInfo info) {
    // Auto-accept all connections
    Nearby().acceptConnection(
      endpointId,
      onPayLoadRecieved: (endpointId, payload) {
        _handleIncomingPayload(endpointId, payload);
      },
    );

    _peers[endpointId] = MeshPeer(
      endpointId: endpointId,
      displayName: info.endpointName,
    );
  }

  /// Connection result callback
  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      final peer = _peers[endpointId];
      if (peer != null) {
        peer.isConnected = true;
        peer.lastSeen = DateTime.now();
      } else {
        _peers[endpointId] = MeshPeer(
          endpointId: endpointId,
          displayName: 'Peer',
          isConnected: true,
        );
      }

      // Send peer info
      _sendPeerInfo(endpointId);

      _peerCountController.add(peerCount);
      notifyListeners();
      debugPrint('[Mesh] Connected to: $endpointId (${peerCount} peers)');
    } else {
      _peers.remove(endpointId);
      debugPrint('[Mesh] Connection failed: $endpointId');
    }
  }

  /// Disconnection callback
  void _onDisconnected(String endpointId) {
    _peers.remove(endpointId);
    _peerCountController.add(peerCount);
    notifyListeners();
    debugPrint('[Mesh] Disconnected: $endpointId (${peerCount} peers)');
  }

  /// Handle incoming payload from mesh
  void _handleIncomingPayload(String endpointId, Payload payload) {
    if (payload.type != PayloadType.BYTES || payload.bytes == null) return;

    try {
      final jsonStr = utf8.decode(payload.bytes!);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final packet = MeshPacket.fromMap(map);

      switch (MeshPacketType.values[packet.type]) {
        case MeshPacketType.message:
          _handleIncomingMessage(packet.payload, endpointId);
          break;
        case MeshPacketType.ping:
          _handlePing(endpointId, packet.payload);
          break;
        case MeshPacketType.pong:
          _handlePong(endpointId, packet.payload);
          break;
        case MeshPacketType.peerInfo:
          _handlePeerInfo(endpointId, packet.payload);
          break;
      }
    } catch (e) {
      debugPrint('[Mesh] Payload parse error: $e');
    }
  }

  /// Handle an incoming chat message — dedup + TTL relay
  void _handleIncomingMessage(Map<String, dynamic> data, String fromEndpoint) {
    final msgId = data['id'] as String;

    // Deduplication
    if (_seenMessageIds.contains(msgId)) return;
    _seenMessageIds.add(msgId);

    final message = MeshMessage.fromMap(data);

    // Save and emit
    MeshStorage.saveMessage(message);
    _messageController.add(message);

    // Relay with TTL-1 if TTL > 0
    if (message.ttl > 0) {
      final relayData = Map<String, dynamic>.from(data);
      relayData['ttl'] = message.ttl - 1;
      relayData['isRelayed'] = true;

      final packet = MeshPacket(
        type: MeshPacketType.message.index,
        payload: relayData,
      );
      _sendToAllPeers(packet, excludeId: fromEndpoint);
    }
  }

  /// Send a broadcast message to all peers
  Future<void> sendMessage(String body) async {
    final message = MeshMessage(
      id: _uuid.v4(),
      from: username,
      to: 'broadcast',
      body: body,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      ttl: _defaultTtl,
      senderRole: userRole,
    );

    // Save locally
    _seenMessageIds.add(message.id);
    await MeshStorage.saveMessage(message);
    _messageController.add(message);

    // Broadcast to mesh
    final packet = MeshPacket(
      type: MeshPacketType.message.index,
      payload: message.toMap(),
    );
    _sendToAllPeers(packet);
  }

  /// Send peer info after connecting
  void _sendPeerInfo(String endpointId) {
    final packet = MeshPacket(
      type: MeshPacketType.peerInfo.index,
      payload: {
        'username': username,
        'role': userRole,
        'deviceModel': _deviceModel,
      },
    );
    _sendToPeer(endpointId, packet);
  }

  /// Handle peer info
  void _handlePeerInfo(String endpointId, Map<String, dynamic> data) {
    final peer = _peers[endpointId];
    if (peer != null) {
      peer.displayName = data['username'] as String? ?? peer.displayName;
      peer.role = data['role'] as String?;
      peer.deviceModel = data['deviceModel'] as String?;
      notifyListeners();
    }
  }

  /// Start periodic ping
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      for (final peer in connectedPeers) {
        final packet = MeshPacket(
          type: MeshPacketType.ping.index,
          payload: {'ts': DateTime.now().millisecondsSinceEpoch},
        );
        _sendToPeer(peer.endpointId, packet);
      }
    });
  }

  /// Handle ping → send pong
  void _handlePing(String endpointId, Map<String, dynamic> data) {
    final packet = MeshPacket(
      type: MeshPacketType.pong.index,
      payload: {'ts': data['ts']},
    );
    _sendToPeer(endpointId, packet);
  }

  /// Handle pong → update last seen
  void _handlePong(String endpointId, Map<String, dynamic> data) {
    final peer = _peers[endpointId];
    if (peer != null) {
      peer.lastSeen = DateTime.now();
    }
  }

  /// Send a packet to all connected peers (optionally excluding one)
  void _sendToAllPeers(MeshPacket packet, {String? excludeId}) {
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(packet.toMap())));
    for (final peer in connectedPeers) {
      if (peer.endpointId == excludeId) continue;
      try {
        Nearby().sendBytesPayload(peer.endpointId, bytes);
      } catch (e) {
        debugPrint('[Mesh] Send error to ${peer.endpointId}: $e');
      }
    }
  }

  /// Send a packet to a specific peer
  void _sendToPeer(String endpointId, MeshPacket packet) {
    try {
      final bytes = Uint8List.fromList(utf8.encode(jsonEncode(packet.toMap())));
      Nearby().sendBytesPayload(endpointId, bytes);
    } catch (e) {
      debugPrint('[Mesh] Send error to $endpointId: $e');
    }
  }

  /// Stop the mesh
  Future<void> stopMesh() async {
    _pingTimer?.cancel();
    _isRunning = false;

    try {
      await Nearby().stopAdvertising();
      await Nearby().stopDiscovery();
      await Nearby().stopAllEndpoints();
    } catch (e) {
      debugPrint('[Mesh] Stop error: $e');
    }

    _peers.clear();
    _peerCountController.add(0);
    notifyListeners();
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    _messageController.close();
    _peerCountController.close();
    stopMesh();
    super.dispose();
  }
}
