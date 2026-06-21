import 'package:flutter/material.dart';

enum ConnectionStatus { disconnected, connecting, connected, error }

class ConnectionProvider extends ChangeNotifier {
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String _errorMessage = '';
  String? _connectedIp;

  ConnectionStatus get status => _status;
  String get errorMessage => _errorMessage;
  String? get connectedIp => _connectedIp;

  bool get isConnected => _status == ConnectionStatus.connected;

  void setStatus(ConnectionStatus status, {String? error, String? ip}) {
    _status = status;
    if (error != null) _errorMessage = error;
    if (ip != null) _connectedIp = ip;
    notifyListeners();
  }

  void disconnect() {
    _status = ConnectionStatus.disconnected;
    _connectedIp = null;
    _errorMessage = '';
    notifyListeners();
  }
}
