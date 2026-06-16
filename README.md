# Grip Strength Monitor - แอปฝึกบีบมือ

## แอปนี้ทำอะไร?

เป็นแอปมือถือสำหรับฝึกบีบมือ เหมาะสำหรับผู้สูงอายุหรือผู้ที่ต้องฟื้นฟูกล้ามเนื้อมือ แอปจะช่วย:
- วัดแรงบีบมือ
- ฝึกบีบมือตามจังหวะ (คล้ายเกม Piano Tiles)
- ดูสถิติการฝึกย้อนหลัง
- ติดตามความต่อเนื่องในการฝึก
- มอบรางวัลเมื่อทำภารกิจสำเร็จ

## โครงสร้างโปรเจค

```
grip_strength_monitor/
├── lib/
│   ├── main.dart                          # จุดเริ่มต้นของแอป
│   ├── main_navigation.dart               # แถบนำทางด้านล่าง 4 แท็บ
│   ├── core/
│   │   ├── theme/app_theme.dart           # ธีมสีชมพูพาสเทล + ฟอนต์ไทย Sarabun
│   │   └── constants/app_localizations.dart # ข้อความภาษาไทยทั้งหมด
│   ├── features/
│   │   ├── dashboard/                     # หน้าหลัก - สรุปข้อมูล
│   │   ├── statistics/                    # ดูสถิติ
│   │   ├── goals/                         # เป้าหมาย + เต่าเลี้ยง
│   │   ├── profile/                       # โปรไฟล์ + ตั้งค่า
│   │   ├── measurement/                   # วัดแรงบีบมือ
│   │   ├── smart_rhythm/                  # ฝึกจังหวะ (มีเมทอนอม)
│   │   ├── training/                      # โปรแกรมฝึกแนะนำ (มีเมทอนอม)
│   │   ├── game/                          # เกมจังหวะบีบมือ
│   │   ├── streak/                        # ปฏิทินความต่อเนื่อง
│   │   ├── history/                       # ประวัติการฝึก
│   │   ├── report/                        # รายงานสุขภาพ
│   │   └── achievements/                  # รางวัล
│   ├── services/
│   │   ├── grip_provider.dart             # จัดการข้อมูลแรงบีบ
│   │   ├── todo_provider.dart             # จัดการภารกิจประจำวัน
│   │   ├── statistics_provider.dart       # จัดการสถิติ
│   │   ├── theme_provider.dart            # จัดการธีม (สว่าง/มืด)
│   │   ├── measurement_provider.dart      # จัดการการวัด
│   │   ├── sound_service.dart             # เสียง + haptic feedback
│   │   ├── ble_service.dart               # เชื่อมต่อ ESP32 ผ่าน Bluetooth
│   │   └── mock_data_service.dart         # ข้อมูลจำลอง
│   └── shared/models/
│       ├── grip_data.dart                 # โมเดลข้อมูลแรงบีบ
│       ├── todo.dart                      # โมเดลภารกิจ
│       ├── training_session.dart          # โมเดลเซสชันฝึก
│       └── achievement.dart               # โมเดลรางวัล
```

## ฟีเจอร์ที่ทำเสร็จแล้ว

### หน้าหลัก (Dashboard)
- แสดงสรุปข้อมูลแรงบีบมือ
- แสดงคะแนนสมอง
- ปุ่มเริ่มวัดแรงบีบ
- ปุ่มลัดเข้าฟีเจอร์ต่างๆ

### วัดแรงบีบมือ (Measurement)
- กดปุ่มเริ่ม/หยุดวัด
- แสดงตัวเลขแรงบีบแบบ real-time
- แสดงกราฟแรงบีบ
- แสดงผลลัพธ์หลังวัดเสร็จ (สูงสุด, ค่าเฉลี่ย, สถานะ)

### ฝึกจังหวะ (Smart Rhythm)
- มีเมทอนอมจริง (สั่นตามจังหวะ)
- เลือกความเร็ว BPM ได้ (40, 60, 80, 100, 120)
- แสดงจังหวะ 1-2-3-4 แบบกระตุกตามเสียง
- นับจำนวนรอบที่ฝึก

### โปรแกรมฝึกแนะนำ (Guided Training)
- มี 3 ระดับ: เริ่มต้น, ปานกลาง, ขั้นสูง
- มี 3 ขั้นตอน: วอร์มอัพ → ฝึกหลัก → คูลดาวน์
- มีเมทอนอมจริงตลอดการฝึก
- แสดงเวลาถอยหลังแต่ละขั้นตอน
- แสดงจำนวนครั้งที่ฝึก

### เกมจังหวะบีบมือ (Grip Rhythm Game)
- โน้ตวิ่งจากบนลงล่าง
- กดหน้าจอเมื่อโน้ตวิ่งถึงเส้นสี
- มี 2 แบบ: โน้ตสั้น (วงกลม) และ โน้ตยาว (สี่เหลี่ยม)
- 3 ระดับความยาก
- ระบบคะแนน: PERFECT/GOOD/OK/MISS
- 3 ชีวิต หมดแล้วเกมจบ

### สถิติ (Statistics)
- เลือกดู 7, 30, หรือ 90 วัน
- แสดงกราฟแนวโน้ม
- แสดงค่าเฉลี่ย, สูงสุด, แนวโน้ม

### เป้าหมาย (Goals)
- เต่าเลี้ยงน่ารัก
- ระบบ Level/XP
- ภารกิจประจำวัน 3 ข้อ

### โปรไฟล์ (Profile)
- ข้อมูลผู้ใช้
- ตั้งค่าการแจ้งเตือน
- ข้อมูลผู้ดูแล
- ตั้งค่าแอป

