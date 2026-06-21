import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:grip_strength_monitor/shared/models/device_info.dart';
import 'package:grip_strength_monitor/services/persistence_service.dart';

class DeviceDiscoveryService {
  static final DeviceDiscoveryService _instance = DeviceDiscoveryService._();
  factory DeviceDiscoveryService() => _instance;
  DeviceDiscoveryService._();

  final PersistenceService _persistence = PersistenceService();
  final StreamController<List<DeviceInfo>> _devicesController = StreamController<List<DeviceInfo>>.broadcast();
  Stream<List<DeviceInfo>> get devicesStream => _devicesController.stream;
  
  List<DeviceInfo> _discoveredDevices = [];
  List<DeviceInfo> get discoveredDevices => List.unmodifiable(_discoveredDevices);
  
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  static const String _lastDeviceKey = 'last_connected_device';
  static const String _savedDevicesKey = 'saved_devices';
  static const String _mdnsHostname = 'smartgrip.local';
  static const Duration _scanTimeout = Duration(seconds: 3);
  static const Duration _connectTimeout = Duration(seconds: 2);
  static const int _maxConcurrentScans = 50;
  static const int _httpPort = 80;

  Future<DeviceInfo?> getLastDevice() async {
    final saved = _persistence.get('devices', _lastDeviceKey);
    if (saved != null) {
      return DeviceInfo.fromJson(Map<String, dynamic>.from(saved));
    }
    return null;
  }

  Future<void> saveLastDevice(DeviceInfo device) async {
    _persistence.save('devices', _lastDeviceKey, device.toJson());
  }

  Future<List<DeviceInfo>> getSavedDevices() async {
    final saved = _persistence.get('devices', _savedDevicesKey);
    if (saved != null) {
      return (saved as List).map((d) => DeviceInfo.fromJson(Map<String, dynamic>.from(d))).toList();
    }
    return [];
  }

  Future<void> saveDevices(List<DeviceInfo> devices) async {
    _persistence.save('devices', _savedDevicesKey, devices.map((d) => d.toJson()).toList());
  }

  Future<void> addOrUpdateDevice(DeviceInfo device) async {
    final devices = await getSavedDevices();
    final existingIndex = devices.indexWhere((d) => d.ip == device.ip);
    if (existingIndex >= 0) {
      devices[existingIndex] = device;
    } else {
      devices.add(device);
    }
    await saveDevices(devices);
  }

  Future<DeviceInfo?> tryConnectToLastDevice() async {
    final lastDevice = await getLastDevice();
    if (lastDevice == null) {
      debugPrint('[Discovery] No last device saved');
      return null;
    }

    debugPrint('[Discovery] Trying last device: ${lastDevice.ip}:${lastDevice.websocketPort}');
    final device = await _discoverDevice(lastDevice.ip);
    if (device != null) {
      return device.copyWith(lastSeen: DateTime.now(), isConnected: true);
    }
    debugPrint('[Discovery] Last device unreachable');
    return null;
  }

  Future<DeviceInfo?> _discoverDevice(String ip) async {
    debugPrint('[Discovery] === Discovering device at $ip ===');
    
    final httpClientData = await _httpDiscovery(ip);
    if (httpClientData == null) {
      debugPrint('[Discovery] STEP 1 FAILED: HTTP discovery returned null for $ip');
      return null;
    }
    debugPrint('[Discovery] STEP 1 OK: HTTP response = $httpClientData');

    final wsPort = httpClientData['websocket_port'] as int? ?? 81;
    debugPrint('[Discovery] STEP 2: websocket_port = $wsPort');

    int rssi = 0;
    final statusData = await _httpStatus(ip);
    if (statusData != null) {
      rssi = statusData['rssi'] as int? ?? 0;
      debugPrint('[Discovery] STEP 3 OK: RSSI = $rssi');
    } else {
      debugPrint('[Discovery] STEP 3: /status returned null, using default RSSI=0');
    }

    final device = DeviceInfo(
      name: httpClientData['device'] ?? 'SMART-GRIP',
      ip: ip,
      version: httpClientData['version'] ?? '1.0',
      websocketPort: wsPort,
      rssi: rssi,
      lastSeen: DateTime.now(),
      isConnected: true,
    );
    debugPrint('[Discovery] STEP 4 OK: Device created = ${device.name} ${device.ip}:${device.websocketPort} RSSI=${device.rssi}');
    return device;
  }

