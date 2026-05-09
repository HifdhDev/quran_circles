# PROJECT_MAP: نظام إدارة حلقات تحفيظ القرآن (Quran Circles)

---

## [TECH_STACK]

### الإصدار الأصلي (Flutter)
| الطبقة | التقنية | الإصدار | المبرر |
|--------|---------|---------|--------|
| Framework | Flutter | 3.x (أحدث stable) | iOS + Android + Web من كود واحد، دعم RTL/Arabic أصلي |
| اللغة | Dart | 3.x | أداء عالٍ، compiled native، typesafe |
| State Mgmt | flutter_bloc | ^9.1.1 | Flutter Favorite، فصل كامل للـ UI عن البيزنس لوجيك |
| DB محلي | sembast | ^3.8.7 | NoSQL embedded، pure Dart (بدون native plugins)، تشفير، cross-platform |
| التشفير | encrypt (AES-256) | latest | تشفير قاعدة البيانات والـ sync payload |
| Networking | dart:io (RawSocket) + multicast_dns | SDK | P2P بدون سيرفر، اكتشاف الأجهزة محلياً |
| Bluetooth | flutter_blue_plus | latest | Sync عبر Bluetooth للقرب المباشر |
| QR Code | mobile_scanner + qr_flutter | latest | تبادل البيانات عبر QR (للحالات الطارئة/offline) |
| Locale | flutter_localizations + intl | SDK | دعم العربية بالكامل (التقويم الهجري، RTL) |
| Testing | flutter_test + bloc_test | SDK | اختبارات unit/bloc/widget |
| Logging | rudimentary async logger | custom | < 200 سطر، غير حظر |

