import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/services/connection_provider.dart';
import 'package:grip_strength_monitor/services/websocket_service.dart';

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

  Future<void> _connect() async {
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
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เชื่อมต่อไม่สำเร็จ: $e')),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                hintText: 'เช่น 192.168.1.100',
                filled: true,
                fillColor: AppTheme.systemGray6,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: Icon(Icons.network_wifi_rounded, color: AppTheme.primaryBlue),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(color: AppTheme.separator),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(AppLocalizations.get('cancel')),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _isLoading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('เชื่อมต่อ'),
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