  Future<Map<String, dynamic>?> _httpDiscovery(String ip) async {
    try {
      debugPrint('[Discovery] HTTP GET http://$ip:$_httpPort/');
      final client = HttpClient();
      client.connectionTimeout = _connectTimeout;
      
      final request = await client.getUrl(Uri.parse('http://$ip:$_httpPort/'));
      final response = await request.close().timeout(_connectTimeout);
      
      debugPrint('[Discovery] HTTP response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final body = await response.transform(SystemEncoding().decoder).join();
        debugPrint('[Discovery] HTTP body: $body');
        try {
          final data = jsonDecode(body) as Map<String, dynamic>;
          final deviceName = data['device'];
          debugPrint('[Discovery] Parsed device field: "$deviceName"');
          if (deviceName == 'SMART-GRIP') {
            client.close(force: false);
            debugPrint('[Discovery] HTTP discovery SUCCESS');
            return data;
          } else {
            debugPrint('[Discovery] HTTP discovery REJECTED: device="$deviceName" != "SMART-GRIP"');
          }
        } catch (e) {
          debugPrint('[Discovery] HTTP body JSON parse error: $e');
        }
      }
      client.close(force: false);
    } catch (e) {
      debugPrint('[Discovery] HTTP discovery EXCEPTION: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _httpStatus(String ip) async {
    try {
      debugPrint('[Discovery] HTTP GET http://$ip:$_httpPort/status');
      final client = HttpClient();
      client.connectionTimeout = _connectTimeout;
      
      final request = await client.getUrl(Uri.parse('http://$ip:$_httpPort/status'));
      final response = await request.close().timeout(_connectTimeout);
      
      debugPrint('[Discovery] /status response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final body = await response.transform(SystemEncoding().decoder).join();
        debugPrint('[Discovery] /status body: $body');
        try {
          final data = jsonDecode(body) as Map<String, dynamic>;
          client.close(force: false);
          return data;
        } catch (e) {
          debugPrint('[Discovery] /status JSON parse error: $e');
        }
      }
      client.close(force: false);
    } catch (e) {
      debugPrint('[Discovery] /status EXCEPTION: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchStatus(String ip) async {
    return await _httpStatus(ip);
  }

  Future<void> startDiscovery() async {
    if (_isScanning) {
      debugPrint('[Discovery] Already scanning, skipping');
      return;
    }
    _isScanning = true;
    _discoveredDevices = [];
    _devicesController.add(_discoveredDevices);
    debugPrint('[Discovery] === Starting discovery ===');

    final mdnsIp = await _tryMdns();
    debugPrint('[Discovery] mDNS result: ${mdnsIp ?? "null"}');
    
    if (mdnsIp != null) {
      debugPrint('[Discovery] mDNS found device, stopping scan');
      _isScanning = false;
      _devicesController.add(_discoveredDevices);
      debugPrint('[Discovery] Devices in list: ${_discoveredDevices.length}');
      return;
    }

    debugPrint('[Discovery] mDNS failed, starting LAN scan');
    await _discoverViaLanScan();

    _isScanning = false;
    _devicesController.add(_discoveredDevices);
    debugPrint('[Discovery] === Discovery complete. Devices found: ${_discoveredDevices.length} ===');
  }

  Future<String?> _tryMdns() async {
    try {
      debugPrint('[Discovery] Resolving mDNS: $_mdnsHostname');
      final result = await InternetAddress.lookup(_mdnsHostname)
          .timeout(_scanTimeout);
      
      debugPrint('[Discovery] mDNS resolved to ${result.length} addresses');
      
      for (final address in result) {
        final ip = address.address;
        debugPrint('[Discovery] mDNS address: $ip');
        
        final device = await _discoverDevice(ip);
        if (device != null) {
          debugPrint('[Discovery] mDNS device found: ${device.name} ${device.ip}:${device.websocketPort}');
          _discoveredDevices.add(device);
          _devicesController.add(_discoveredDevices);
          debugPrint('[Discovery] Devices list now: ${_discoveredDevices.length}');
          return ip;
        } else {
          debugPrint('[Discovery] mDNS address $ip did not yield a valid device');
        }
      }
    } catch (e) {
      debugPrint('[Discovery] mDNS EXCEPTION: $e');
    }
    return null;
  }

  Future<void> _discoverViaLanScan() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      debugPrint('[Discovery] LAN scan: ${interfaces.length} network interfaces');
      
      for (final interface in interfaces) {
        debugPrint('[Discovery] Interface: ${interface.name}');
        for (final addr in interface.addresses) {
          if (addr.isLoopback) continue;
          
          final subnet = _getSubnet(addr.address);
          if (subnet == null) continue;

          debugPrint('[Discovery] Scanning subnet: $subnet.*');
          await _scanSubnetParallel(subnet);
        }
      }
    } catch (e) {
      debugPrint('[Discovery] LAN scan EXCEPTION: $e');
    }
  }

  String? _getSubnet(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return null;
    return '${parts[0]}.${parts[1]}.${parts[2]}';
  }

  Future<void> _scanSubnetParallel(String subnet) async {
    final allIps = List.generate(254, (i) => '$subnet.${i + 1}');
    final remaining = allIps.where((ip) => !_discoveredDevices.any((d) => d.ip == ip)).toList();
    
    debugPrint('[Discovery] Scanning ${remaining.length} IPs in batches of $_maxConcurrentScans');
    
    for (var i = 0; i < remaining.length; i += _maxConcurrentScans) {
      if (!_isScanning) break;
      
      final batch = remaining.skip(i).take(_maxConcurrentScans).toList();
      debugPrint('[Discovery] Batch ${i ~/ _maxConcurrentScans + 1}: testing ${batch.length} IPs');
      final futures = batch.map((ip) => _tryDiscover(ip)).toList();
      await Future.wait(futures);
      debugPrint('[Discovery] Devices found so far: ${_discoveredDevices.length}');
    }
  }

  Future<void> _tryDiscover(String ip) async {
    try {
      final device = await _discoverDevice(ip);
      if (device != null && !_discoveredDevices.any((d) => d.ip == ip)) {
        _discoveredDevices.add(device);
        _devicesController.add(_discoveredDevices);
        debugPrint('[Discovery] DEVICE FOUND: ${device.name} ${device.ip}:${device.websocketPort}');
      }
    } catch (e) {
      debugPrint('[Discovery] _tryDiscover($ip) EXCEPTION: $e');
    }
  }

  Future<void> stopDiscovery() async {
    _isScanning = false;
  }

  Future<DeviceInfo?> tryMdnsDiscovery() async {
    try {
      debugPrint('[AUTO] Resolving mDNS: $_mdnsHostname');
      final result = await InternetAddress.lookup(_mdnsHostname)
          .timeout(_scanTimeout);
      
      debugPrint('[AUTO] mDNS resolved: ${result.length} addresses');
      
      for (final address in result) {
        final ip = address.address;
        debugPrint('[AUTO] mDNS trying: $ip');
        
        final device = await _discoverDevice(ip);
        if (device != null) {
          debugPrint('[AUTO] mDNS found: ${device.ip}:${device.websocketPort}');
          return device;
        }
      }
    } catch (e) {
      debugPrint('[AUTO] mDNS failed: $e');
    }
    return null;
  }

  Future<DeviceInfo?> tryLanScanFast() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.isLoopback) continue;
          
          final subnet = _getSubnet(addr.address);
          if (subnet == null) continue;

          debugPrint('[AUTO] Fast LAN scan: $subnet.*');
          final device = await _scanSubnetFast(subnet);
          if (device != null) return device;
        }
      }
    } catch (e) {
      debugPrint('[AUTO] LAN scan failed: $e');
    }
    return null;
  }

  Future<DeviceInfo?> _scanSubnetFast(String subnet) async {
    final allIps = List.generate(254, (i) => '$subnet.${i + 1}');
    
    for (var i = 0; i < allIps.length; i += _maxConcurrentScans) {
      if (!_isScanning && _autoDiscoveryActive) break;
      
      final batch = allIps.skip(i).take(_maxConcurrentScans).toList();
      final futures = batch.map((ip) => _tryDiscoverFast(ip)).toList();
      final results = await Future.wait(futures);
      
      for (final device in results) {
        if (device != null) return device;
      }
    }
    return null;
  }

  bool _autoDiscoveryActive = true;

  Future<DeviceInfo?> _tryDiscoverFast(String ip) async {
    try {
      final device = await _discoverDevice(ip);
      if (device != null) {
        debugPrint('[AUTO] LAN found: ${device.ip}:${device.websocketPort}');
        _autoDiscoveryActive = false;
        return device;
      }
    } catch (_) {}
    return null;
  }

  void resetAutoDiscovery() {
    _autoDiscoveryActive = true;
  }

  void dispose() {
    _devicesController.close();
  }
}
