import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static const String serviceUuid = '0000fff0-0000-1000-8000-00805f9b34fb';
  static const String characteristicUuid = '0000fff1-0000-1000-8000-00805f9b34fb';

  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  StreamController<double> _gripStreamController = StreamController<double>.broadcast();

  Stream<double> get gripStream => _gripStreamController.stream;
  bool get isConnected => _device != null && _characteristic != null;

  Future<List<BluetoothDevice>> scanDevices() async {
    final devices = <BluetoothDevice>[];

    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    await for (final results in FlutterBluePlus.scanResults) {
      for (final result in results) {
        if (result.device.platformName.isNotEmpty &&
            !devices.any((d) => d.remoteId == result.device.remoteId)) {
          devices.add(result.device);
        }
      }
    }

    FlutterBluePlus.stopScan();
    return devices;
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _device = device;

      final services = await device.discoverServices();
      for (final service in services) {
        for (final char in service.characteristics) {
          if (char.uuid.toString() == characteristicUuid) {
            _characteristic = char;
            await char.setNotifyValue(true);
            _listenToCharacteristic();
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void _listenToCharacteristic() {
    if (_characteristic == null) return;

    _characteristic!.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        final bytes = value;
        if (bytes.length >= 4) {
          final gripValue = _bytesToDouble(bytes);
          _gripStreamController.add(gripValue);
        }
      }
    });
  }

  double _bytesToDouble(List<int> bytes) {
    final byteData = ByteData(4);
    for (int i = 0; i < 4; i++) {
      byteData.setUint8(i, bytes[i]);
    }
    return byteData.getFloat32(0, Endian.little);
  }

  Future<void> disconnect() async {
    await _device?.disconnect();
    _device = null;
    _characteristic = null;
  }

  void dispose() {
    _gripStreamController.close();
    disconnect();
  }
}
