class DeviceInfo {
  final String name;
  final String ip;
  final String version;
  final int websocketPort;
  final DateTime lastSeen;
  final bool isConnected;
  final int latencyMs;
  final int rssi;
  final String healthQuality;

  const DeviceInfo({
    required this.name,
    required this.ip,
    this.version = '1.0',
    this.websocketPort = 81,
    required this.lastSeen,
    this.isConnected = false,
    this.latencyMs = 0,
    this.rssi = 0,
    this.healthQuality = 'Offline',
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      name: json['name'] ?? 'SMART-GRIP',
      ip: json['ip'] ?? '',
      version: json['version'] ?? '1.0',
      websocketPort: json['websocketPort'] ?? 81,
      lastSeen: DateTime.parse(json['lastSeen'] ?? DateTime.now().toIso8601String()),
      isConnected: json['isConnected'] ?? false,
      latencyMs: json['latencyMs'] ?? 0,
      rssi: json['rssi'] ?? 0,
      healthQuality: json['healthQuality'] ?? 'Offline',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ip': ip,
      'version': version,
      'websocketPort': websocketPort,
      'lastSeen': lastSeen.toIso8601String(),
      'isConnected': isConnected,
      'latencyMs': latencyMs,
      'rssi': rssi,
      'healthQuality': healthQuality,
    };
  }

  DeviceInfo copyWith({
    String? name,
    String? ip,
    String? version,
    int? websocketPort,
    DateTime? lastSeen,
    bool? isConnected,
    int? latencyMs,
    int? rssi,
    String? healthQuality,
  }) {
    return DeviceInfo(
      name: name ?? this.name,
      ip: ip ?? this.ip,
      version: version ?? this.version,
      websocketPort: websocketPort ?? this.websocketPort,
      lastSeen: lastSeen ?? this.lastSeen,
      isConnected: isConnected ?? this.isConnected,
      latencyMs: latencyMs ?? this.latencyMs,
      rssi: rssi ?? this.rssi,
      healthQuality: healthQuality ?? this.healthQuality,
    );
  }

  String get lastSeenFormatted {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);
    if (diff.inMinutes < 1) return 'เมื่อสักครู่';
    if (diff.inHours < 1) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inDays < 1) return '${diff.inHours} ชั่วโมงที่แล้ว';
    return '${diff.inDays} วันที่แล้ว';
  }

  String get rssiQuality {
    if (rssi > -60) return 'Excellent';
    if (rssi > -70) return 'Good';
    if (rssi > -80) return 'Weak';
    return 'Poor';
  }
}
