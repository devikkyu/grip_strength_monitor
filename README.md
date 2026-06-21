# Grip Strength Monitor 🦾

แอปพลิเคชันสำหรับติดตามและวิเคราะห์ความแข็งแรงของการกำมือ (Grip Strength) พร้อมระบบฝึกฝนและเกมจังหวะดนตรี เพื่อช่วยพัฒนาและติดตามสุขภาพของกล้ามเนื้อมืออย่างมีประสิทธิภาพ

## ✨ คุณสมบัติหลัก (Key Features)

- **📊 แดชบอร์ด (Dashboard)**: สรุปผลการวัดความแข็งแรงของมือแบบเรียลไทม์และภาพรวมสุขภาพ
- **🎮 เกมจังหวะดนตรี (Rhythm Game)**: ฝึกความแข็งแรงของมือผ่านเกมที่ต้องกำมือตามจังหวะเพลง เพิ่มความสนุกในการฝึกฝน
- **🏋️ การฝึกแบบมีคำแนะนำ (Guided Training)**: โปรแกรมการฝึกที่ออกแบบมาเพื่อพัฒนาความแข็งแรงของมืออย่างเป็นระบบ
- **📈 รายงานสุขภาพ (Health Report)**: วิเคราะห์สถิติการฝึกและแนวโน้มความแข็งแรงในรูปแบบกราฟและรายงาน
- **🏆 ความสำเร็จและเป้าหมาย (Achievements & Goals)**: ตั้งเป้าหมายและรับเหรียญรางวัลเมื่อบรรลุเป้าหมายเพื่อสร้างแรงจูงใจ
- **📜 ประวัติการฝึก (Training History)**: บันทึกทุกการวัดผลและกิจกรรมการฝึกอย่างละเอียด
- **👤 โปรไฟล์และการตั้งค่า (Profile & Settings)**: จัดการข้อมูลผู้ใช้และการตั้งค่าแอปพลิเคชัน

## 🛠 สถาปัตยกรรมทางเทคนิค (Technical Architecture)

- **Frontend**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Storage**: [Hive](https://pub.dev/packages/hive) สำหรับเก็บข้อมูลประสิทธิภาพสูง
- **Communication**: เชื่อมต่อกับ ESP32 ผ่าน [WebSockets](https://pub.dev/packages/web_socket_channel) (`ws://<ip>:80`)
- **Design**: ธีมสีชมพูหลัก (#FF6B9D) และใช้ฟอนต์ Sarabun

## 🚀 การติดตั้งและใช้งาน (Installation)

1. **Clone Repository**:
   ```bash
   git clone https://github.com/devikkyu/grip_strength_monitor.git
   cd grip_strength_monitor
   ```

2. **ติดตั้ง Dependencies**:
   ```bash
   flutter pub get
   ```

3. **รันแอปพลิเคชัน**:
   ```bash
   flutter run
   ```

## 📡 การเชื่อมต่อฮาร์ดแวร์ (Hardware Connection)

แอปพลิเคชันเชื่อมต่อกับอุปกรณ์วัดแรงกำมือที่ใช้ ESP32 ผ่าน WebSocket โดยใช้รูปแบบข้อมูล JSON ดังนี้:
```json
{
  "grip": 12.5,
  "timestamp": 1718000000
}
```

## 📁 โครงสร้างโปรเจกต์ (Project Structure)

```text
lib/
├── core/           # โครงสร้างพื้นฐาน (Theme, Utils)
├── features/       # แบ่งตามฟีเจอร์ (Dashboard, Game, Training, etc.)
├── services/       # Business Logic และ State Providers
└── shared/         # Models และ Components ที่ใช้ร่วมกัน
```

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