### รางวัล (Achievements)
- 6 รางวัลให้ปลดล็อค
- แสดง progress แต่ละรางวัล

### ปฏิทินความต่อเนื่อง (Streak)
- แสดงวันที่ฝึกแล้วในปฏิทิน
- แสดงจำนวนวันต่อเนื่อง

### ประวัติการฝึก (History)
- แสดงรายการฝึกย้อนหลัง
- ตัวกรองตามประเภท

### รายงานสุขภาพ (Health Report)
- รายงานรายสัปดาห์/เดือน
- เปรียบเทียบกับสัปดาห์ก่อน

### ธีม
- สีชมพูพาสเทล (ธีมสว่าง)
- รองรับธีมมืด
- ฟอนต์ไทย Sarabun (อ่านง่าย)

## ฟีเจอร์ที่ยังไม่เสร็จ / ต้องทำต่อ

### 1. การเชื่อมต่อ Hardware (สำคัญมาก!)
- ตอนนี้ใช้ข้อมูลจำลอง (mock data) ทั้งหมด
- ต้องเชื่อมต่อ ESP32 + HX711 sensor จริง
- ไฟล์ที่ต้องแก้: `ble_service.dart`, `measurement_provider.dart`

### 2. บันทึกข้อมูลจริง
- ตอนนี้ข้อมูลไม่ได้บันทึกถาวร
- ต้องเพิ่ม database (เช่น SQLite หรือ Hive)
- ไฟล์ที่ต้องแก้: ทุก provider

### 3. การแจ้งเตือน
- ยังไม่มีการแจ้งเตือนจริง
- ต้องเพิ่ม local notification

### 4. แชร์รายงาน
- ปุ่มแชร์ยังไม่ทำงาน
- ต้องสร้าง PDF report

### 5. แก้บัค ListTile
- มี warning "ListTile background color may be invisible"
- เกิดจาก ListTile อยู่ใน Container ที่มีสีพื้นหลัง
- ต้องแก้ในหน้าที่มี ListTile

## วิธีติดตั้งและรัน

### สิ่งที่ต้องมี
1. Flutter SDK (version 3.12.2 ขึ้นไป)
2. Android Studio หรือ VS Code
3. Android Emulator หรือมือถือ Android

### วิธีติดตั้ง
```bash
# 1. เข้าไปในโฟลเดอร์โปรเจค
cd grip_strength_monitor

# 2. ติดตั้ง packages ที่ต้องใช้
flutter pub get

# 3. รันแอป
flutter run
```

### วิธีรันบน Emulator
1. เปิด Android Studio
2. สร้าง Virtual Device (ถ้ายังไม่มี)
3. เปิด Emulator
4. รันคำสั่ง `flutter run`

### วิธีรันบนมือถือจริง
1. เปิด USB Debugging บนมือถือ
2. เสียบสาย USB เชื่อมกับคอม
3. รันคำสั่ง `flutter run`

## วิธีทำต่อ (สำหรับคนมาทำต่อ)

### ถ้าอยากแก้บัค
1. ดู error message ใน terminal
2. หาไฟล์ที่มีปัญหาตาม path ที่บอก
3. แก้โค้ด
4. รัน `flutter analyze` ดูว่ายังมี error ไหม
5. รัน `flutter run` ทดสอบ

### ถ้าอยากเพิ่มฟีเจอร์ใหม่
1. สร้างโฟลเดอร์ใหม่ใน `lib/features/`
2. สร้างไฟล์ screen ใหม่
3. เพิ่ม navigation ใน `main_navigation.dart` หรือ `dashboard_screen.dart`
4. เพิ่มข้อความภาษาไทยใน `app_localizations.dart`

### ถ้าอยากเชื่อมต่อ ESP32
1. ดูไฟล์ `ble_service.dart` เป็นตัวอย่าง
2. สร้าง serial port สำหรับอ่านข้อมูลจาก HX711
3. ส่งข้อมูลแรงบีบมือเข้ามาใน app
4. แก้ `measurement_provider.dart` ให้รับข้อมูลจริง

### คำสั่งที่ใช้บ่อย
```bash
flutter pub get          # ติดตั้ง packages
flutter analyze          # ตรวจ error
flutter run              # รันแอป
flutter run -d emulator  # รันบน emulator
```

## ปัญหาที่พบบ่อย

### "Unused import" warning
- เกิดจาก import ไฟล์ที่ไม่ได้ใช้
- แก้: ลบ import นั้นออก

### "ListTile background" warning
- เกิดจาก ListTile อยู่ใน Container ที่มีสีพื้นหลัง
- แก้: ครอบ ListTile ด้วย Material widget

### แอปรันช้า
- ปกติตอน startup จะช้าเล็กน้อย (Skipped frames)
- ถ้าช้ามาก ลอง Hot Restart ด้วยการกด R

## โครงสร้างโค้ดสำคัญ

### Provider Pattern (จัดการข้อมูล)
ทุกหน้าจอใช้ Provider ในการจัดการข้อมูล:
```dart
Consumer<GripProvider>(
  builder: (context, provider, child) {
    return Text('${provider.currentGrip}');
  },
)
```

### Navigation (ไปหน้าจอต่างๆ)
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => TargetScreen()),
);
```

### Sound Service (เสียง)
```dart
_sound.playClick();    // เสียงคลิก
_sound.playBeat();     // เสียงจังหวะ
_sound.playSuccess();  // เสียงสำเร็จ
_sound.playError();    // เสียงผิดพลาด
```

## ติดต่อ

ถ้ามีคำถามหรือปัญหา ถาม AI ได้เลย!
"# grip_strength_monitor" 
