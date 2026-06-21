import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:grip_strength_monitor/services/connection_provider.dart';
import 'package:flutter/material.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  ConnectionProvider? _connProvider;
  final StreamController<double> _gripStreamController = StreamController<double>.broadcast();

  Stream<double> get gripStream => _gripStreamController.stream;
  bool get isConnected => _channel != null;

  Future<void> connect(String ip, ConnectionProvider connProvider) async {
    try {
      final url = 'ws://$ip:80';
      final channel = WebSocketChannel.connect(Uri.parse(url));
      await channel.ready;

      _channel = channel;
      _connProvider = connProvider;
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
          if (message is String) {
            final data = jsonDecode(message);
            if (data is Map<String, dynamic> && data.containsKey('grip')) {
              final value = (data['grip'] as num).toDouble();
              _gripStreamController.add(value);
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
      },
      onDone: () {
        _channel = null;
        _connProvider?.setStatus(ConnectionStatus.disconnected);
      },
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    _gripStreamController.close();
    disconnect();
  }
}