### الإصدار الويب (HTML/JS/CSS - بدون سيرفر)
| الطبقة | التقنية | المبرر |
|--------|---------|--------|
| الهيكل | HTML5 + CSS3 | يعمل على file:// بدون حاجة لسيرفر |
| اللغة | Vanilla JS (ES6) | لا dependencies خارجية |
| DB محلي | localStorage | تخزين البيانات في المتصفح |
| الخط | Cairo (Google Fonts) | دعم RTL/Arabic |
| التوجيه | Hash-based SPA | بدون سيرفر (file://) |
| المسار | `quran_circles_web/` | مجلد مستقل بجانب المشروع الأصلي |

### الـ Dependencies المحظورة (Deprecated / Avoid):
- `sqflite` (Dart 1 only) ← استخدم sembast
- `wifi_direct` 0.0.1 (لم يتم تحديثه منذ 5 سنوات)
- Hive 4.0.0-dev.2 (prerelease غير مستقر)

---

## [ARCHITECTURE]

### Clean Architecture + DDD (3 Layers)

```
┌────────────────────────────────────────────────┐
│  Presentation Layer (UI)                        │
│  - Flutter Widgets / Screens                    │
│  - BlocConsumer / BlocBuilder                   │
│  - Arabic RTL (Directionality, TextDirection)   │
├────────────────────────────────────────────────┤
│  Domain Layer (Business Logic)                  │
│  - Entities (Freezed)                           │
│  - UseCases                                    │
│  - Repository Interfaces (abstract)             │
├────────────────────────────────────────────────┤
│  Data Layer (Implementation)                   │
│  - Local Data Source (sembast)                 │
│  - Sync Engine (P2P Multi-Transport)           │
│  - Repository Implementations                  │
└────────────────────────────────────────────────┘
```

### Directory Structure (Feature-Based) - ✅ تم التنفيذ

```
lib/
├── core/
│   ├── database/
│   │   ├── database_service.dart       # واجهة DB + تنفيذ sembast
│   │   └── store_refs.dart             # تعريفات الـ Stores
│   ├── sync/
│   │   ├── sync_engine.dart            # المحرك الرئيسي للمزامنة
│   │   ├── sync_transport.dart         # Interface للنقل
│   │   ├── transports/
│   │   │   ├── wifi_transport.dart     # TCP/IP عبر WiFi
│   │   │   ├── bluetooth_transport.dart # BLE
│   │   │   ├── qr_transport.dart       # QR code import/export
│   │   │   └── file_transport.dart     # ملفات JSON للنسخ الاحتياطي
│   │   ├── conflict_resolver.dart      # LWW + priority
│   │   └── sync_record.dart            # نموذج بيانات المزامنة
│   ├── discovery/
│   │   ├── device_discovery.dart       # Interface
│   │   ├── mdns_discovery.dart         # WiFi mDNS
│   │   └── ble_discovery.dart          # Bluetooth scanning
│   ├── logging/
│   │   └── quran_logger.dart           # Async logger (غير حظر)
│   ├── network/
│   │   └── network_utils.dart          # IP, connectivity check
│   └── utils/
│       ├── extensions.dart
│       ├── date_utils.dart             # التقويم الهجري + الميلادي
│       └── constants.dart
├── features/
│   ├── auth/
│   │   ├── data/ ...                   # نماذج، مصادر بيانات
│   │   ├── domain/ ...                 # Entities, repos (abstract)
│   │   └── presentation/ ...           # شاشات login، إدارة الأدوار
│   ├── students/                       # الطلاب
│   │   ├── data/
│   │   │   ├── models/student_model.dart
│   │   │   └── repositories/student_repository.dart
│   │   ├── domain/
│   │   │   ├── entities/student.dart
│   │   │   └── repositories/i_student_repository.dart
│   │   └── presentation/
│   │       ├── bloc/student_bloc.dart
│   │       └── screens/student_list_screen.dart
│   ├── circles/                        # الحلقات
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/ ...
│   ├── memorization/                   # الحفظ والمراجعة
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/ ...
│   ├── reports/                        # التقارير
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/ ...
│   └── messaging/                      # التراسل المنسق
│       ├── data/ ...
│       ├── domain/ ...
│       └── presentation/ ...
└── l10n/
    ├── app_ar.arb                      # ملف الترجمة العربية
    └── app_en.arb                      # English fallback
```

### Data Flow: المزامنة اللامركزية

```
                   ┌─────────────┐
                   │   Device A  │  (Teacher 1)
                   │  ┌────────┐ │
                   │  │sembast │ │
                   │  │ (Local)│ │
                   │  └───┬────┘ │
                   │      │      │
                   │  ┌───▼────┐ │
                   │  │  Sync  │ │
                   │  │ Engine │ │
                   │  └───┬────┘ │
                   └──────┼──────┘
                          │
        ┌─────────────────┼─────────────────┐
        │ WiFi (TCP)      │ Bluetooth (BLE) │ QR / File  │
        ▼                 ▼                 ▼          ▼
   ┌──────────┐    ┌──────────┐     ┌──────────┐
   │ Device B │    │ Device C │     │ Device D │
   │ (Teacher)│    │(Supervisor)    │ (Teacher)│
   └──────────┘    └──────────┘     └──────────┘
```

### نموذج بيانات Sync (CRDT-like)

```dart
class SyncRecord {
  String id;            // UUID v4
  String collection;    // 'students', 'circles', 'progress'...
  String recordId;      // ID السجل الأصلي
  String data;          // JSON payload
  String deviceId;      // مصدر التعديل
  int timestamp;        // Unix ms
  bool isDeleted;
  String signature;     // توقيع للتأكد من سلامة البيانات
}
```

**استراتيجية حل التعارضات:** Last-Writer-Wins (LWW) based on `timestamp` مع `deviceId` كـ tiebreaker

---

## [SYSTEM_FLOW]

### رحلة المستخدم: اليوم النموذجي

```
1. يفتح المعلم التطبيق → شاشة الحلقات (Circles)
2. يختار الحلقة → يعرض قائمة الطلاب
3. يسجل حضور الطلاب (حاضر/غائب/متأخر)
4. يسجل تقدم الحفظ (الجزء، الصفحة، الآيات)
5. يدون ملاحظات تقييمية لكل طالب
6. عند توفر اتصال (WiFi/BLE):
     → يكتشف أجهزة المشرفين والمعلمين الآخرين
     → يتزامن: الحضور ← التقارير ← التقييمات
7. المشرف يفتح التطبيق → يستقبل التحديثات التلقائية
8. المشرف يرسل رسالة/إشعار للمعلم (منسق)
9. المعلم يستقبل الرسالة عند أول اتصال
10. المشرف يعرض تقارير شاملة (لمسة زر)
```

### الشاشات الرئيسية (GUI Flow)

```
Splash ──> Login (دخول)
              │
              ▼
        Dashboard (لوحة التحكم)
         ├── Circles (الحلقات)
         │    ├── CircleDetail (تفاصيل الحلقة)
         │    │    ├── Attendance (الحضور)
         │    │    ├── Memorization (الحفظ)
         │    │    │    └── SurahPicker (اختيار السورة/الآيات)
         │    │    ├── Evaluation (التقييم)
         │    │    └── StudentProfile (ملف الطالب)
         │    └── AddStudent (إضافة طالب)
         ├── Reports (التقارير)
         │    ├── AttendanceReport (تقرير الحضور)
         │    ├── ProgressReport (تقرير التقدم)
         │    └── CircleSummary (ملخص الحلقة)
         ├── Messages (التراسل)
         │    ├── Inbox (الوارد)
         │    └── NewMessage (رسالة جديدة)
         └── Settings (الإعدادات)
              ├── Profile (الملف الشخصي)
              ├── SyncStatus (حالة المزامنة)
              ├── QR Export (تصدير QR)
              └── Backup (نسخ احتياطي)
```

### الملاحظات المهمة للـ UI (عربية 100%):
- `Directionality` مع `TextDirection.rtl`
- `locale: const Locale('ar')` مع دعم `ar_SA`
- أيقونات مناسبة للسياق الإسلامي
- تواريخ هجرية + ميلادية
- أرقام عربية (٠١٢٣) أو هندية حسب الطلب

---

## [SYNC STRATEGY - Multi-Transport]

### اكتشاف الأجهزة:
| الوسيلة | النطاق | الاكتشاف | notes |
|---------|--------|----------|-------|
| mDNS (WiFi) | شبكة محلية | تلقائي | zero-config |
| BLE | ~10 متر | Scanning | بطيء ولكن منخفض الطاقة |
| QR Code | بصري | يدوي | للطوارئ أو أول اتصال |
| Manual IP | أي | يدوي | أدخال IP يدوي |

### تدفق المزامنة:
```
1. Discovery → 2. Pairing (مصافحة) → 3. Exchange versions (تبادل إصدارات البيانات)
→ 4. Pull missing records (سحب المفقود) → 5. Push local changes (دفع المحلي)
→ 6. Conflict resolution → 7. Ack
```

### متطلبات الـ Sync:
- ❌ لا يحتاج اتصال إنترنت
- ✅ يعمل على شبكة محلية بدون سيرفر
- ✅ يعمل عبر Bluetooth عند القرب
- ✅ يدعم QR لتبادل البيانات الأساسية (للطوارئ)
- ✅ يدعم تصدير/استيراد ملفات (للنسخ الاحتياطي)
- ✅ آمن (AES-256 للبيانات الحساسة)

---

## [SAFE LOGGING]

```dart
// quran_logger.dart - < 200 سطر
enum LogLevel { debug, info, warning, error }

class QuranLogger {
  static final _queue = StreamController<LogRecord>.broadcast();

  static void log(LogLevel level, String message, [dynamic error]) {
    unawaited(_queue.add(LogRecord(level, message, error, DateTime.now())));
  }

  // Non-blocking: يكتب في الخلفية
  static void init() {
    _queue.stream
      .asyncMap((r) => _writeToFile(r))
      .listen(null, onError: (_) {}); // ignore write errors
  }
}
```

- المستويات: `debug`, `info`, `warning`, `error` فقط
- يكتب إلى ملف دوري (حجم أقصى 5MB ثم rotate)
- غير حظري تماماً (isolate/async)
- لا يؤثر على أداء المزامنة أو UI

---

## [ORPHANS & PENDING]

| البند | الحالة | ملاحظات |
|-------|--------|---------|
| تكامل التسجيل الصوتي | ❌ مؤجل | خارج النطاق الحالي |
| WebRTC للـ P2P عبر الإنترنت | ⏳ اختياري | قد يضاف لاحقاً كـ transport خامس |
| Push notifications | ⏳ مستقبلاً | حالياً التحديثات تتم عند الاتصال المباشر |
| تقويم هجري دقيق | ⏳ يحتاج مكتبة | ummalqura_calendar أو custom |
| Quran text database | ⏳ يحتاج إعداد | نص القرآن كاملاً مع التشكيل |
| Role-based permissions | ⏳ مستقبلاً | إضافة الأنواع: معلم، مشرف، مدير |
| End-to-end encryption | ⏳ مهم | للبيانات الحساسة في sync |
| Sync Engine للنسخة الويب | ❌ غير مدعوم | الإصدار الويب لا يدعم المزامنة P2P (localStorage محدود) |
| QR Export حقيقي | ⏳ API | يستخدم QR API خارجي (البيانات الكبيرة غير مدعومة) |
| تقويم هجري دقيق | ⏳ إصدار ويب | يحتاج مكتبة ummalqura للويب |

---

## [IMPLEMENTATION STATUS]

### ✅ Completed: Milestone 1 - التأسيس
- [x] إنشاء هيكل المشروع (pubspec.yaml, analysis_options.yaml)
- [x] تهيئة `sembast` (DatabaseService, StoreRefs)
- [x] تهيئة `flutter_bloc` وإعداد هيكل المشروع
- [x] إعداد Routing (app_router.dart مع named routes)
- [x] إعداد Localization (دعم العربية كاملة)
- [x] ملفات: `main.dart`، `app_router.dart`، 30 ملف مصدر

### ✅ Completed: Milestone 2 - نوى البيانات الأساسية
- [x] Domain: User, Student, Circle, Attendance, MemorizationRecord, Message
- [x] Repository interfaces (abstract) for all features
- [x] Repository implementations مع sembast (CRUD كامل)
- [x] Search, filter, progress aggregation

### ✅ Completed: Milestone 3 - Sync Engine
- [x] SyncEngine class مع push/pull/announce
- [x] SyncTransport abstract interface
- [x] WiFi Transport (mDNS discovery + TCP ServerSocket)
- [x] Bluetooth Transport (interface + platform detection)
- [x] QR Transport (JSON export/import)
- [x] File Transport (backup/restore)
- [x] ConflictResolver (LWW + deviceId tiebreaker)
- [x] SyncRecord model

### ✅ Completed: Milestone 4 - Transports
- [x] WiFi mDNS + broadcast discovery
- [x] BLE discovery interface
- [x] QR code data exchange
- [x] File backup/restore

### ✅ Completed: Milestone 5 - التقارير والتراسل
- [x] BLoC لكل feature (StudentBloc, CircleBloc, MemorizationBloc, MessageBloc)
- [x] UI Screens: Login, Dashboard, StudentList, CircleList, CircleDetail
- [x] UI Screens: MessageList, Reports, Settings
- [x] نظام التراسل (inbox, send, markRead)
- [x] تقارير الحضور والتقدم عبر الـ repository

### ✅ Completed: Milestone 6 - الاختبارات
- [x] StudentRepository unit tests (add/retrieve/getAll/search/delete/update)
- [x] CircleRepository unit tests (add/retrieve/filter/attendance)
- [x] MemorizationRepository unit tests (add/progress/circle filter)
- [x] Sync engine unit tests (SyncRecord roundtrip, ConflictResolver)
- [x] StudentBloc unit test via bloc_test

### ✅ Completed: Milestone 7 - الإصدار الويب (HTML/JS/CSS)
- [x] إنشاء مجلد `quran_circles_web/` (مستقل بجانب المشروع الأصلي)
- [x] طبقة Core: `utils.js` (ثوابت، سور، مساعدات، localStorage wrapper)
- [x] طبقة البيانات: `repositories.js` (5 Repositories: Auth, Student, Circle, Memorization, Message)
- [x] واجهات المستخدم: `screens.js` (775 سطر - شاشات متكاملة)
- [x] التوجيه: `app.js` (Hash-based SPA، routing)
- [x] التصميم: `style.css` (RTL، ألوان إسلامية، Cairo Font، متجاوب)
- [x] لا يحتاج سيرفر (يعمل على file:// و localhost)
- [x] تخزين محلي (localStorage يحاكي sembast)
- [x] 114 سورة كاملة مع أسماء وأعداد الآيات والأجزاء
- [x] المصادقة: تسجيل دخول + أدوار (معلم، مشرف، مدير)
- [x] لوحة التحكم: 6 كروت + زر مزامنة + إحصائيات سريعة
- [x] الطلاب: إضافة/تعديل/حذف/بحث + ربط الطالب بالحلقة
- [x] الحلقات: إضافة/تعديل/حذف + 4 تبويبات (معلومات، حضور، حفظ، طلاب)
- [x] الحضور: 4 حالات (حاضر ✅/غائب ❌/متأخر ⏰/معذور 🔵) + سجل حضوري + حفظ يومي
- [x] الحفظ: سجل جلسات لكل طالب + إضافة حفظ (سورة، آيات، نوع، تقييم) + إحصائيات
- [x] الرسائل: وارد/مرسل + إرسال (عنوان، نص، مستلم، أولوية) + عرض + حذف
- [x] التقارير: تقرير حضور + تقرير تقدم + ملخص حلقات + إحصائيات سريعة
- [x] الإعدادات: الملف الشخصي + حالة المزامنة + QR Code + تصدير/استيراد JSON + مسح بيانات

### التالي (Next Steps - يتطلب Flutter SDK):
- [ ] `flutter pub get` لتثبيت الـ dependencies
- [ ] تشغيل `flutter test` للتحقق من جميع الاختبارات
- [ ] تشغيل `flutter run` على iOS/Android/Web
- [ ] تثبيت Flutter على هذا الجهاز للتشغيل المحلي
- [ ] إضافة نص القرآن الكريم كقاعدة بيانات
