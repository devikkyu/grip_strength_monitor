import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:grip_strength_monitor/services/connection_provider.dart';
import 'package:flutter/material.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  ConnectionProvider? _connProvider;
  final StreamController<double> _gripStreamController = StreamController<double>.broadcast();
  Timer? _reconnectTimer;
  String? _lastConnectedIp;
  int _lastConnectedPort = 81;
  bool _shouldReconnect = true;
  DateTime? _lastPacketTime;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;

  Stream<double> get gripStream => _gripStreamController.stream;
  bool get isConnected => _channel != null;
  DateTime? get lastPacketTime => _lastPacketTime;

  Future<void> connect(String ip, ConnectionProvider connProvider, {int port = 81}) async {
    _lastConnectedIp = ip;
    _lastConnectedPort = port;
    _connProvider = connProvider;
    _reconnectAttempts = 0;
    
    _channel?.sink.close();
    _channel = null;
    
    try {
      connProvider.setStatus(ConnectionStatus.connecting, ip: ip);
      
      final url = 'ws://$ip:$port';
      final channel = WebSocketChannel.connect(Uri.parse(url));
      
      await channel.ready.timeout(Duration(seconds: 5));

      _channel = channel;
      debugPrint('WebSocket connected: $url (count: 1)');
      connProvider.setStatus(ConnectionStatus.connected, ip: ip);

      _listenToMessages();
    } catch (e) {
      connProvider.setStatus(ConnectionStatus.error, error: 'Connection failed: ${e.toString()}');
      rethrow;
    }
  }

  void _listenToMessages() {
    _channel?.stream.listen(
      (message) {
        try {
          _lastPacketTime = DateTime.now();
          
          if (message is String) {
            final data = jsonDecode(message);
            if (data is Map<String, dynamic> && data.containsKey('g')) {
              final gripValue = data['g'];
              if (gripValue is num) {
                final value = gripValue.toDouble();
                debugPrint('Received: {"g":$gripValue,"t":${data['t'] ?? ''}}');
                debugPrint('Parsed: grip=$value');
                _gripStreamController.add(value);
                
                if (_connProvider != null && _lastPacketTime != null) {
                  final latency = _calculateLatency();
                  _connProvider!.updateLatency(latency);
                }
              }
            }
          }
        } catch (e) {
          debugPrint('WebSocket JSON Decode Error: $e');
        }
      },
      onError: (error) {
        _gripStreamController.addError(error);
        _connProvider?.setStatus(ConnectionStatus.error, error: 'Stream error');
        _channel = null;
        _handleDisconnection();
      },
      onDone: () {
        _channel = null;
        _connProvider?.setStatus(ConnectionStatus.disconnected);
        _handleDisconnection();
      },
    );
  }

  int _calculateLatency() {
    if (_lastPacketTime == null) return 0;
    return DateTime.now().difference(_lastPacketTime!).inMilliseconds;
  }

  void _handleDisconnection() {
    if (_shouldReconnect && _lastConnectedIp != null) {
      _reconnectTimer?.cancel();
      
      if (_reconnectAttempts < _maxReconnectAttempts) {
        final delay = Duration(seconds: 2 * (_reconnectAttempts + 1));
        _reconnectTimer = Timer(delay, () {
          if (_lastConnectedIp != null && _connProvider != null && !isConnected) {
            _reconnectAttempts++;
            attemptReconnect(_lastConnectedIp!, _connProvider!, port: _lastConnectedPort);
          }
        });
      } else {
        debugPrint('Max reconnect attempts reached');
        _connProvider?.handleConnectionLost();
      }
    }
  }

  Future<void> attemptReconnect(String ip, ConnectionProvider connProvider, {int port = 81}) async {
    if (isConnected) return;
    
    try {
      await connect(ip, connProvider, port: port);
      _reconnectAttempts = 0;
    } catch (e) {
      debugPrint('Reconnect failed: $e');
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        connProvider.handleConnectionLost();
      }
    }
  }

  void disconnect() {
    _shouldReconnect = false;
    _channel?.sink.close();
    _channel = null;
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
  }

  void setAutoReconnect(bool enabled) {
    _shouldReconnect = enabled;
  }

  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _gripStreamController.close();
    disconnect();
  }
}
