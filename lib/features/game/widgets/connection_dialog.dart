import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import '../services/ble_service.dart';

class ConnectionDialog extends StatefulWidget {
  final BleService bleService;
  final VoidCallback onConnected;

  const ConnectionDialog({
    super.key,
    required this.bleService,
    required this.onConnected,
  });

  @override
  State<ConnectionDialog> createState() => _ConnectionDialogState();
}

class _ConnectionDialogState extends State<ConnectionDialog> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  String? _connectingDeviceId;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    final devices = await widget.bleService.scanDevices();
    setState(() {
      _devices = devices;
      _isScanning = false;
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _connectingDeviceId = device.platformName;
    });

    final success = await widget.bleService.connectToDevice(device);

    if (success && mounted) {
      Navigator.pop(context);
      widget.onConnected();
    } else if (mounted) {
      setState(() {
        _connectingDeviceId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('connectionFailed')),
          backgroundColor: AppTheme.riskRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.bluetooth_rounded, color: AppTheme.primaryBlue, size: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.get('connectESP32'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_isScanning)
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryBlue),
                    SizedBox(height: 12),
                    Text(
                      AppLocalizations.get('scanning'),
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              )
            else if (_devices.isEmpty)
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  AppLocalizations.get('noDevicesFound'),
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    final isConnecting = _connectingDeviceId == device.platformName;

                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Icon(
                          Icons.bluetooth_rounded,
                          color: AppTheme.primaryBlue,
                        ),
                        title: Text(device.platformName),
                        subtitle: Text(device.remoteId.toString()),
                        trailing: isConnecting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.chevron_right_rounded),
                        onTap: isConnecting ? null : () => _connectToDevice(device),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(color: AppTheme.separator),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(AppLocalizations.get('cancel')),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _startScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(AppLocalizations.get('scan')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
