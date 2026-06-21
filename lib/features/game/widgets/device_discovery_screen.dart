import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/services/connection_provider.dart';
import 'package:grip_strength_monitor/services/websocket_service.dart';
import 'package:grip_strength_monitor/services/auto_connection_service.dart';
import 'package:grip_strength_monitor/shared/models/device_info.dart' as models;

class DeviceDiscoveryScreen extends StatefulWidget {
  const DeviceDiscoveryScreen({super.key});

  @override
  State<DeviceDiscoveryScreen> createState() => _DeviceDiscoveryScreenState();
}

class _DeviceDiscoveryScreenState extends State<DeviceDiscoveryScreen> with SingleTickerProviderStateMixin {
  final AutoConnectionService _autoService = AutoConnectionService();
  final TextEditingController _ipController = TextEditingController();
  late AnimationController _pulseController;
  bool _isSearching = false;
  bool _isConnecting = false;
  ConnectionDeviceInfo? _device;
  int _searchCountdown = 10;
  bool _showManualInput = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ipController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _startSearch() async {
    if (_isSearching) return;

    setState(() {
      _isSearching = true;
      _device = null;
      _showManualInput = false;
      _searchCountdown = 3;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _searchCountdown--;
          if (_searchCountdown <= 0) {
            timer.cancel();
          }
        });
      }
    });

    final device = await _autoService.searchDevice();

    _countdownTimer?.cancel();
    if (mounted) {
      setState(() {
        _isSearching = false;
        _searchCountdown = 0;
        if (device != null) {
          _device = device;
          _showManualInput = false;
        } else {
          _showManualInput = true;
        }
      });
    }
  }

  Future<void> _connectManual() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาใส่ IP Address')),
      );
      return;
    }

    setState(() {
      _device = ConnectionDeviceInfo(
        name: 'SMART-GRIP',
        ip: ip,
        port: 81,
        version: '1.0',
      );
      _showManualInput = false;
    });
  }

  Future<void> _connect() async {
    if (_device == null || _isConnecting) return;

    setState(() => _isConnecting = true);

    final connProvider = context.read<ConnectionProvider>();
    final wsService = context.read<WebSocketService>();

    connProvider.setStatus(ConnectionStatus.connecting, ip: _device!.ip);

    try {
      debugPrint('[DISCOVERY] Connecting to ${_device!.ip}:${_device!.port}');
      await wsService.connect(_device!.ip, connProvider, port: _device!.port);
      debugPrint('[DISCOVERY] WebSocket connected successfully');

      connProvider.setConnectedDevice(models.DeviceInfo(
        name: _device!.name,
        ip: _device!.ip,
        websocketPort: _device!.port,
        version: _device!.version,
        lastSeen: DateTime.now(),
        isConnected: true,
      ));
      debugPrint('[DISCOVERY] Device set, returning to dashboard');

      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('[DISCOVERY] Connection failed: $e');
      connProvider.setStatus(ConnectionStatus.error, error: e.toString());
      if (mounted) {
        setState(() => _isConnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เชื่อมต่อไม่สำเร็จ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _device != null && !_showManualInput
                  ? _buildDeviceFound()
                  : _showManualInput
                      ? _buildManualInput()
                      : _buildSearchView(),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: _isConnecting ? null : () => Navigator.pop(context),
            color: AppTheme.textPrimary,
          ),
          Expanded(
            child: Text(
              'เชื่อมต่ออุปกรณ์',
              style: GoogleFonts.sarabun(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isSearching ? 1.0 + (_pulseController.value * 0.1) : 1.0,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isSearching
                            ? [AppTheme.primaryBlue, AppTheme.primaryLightBlue]
                            : [AppTheme.systemGray6, AppTheme.systemGray6],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: _isSearching
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 40,
                                offset: Offset(0, 16),
                              ),
                            ]
                          : [],
                    ),
                    child: _isSearching
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '$_searchCountdown',
                                style: GoogleFonts.sarabun(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Icon(
                            Icons.wifi_find_rounded,
                            size: 56,
                            color: AppTheme.textTertiary,
                          ),
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            Text(
              _isSearching ? 'กำลังค้นหาอุปกรณ์...' : 'กดปุ่มค้นหาเพื่อเริ่ม',
              style: GoogleFonts.sarabun(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              _isSearching ? 'ค้นหาผ่าน UDP broadcast (10 วินาที)' : 'ตรวจสอบว่า ESP32 เปิดอยู่',
              style: GoogleFonts.sarabun(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInput() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: 24),
            Text(
              'ไม่พบอุปกรณ์อัตโนมัติ',
              style: GoogleFonts.sarabun(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'กรุณาใส่ IP Address ของ ESP32 ด้วยตนเอง',
              style: GoogleFonts.sarabun(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IP Address',
                    style: GoogleFonts.sarabun(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _ipController,
                    decoration: InputDecoration(
                      hintText: 'เช่น 192.168.1.100',
                      filled: true,
                      fillColor: AppTheme.systemGray6,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.wifi_rounded, color: AppTheme.primaryBlue, size: 20),
                    ),
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: GoogleFonts.sarabun(fontSize: 15),
                    onSubmitted: (_) => _connectManual(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceFound() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.accentGreen, Color(0xFF2ECC71)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGreen.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'พบอุปกรณ์แล้ว!',
              style: GoogleFonts.sarabun(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'SMART-GRIP พร้อมเชื่อมต่อ',
              style: GoogleFonts.sarabun(
                fontSize: 14,
                color: AppTheme.accentGreen,
              ),
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDeviceInfoRow(Icons.devices_rounded, 'อุปกรณ์', _device?.name ?? '-'),
                  SizedBox(height: 12),
                  _buildDeviceInfoRow(Icons.wifi_rounded, 'IP Address', _device?.ip ?? '-'),
                  SizedBox(height: 12),
                  _buildDeviceInfoRow(Icons.info_outline_rounded, 'เวอร์ชัน', 'v${_device?.version ?? '-'}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryBlue),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.sarabun(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.sarabun(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    final bool canConnect = _device != null && !_showManualInput;
    final bool canManualConnect = _showManualInput && !_isConnecting;

    return Padding(
      padding: EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isSearching || _isConnecting
              ? null
              : canConnect
                  ? _connect
                  : canManualConnect
                      ? _connectManual
                      : _startSearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: canConnect
                ? AppTheme.accentGreen
                : AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.systemGray6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isConnecting
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _isSearching
                      ? 'กำลังค้นหา... ($_searchCountdown วินาที)'
                      : canConnect
                          ? 'เชื่อมต่อเลย'
                          : canManualConnect
                              ? 'เชื่อมต่อ'
                              : 'ค้นหาอุปกรณ์',
                  style: GoogleFonts.sarabun(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
