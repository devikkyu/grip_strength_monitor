import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum AutoConnectState { idle, searching, connected, disconnected }

class ConnectionDeviceInfo {
  final String name;
  final String ip;
  final int port;
  final String version;

  ConnectionDeviceInfo({
    required this.name,
    required this.ip,
    this.port = 81,
    this.version = '1.0',
  });
}

class DeviceDiscovery {
  static const int udpPort = 4210;
  static const String broadcastMsg = 'SMARTGRIP_DISCOVER';

  static Future<String?> discover({Duration timeout = const Duration(seconds: 3)}) async {
    RawDatagramSocket? sock;
    try {
      debugPrint('[DISCOVERY] Binding UDP socket');
      sock = await RawDatagramSocket.bind(
        InternetAddress('0.0.0.0'),
        0,
        reuseAddress: true,
        reusePort: false,
      );
      sock.broadcastEnabled = true;
      sock.readEventsEnabled = true;

      debugPrint('[DISCOVERY] Sending broadcast to 255.255.255.255:$udpPort');
      final msg = utf8.encode(broadcastMsg);

      for (int i = 0; i < 3; i++) {
        sock.send(msg, InternetAddress('255.255.255.255'), udpPort);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final completer = Completer<String?>();

      final sub = sock.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = sock?.receive();
          if (datagram == null) return;

          try {
            final raw = utf8.decode(datagram.data);
            debugPrint('[DISCOVERY] Got response: $raw');
            final json = jsonDecode(raw) as Map<String, dynamic>;
            if (json['device'] == 'SMART-GRIP' && !completer.isCompleted) {
              completer.complete(json['ip'] as String);
            }
          } catch (e) {
            debugPrint('[DISCOVERY] Parse error: $e');
          }
        }
      });

      final result = await completer.future.timeout(
        timeout,
        onTimeout: () {
          debugPrint('[DISCOVERY] Timeout after ${timeout.inSeconds}s');
          return null;
        },
      );

      await sub.cancel();
      return result;
    } catch (e) {
      debugPrint('[DISCOVERY] Error: $e');
      return null;
    } finally {
      sock?.close();
    }
  }

  static Future<bool> checkHost(String ip) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(milliseconds: 500);
      final req = await client.get(ip, 80, '/');
      final res = await req.close().timeout(Duration(milliseconds: 500));
      final body = await res.transform(utf8.decoder).join();
      client.close();
      if (body.contains('SMART-GRIP')) {
        debugPrint('[SCAN] Found device at $ip');
        return true;
      }
    } catch (_) {}
    return false;
  }
}

class AutoConnectionService {
  static final AutoConnectionService _instance = AutoConnectionService._();
  factory AutoConnectionService() => _instance;
  AutoConnectionService._();

  static const String _lastDeviceIpKey = 'last_device_ip';
  static const String _lastDevicePortKey = 'last_device_port';
  static const String _settingsBox = 'settings';
  static const int _defaultPort = 81;

  final StreamController<AutoConnectState> _stateController = StreamController<AutoConnectState>.broadcast();
  Stream<AutoConnectState> get stateStream => _stateController.stream;

  AutoConnectState _state = AutoConnectState.idle;
  AutoConnectState get state => _state;
  String? _connectedIp;
  int _connectedPort = _defaultPort;
  String? get connectedIp => _connectedIp;
  int get connectedPort => _connectedPort;
  ConnectionDeviceInfo? _foundDevice;
  ConnectionDeviceInfo? get foundDevice => _foundDevice;

  bool _isRunning = false;

  void _log(String message) {
    debugPrint('[AUTO] $message');
  }

  void _setState(AutoConnectState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  Future<ConnectionDeviceInfo?> searchDevice() async {
    if (_isRunning) return _foundDevice;
    _isRunning = true;
    _setState(AutoConnectState.searching);
    _log('Starting UDP discovery (3s timeout)');

    String? ip = await DeviceDiscovery.discover(timeout: Duration(seconds: 3));
    if (ip != null) {
      _log('Found via broadcast: $ip');
      _foundDevice = ConnectionDeviceInfo(name: 'SMART-GRIP', ip: ip, port: _defaultPort);
      _setState(AutoConnectState.connected);
      _isRunning = false;
      return _foundDevice;
    }

    _log('No device found via UDP');
    _foundDevice = null;
    _setState(AutoConnectState.disconnected);
    _isRunning = false;
    return null;
  }

  Future<ConnectionDeviceInfo?> searchDeviceByHostname(String hostname) async {
    return searchDevice();
  }

  Future<bool> connectToDevice(ConnectionDeviceInfo device) async {
    try {
      _log('Connecting to ${device.ip}:${device.port}');
      final url = 'ws://${device.ip}:${device.port}';
      final channel = WebSocketChannel.connect(Uri.parse(url));
      await channel.ready.timeout(Duration(seconds: 5));
      await channel.sink.close();

      _connectedIp = device.ip;
      _connectedPort = device.port;
      _saveDevice(device.ip, device.port);
      _setState(AutoConnectState.connected);
      _log('Connected');
      return true;
    } catch (e) {
      _log('Connection failed: $e');
      return false;
    }
  }

  Future<void> _saveDevice(String ip, int port) async {
    try {
      final box = await Hive.openBox(_settingsBox);
      await box.put(_lastDeviceIpKey, ip);
      await box.put(_lastDevicePortKey, port);
    } catch (_) {}
  }

  void disconnect() {
    _setState(AutoConnectState.disconnected);
    _connectedIp = null;
    _foundDevice = null;
    _log('Disconnected');
  }

  void reset() {
    _foundDevice = null;
    _setState(AutoConnectState.idle);
  }

  void dispose() {
    _stateController.close();
  }
}
