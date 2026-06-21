import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/services/connection_provider.dart';
import 'package:grip_strength_monitor/services/websocket_service.dart';
import 'package:grip_strength_monitor/services/device_discovery_service.dart';
import 'package:grip_strength_monitor/shared/models/device_info.dart';
import 'package:grip_strength_monitor/features/game/widgets/device_discovery_screen.dart';

class ConnectionDialog extends StatefulWidget {
  final ConnectionProvider connProvider;
  final WebSocketService wsService;

  const ConnectionDialog({
    super.key,
    required this.connProvider,
    required this.wsService,
  });

  @override
  State<ConnectionDialog> createState() => _ConnectionDialogState();
}

class _ConnectionDialogState extends State<ConnectionDialog> {
  final TextEditingController _ipController = TextEditingController();
  bool _isLoading = false;
  List<DeviceInfo> _savedDevices = [];

  @override
  void initState() {
    super.initState();
    _loadSavedDevices();
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedDevices() async {
    final discovery = context.read<DeviceDiscoveryService>();
    final devices = await discovery.getSavedDevices();
    if (mounted) {
      setState(() => _savedDevices = devices);
    }
  }

  void _openDiscoveryScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeviceDiscoveryScreen()),
    );
  }

  void _connectToDevice(DeviceInfo device) async {
    setState(() => _isLoading = true);

    try {
      await widget.wsService.connect(device.ip, widget.connProvider, port: device.websocketPort);
      widget.connProvider.setConnectedDevice(device.copyWith(
        lastSeen: DateTime.now(),
        isConnected: true,
      ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เชื่อมต่อไม่สำเร็จ: $e')),
        );
      }
    }
  }

  Future<void> _connectManual() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาใส่ IP Address ของ ESP32')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.wsService.connect(ip, widget.connProvider);
      final device = DeviceInfo(
        name: 'SMART-GRIP',
        ip: ip,
        lastSeen: DateTime.now(),
        isConnected: true,
      );
      widget.connProvider.setConnectedDevice(device);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เชื่อมต่อไม่สำเร็จ: $e')),
        );
      }
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
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.wifi_rounded, color: AppTheme.primaryBlue, size: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'เชื่อมต่อ ESP32',
                    style: GoogleFonts.sarabun(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openDiscoveryScreen,
                icon: Icon(Icons.wifi_find_rounded, size: 20),
                label: Text('ค้นหาอัตโนมัติ', style: GoogleFonts.sarabun(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
              ),
            ),
            
            if (_savedDevices.isNotEmpty) ...[
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'อุปกรณ์ที่บันทึกไว้',
                  style: GoogleFonts.sarabun(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                ),
              ),
              SizedBox(height: 8),
              ...(_savedDevices.take(3).map((device) => _buildSavedDeviceCard(device))),
            ],
            
            SizedBox(height: 16),
            Divider(height: 1, color: AppTheme.separator),
            SizedBox(height: 16),
            
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                hintText: 'หรือใส่ IP ด้วยตนเอง เช่น 192.168.1.100',
                filled: true,
                fillColor: AppTheme.systemGray6,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: Icon(Icons.edit_rounded, color: AppTheme.primaryBlue, size: 20),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              keyboardType: TextInputType.number,
              style: GoogleFonts.sarabun(fontSize: 14),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(AppLocalizations.get('cancel'), style: GoogleFonts.sarabun()),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _connectManual,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: _isLoading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('เชื่อมต่อ', style: GoogleFonts.sarabun(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedDeviceCard(DeviceInfo device) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.systemGray6,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => _connectToDevice(device),
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.devices_rounded, color: AppTheme.primaryBlue, size: 18),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: GoogleFonts.sarabun(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  Text(device.ip, style: GoogleFonts.sarabun(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}
