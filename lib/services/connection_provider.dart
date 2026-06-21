import 'package:flutter/material.dart';
import 'dart:async';
import 'package:grip_strength_monitor/shared/models/device_info.dart';
import 'package:grip_strength_monitor/services/device_discovery_service.dart';

enum ConnectionStatus { disconnected, connecting, connected, error, discovering }

class DeviceHealth {
  final DateTime? lastPacketTime;
  final int latencyMs;
  final Duration uptime;
  final String quality;

  const DeviceHealth({
    this.lastPacketTime,
    this.latencyMs = 0,
    this.uptime = Duration.zero,
    this.quality = 'Offline',
  });

  factory DeviceHealth.excellent() => DeviceHealth(
    lastPacketTime: DateTime.now(),
    latencyMs: 10,
    quality: 'Excellent',
  );

  factory DeviceHealth.good() => DeviceHealth(
    lastPacketTime: DateTime.now(),
    latencyMs: 50,
    quality: 'Good',
  );

  factory DeviceHealth.weak() => DeviceHealth(
    lastPacketTime: DateTime.now(),
    latencyMs: 150,
    quality: 'Weak',
  );

  factory DeviceHealth.offline() => DeviceHealth(
    quality: 'Offline',
  );
}

class ConnectionProvider extends ChangeNotifier {
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String _errorMessage = '';
  String? _connectedIp;
  DeviceInfo? _connectedDevice;
  List<DeviceInfo> _discoveredDevices = [];
  Timer? _healthCheckTimer;
  StreamSubscription<List<DeviceInfo>>? _discoverySubscription;
  DateTime? _connectionStartTime;
  DeviceHealth _deviceHealth = DeviceHealth.offline();
  
  final DeviceDiscoveryService _discoveryService = DeviceDiscoveryService();

  ConnectionStatus get status => _status;
  String get errorMessage => _errorMessage;
  String? get connectedIp => _connectedIp;
  DeviceInfo? get connectedDevice => _connectedDevice;
  List<DeviceInfo> get discoveredDevices => List.unmodifiable(_discoveredDevices);
  bool get isConnected => _status == ConnectionStatus.connected;
  DeviceHealth get deviceHealth => _deviceHealth;
  Duration get connectionUptime => _connectionStartTime != null 
      ? DateTime.now().difference(_connectionStartTime!) 
      : Duration.zero;

  ConnectionProvider() {
    _listenToDiscovery();
  }

  void _listenToDiscovery() {
    _discoverySubscription?.cancel();
    _discoverySubscription = _discoveryService.devicesStream.listen((devices) {
      _discoveredDevices = devices;
      notifyListeners();
    });
  }

  void setStatus(ConnectionStatus status, {String? error, String? ip}) {
    _status = status;
    if (error != null) _errorMessage = error;
    if (ip != null) _connectedIp = ip;
    notifyListeners();
  }

  void setConnectedDevice(DeviceInfo device) {
    _connectedDevice = device;
    _connectedIp = device.ip;
    _status = ConnectionStatus.connected;
    _errorMessage = '';
    _connectionStartTime = DateTime.now();
    _deviceHealth = DeviceHealth(
      lastPacketTime: DateTime.now(),
      latencyMs: 0,
      uptime: Duration.zero,
      quality: device.rssiQuality,
    );
    _discoveryService.saveLastDevice(device);
    _discoveryService.addOrUpdateDevice(device.copyWith(isConnected: true));
    _startHealthMonitoring();
    debugPrint('[AUTO] Connected: ${device.ip}:${device.websocketPort}');
    notifyListeners();
  }

  void updateHealth(DeviceHealth health) {
    _deviceHealth = health;
    notifyListeners();
  }

  void updateLatency(int latencyMs) {
    _deviceHealth = DeviceHealth(
      lastPacketTime: DateTime.now(),
      latencyMs: latencyMs,
      uptime: connectionUptime,
      quality: _calculateQuality(latencyMs),
    );
    notifyListeners();
  }

  String _calculateQuality(int latencyMs) {
    if (latencyMs < 30) return 'Excellent';
    if (latencyMs < 100) return 'Good';
    if (latencyMs < 200) return 'Weak';
    return 'Offline';
  }

  void _startHealthMonitoring() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(Duration(seconds: 15), (_) async {
      if (!isConnected || _connectedDevice == null) {
        _healthCheckTimer?.cancel();
        return;
      }
      
      final statusData = await _discoveryService.fetchStatus(_connectedDevice!.ip);
      if (statusData != null) {
        final rssi = statusData['rssi'] as int? ?? _connectedDevice!.rssi;
        _connectedDevice = _connectedDevice!.copyWith(rssi: rssi);
        _deviceHealth = DeviceHealth(
          lastPacketTime: DateTime.now(),
          latencyMs: _deviceHealth.latencyMs,
          uptime: connectionUptime,
          quality: _connectedDevice!.rssiQuality,
        );
        notifyListeners();
      }
    });
  }

  Future<void> startDiscovery() async {
    _status = ConnectionStatus.discovering;
    notifyListeners();
    await _discoveryService.startDiscovery();
  }

  Future<void> stopDiscovery() async {
    await _discoveryService.stopDiscovery();
    if (_status == ConnectionStatus.discovering) {
      _status = ConnectionStatus.disconnected;
      notifyListeners();
    }
  }

  Future<bool> connectToDevice(DeviceInfo device) async {
    _status = ConnectionStatus.connecting;
    _connectedIp = device.ip;
    notifyListeners();
    return true;
  }

  void disconnect() {
    _healthCheckTimer?.cancel();
    if (_connectedDevice != null) {
      _discoveryService.addOrUpdateDevice(_connectedDevice!.copyWith(isConnected: false));
    }
    _status = ConnectionStatus.disconnected;
    _connectedIp = null;
    _connectedDevice = null;
    _errorMessage = '';
    _deviceHealth = DeviceHealth.offline();
    _connectionStartTime = null;
    notifyListeners();
  }

  void handleConnectionLost() {
    _status = ConnectionStatus.disconnected;
    _connectedDevice = null;
    _deviceHealth = DeviceHealth.offline();
    _connectionStartTime = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    _discoverySubscription?.cancel();
    super.dispose();
  }
}
