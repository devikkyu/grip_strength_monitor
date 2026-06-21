# Grip Strength Monitor 🦾
แอปพลิเคชันสำหรับติดตามและวิเคราะห์ความแข็งแรงของการกำมือ (Grip Strength) พร้อมระบบฝึกฝนและเกมจังหวะดนตรี เพื่อช่วยพัฒนาและติดตามสุขภาพของกล้ามเนื้อมืออย่างมีประสิทธิภาพ

## ✨ คุณสมบัติหลัก (Key Features)

### 📊 การติดตามและวิเคราะห์ (Monitoring & Analysis)
- **แดชบอร์ด (Dashboard)**: สรุปผลการวัดความแข็งแรงแบบเรียลไทม์และภาพรวมสุขภาพในหน้าเดียว
- **รายงานสุขภาพ (Health Report)**: วิเคราะห์สถิติการฝึกและแนวโน้มความแข็งแรงในรูปแบบกราฟและรายงานเชิงลึก
- **สถิติโดยละเอียด (Statistics)**: ติดตามพัฒนาการของความแข็งแรงและการใช้งานในระยะยาว
- **ปฏิทินความต่อเนื่อง (Streak Calendar)**: ติดตามความสม่ำเสมอในการฝึกฝนเพื่อสร้างวินัย

### 🎮 การฝึกฝนผ่านเกม (Gamified Training)
- **เกมจังหวะดนตรี (Rhythm Games)**: ฝึกความแข็งแรงของมือผ่านการกำมือตามจังหวะเพลง ประกอบด้วย:
    - **Music Rhythm**: ฝึกพื้นฐานตามจังหวะเพลง
    - **Grip Rhythm**: เน้นการกำที่แม่นยำและทรงพลัง
    - **Smart Rhythm**: ระบบจังหวะอัจฉริยะที่ปรับตามความสามารถ
- **ระบบค้นหาอุปกรณ์ (Device Discovery)**: ค้นหาและเชื่อมต่อกับอุปกรณ์ ESP32 ได้โดยอัตโนมัติผ่านเครือข่าย

### 🏋️ โปรแกรมการฝึกและเป้าหมาย (Training & Goals)
- **การฝึกแบบมีคำแนะนำ (Guided Training)**: โปรแกรมการฝึกที่ออกแบบมาเพื่อพัฒนาความแข็งแรงของมืออย่างเป็นระบบ
- **เป้าหมายและความสำเร็จ (Goals & Achievements)**: ตั้งเป้าหมายส่วนตัวและสะสมเหรียญรางวัลเมื่อบรรลุความสำเร็จ
- **ประวัติการฝึก (Training History)**: บันทึกรายละเอียดทุกเซสชันการฝึกเพื่อเปรียบเทียบผลลัพธ์

### 👤 การจัดการส่วนตัว (User Management)
- **โปรไฟล์และการตั้งค่า (Profile & Settings)**: ปรับแต่งข้อมูลส่วนตัวและการตั้งค่าการใช้งานแอปพลิเคชัน

## 🛠 สถาปัตยกรรมทางเทคนิค (Technical Architecture)

### Tech Stack
- **Frontend**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Provider](https://pub.dev/packages/provider) - จัดการสถานะแอปพลิเคชันแบบ Reactive
- **Local Storage**: [Hive](https://pub.dev/packages/hive) - เก็บข้อมูล Local DB ประสิทธิภาพสูง
- **Communication**: [WebSockets](https://pub.dev/packages/web_socket_channel) (`ws://<ip>:80`) - รับส่งข้อมูลเรียลไทม์จาก ESP32
- **Audio Engine**: [just_audio](https://pub.dev/packages/just_audio) & [audio_session](https://pub.dev/packages/audio_session)
- **Design**: ธีมสีชมพูหลัก (`#FF6B9D`) และใช้ฟอนต์ **Sarabun** จาก Google Fonts

### Data Format (Hardware)
อุปกรณ์ ESP32 จะส่งข้อมูลในรูปแบบ JSON ผ่าน WebSocket:
```json
{
  "grip": 12.5,
  "timestamp": 1718000000
}
```

## 🚀 การติดตั้งและใช้งาน (Installation)

### ความต้องการพื้นฐาน (Prerequisites)
- Flutter SDK (เวอร์ชัน 3.12.2 ขึ้นไป)
- อุปกรณ์ที่รัน Flutter (Android/iOS)
- อุปกรณ์วัดแรงกำมือ (ESP32) ที่เชื่อมต่อวง LAN เดียวกับมือถือ

### ขั้นตอนการติดตั้ง (Steps)
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

## 📁 โครงสร้างโปรเจกต์ (Project Structure)

```text
lib/
├── core/           # โครงสร้างพื้นฐาน (Theme, Utils, AppLocalizations)
├── features/       # ฟีเจอร์แยกตามโมดูล (Dashboard, Game, Training, Profile, etc.)
│   ├── game/       # ระบบเกมจังหวะดนตรี, Beatmap Generator, Audio Manager
│   ├── report/      # ระบบวิเคราะห์รายงานสุขภาพ
│   └── streak/      # ระบบติดตามความต่อเนื่อง (Streak)
├── services/       # Business Logic และ State Providers (WebSocket, Persistence, etc.)
└── shared/         # Models (GripData, TrainingSession) และ Components ที่ใช้ร่วมกัน
```

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
