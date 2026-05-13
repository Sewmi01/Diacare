# 🔧 Supabase Complete Setup Guide for Medicine Reminders

## 📋 Table of Contents
1. Database Schema Setup
2. Row Level Security (RLS) Policies
3. Dart/Flutter Configuration
4. Usage Examples

---

## 1️⃣ Step 1: Database Schema Setup

Run these SQL commands in your Supabase SQL Editor:

### A. Create Primary Table
```sql
-- Drop if exists (for debugging only)
DROP TABLE IF EXISTS medicine_reminders CASCADE;

-- Create medicine_reminders table
CREATE TABLE medicine_reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  time_of_day TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create indexes for faster queries
CREATE INDEX idx_medicine_reminders_user_id ON medicine_reminders(user_id);
CREATE INDEX idx_medicine_reminders_created_at ON medicine_reminders(created_at DESC);

-- Enable RLS
ALTER TABLE medicine_reminders ENABLE ROW LEVEL SECURITY;
```

### B. Create Storage Bucket (Optional - for reminder backup)
```sql
-- Create storage bucket for reminder backups
INSERT INTO storage.buckets (id, name, public)
VALUES ('reminders', 'reminders', false)
ON CONFLICT (id) DO NOTHING;
```

---

## 2️⃣ Step 2: Row Level Security (RLS) Policies

Run these policies in your Supabase SQL Editor:

```sql
-- Policy 1: Users can SELECT their own reminders
CREATE POLICY "Users can VIEW their own reminders"
ON medicine_reminders FOR SELECT
USING (auth.uid() = user_id);

-- Policy 2: Users can INSERT their own reminders
CREATE POLICY "Users can INSERT their own reminders"
ON medicine_reminders FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy 3: Users can UPDATE their own reminders
CREATE POLICY "Users can UPDATE their own reminders"
ON medicine_reminders FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy 4: Users can DELETE their own reminders
CREATE POLICY "Users can DELETE their own reminders"
ON medicine_reminders FOR DELETE
USING (auth.uid() = user_id);

-- Verify policies are enabled
SELECT * FROM pg_policies WHERE tablename = 'medicine_reminders';
```

---

## 3️⃣ Step 3: Update Your Supabase Config

### File: `lib/config/supabase_config.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient getClient() {
    return Supabase.instance.client;
  }

  static User? getCurrentUser() {
    return Supabase.instance.client.auth.currentUser;
  }
}
```

---

## 4️⃣ Step 4: Update Your Main.dart

### File: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'config/supabase_config.dart';
import 'reminder/water.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize notifications
  await _initializeNotifications();

  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Supabase initialization error: $e');
  }

  runApp(const MyApp());
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iOSInit =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iOSInit,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      print('Notification tapped: ${response.payload}');
    },
  );

  // Request permissions (Android 13+)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DiaCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B0F3B),
        ),
      ),
      home: const AlarmPage(),
    );
  }
}
```

---

## 5️⃣ Complete Reminder Service Class

### File: `lib/services/reminder_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class ReminderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ Get all reminders for current user
  Future<List<Map<String, dynamic>>> getAllReminders() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final reminders = await _supabase
          .from('medicine_reminders')
          .select()
          .eq('user_id', user.id)
          .order('time_of_day', ascending: true);

      debugPrint('✅ Fetched ${reminders.length} reminders');
      return List<Map<String, dynamic>>.from(reminders);
    } catch (e) {
      debugPrint('❌ Error fetching reminders: $e');
      rethrow;
    }
  }

  // ✅ Add a new reminder
  Future<Map<String, dynamic>> addReminder(String timeOfDay) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('medicine_reminders')
          .insert({
            'user_id': user.id,
            'time_of_day': timeOfDay,
            'is_active': true,
          })
          .select()
          .single();

      debugPrint('✅ Reminder added: $timeOfDay');
      return response;
    } catch (e) {
      debugPrint('❌ Error adding reminder: $e');
      rethrow;
    }
  }

  // ✅ Update reminder status
  Future<void> updateReminderStatus(String reminderId, bool isActive) async {
    try {
      await _supabase
          .from('medicine_reminders')
          .update({'is_active': isActive})
          .eq('id', reminderId);

      debugPrint('✅ Reminder updated: $reminderId -> $isActive');
    } catch (e) {
      debugPrint('❌ Error updating reminder: $e');
      rethrow;
    }
  }

  // ✅ Delete reminder
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _supabase
          .from('medicine_reminders')
          .delete()
          .eq('id', reminderId);

      debugPrint('✅ Reminder deleted: $reminderId');
    } catch (e) {
      debugPrint('❌ Error deleting reminder: $e');
      rethrow;
    }
  }

  // ✅ Delete all reminders for user
  Future<void> deleteAllReminders() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase
          .from('medicine_reminders')
          .delete()
          .eq('user_id', user.id);

      debugPrint('✅ All reminders deleted');
    } catch (e) {
      debugPrint('❌ Error deleting all reminders: $e');
      rethrow;
    }
  }

  // ✅ Stream reminders (real-time updates)
  Stream<List<Map<String, dynamic>>> streamReminders() {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      return _supabase
          .from('medicine_reminders')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .order('time_of_day')
          .map((data) => List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('❌ Error streaming reminders: $e');
      return Stream.error(e);
    }
  }
}
```

---

## 6️⃣ Advanced Example: Using ReminderService with StreamBuilder

### File: `lib/screens/advanced_reminder_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:diecare_app/services/reminder_service.dart';

class AdvancedReminderScreen extends StatefulWidget {
  const AdvancedReminderScreen({super.key});

  @override
  State<AdvancedReminderScreen> createState() =>
      _AdvancedReminderScreenState();
}

class _AdvancedReminderScreenState extends State<AdvancedReminderScreen> {
  final ReminderService _reminderService = ReminderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💊 Medicine Reminders'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _reminderService.streamReminders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reminders = snapshot.data ?? [];

          if (reminders.isEmpty) {
            return const Center(child: Text('No reminders set'));
          }

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return ListTile(
                title: Text(reminder['time_of_day']),
                subtitle: Text(
                  reminder['is_active'] ? 'Active' : 'Inactive',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _reminderService.deleteReminder(reminder['id']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## 7️⃣ Update `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.2.0
  flutter_local_notifications: ^14.1.0
  timezone: ^0.9.2
```

Then run:
```bash
flutter pub get
```

---

## 8️⃣ Troubleshooting Guide

### Problem: User not authenticated
**Solution:** Make sure user is logged in before accessing reminders
```dart
final user = Supabase.instance.client.auth.currentUser;
if (user == null) {
  print('❌ No user logged in');
  // Redirect to login
}
```

### Problem: RLS policy violations
**Solution:** Check Supabase logs and verify RLS policies are set correctly
```sql
-- View all policies
SELECT * FROM pg_policies WHERE tablename = 'medicine_reminders';
```

### Problem: Notifications not working
**Solution:** Check permissions in `AndroidManifest.xml` and `Info.plist`

**Android (`android/app/src/main/AndroidManifest.xml`):**
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

**iOS (`ios/Runner/Info.plist`):**
```xml
<key>UILocalNotificationPermission</key>
<true/>
```

---

## 9️⃣ Testing Your Setup

```dart
// Test 1: Check user authentication
void testAuth() async {
  final user = Supabase.instance.client.auth.currentUser;
  print('User: ${user?.email}');
}

// Test 2: Add a reminder
void testAddReminder() async {
  final response = await Supabase.instance.client
      .from('medicine_reminders')
      .insert({
        'user_id': Supabase.instance.client.auth.currentUser!.id,
        'time_of_day': '09:00 AM',
        'is_active': true,
      })
      .select()
      .single();
  print('✅ Added: $response');
}

// Test 3: Query reminders
void testQueryReminders() async {
  final reminders = await Supabase.instance.client
      .from('medicine_reminders')
      .select()
      .eq('user_id', Supabase.instance.client.auth.currentUser!.id);
  print('📋 Reminders: $reminders');
}
```

---

## 🔟 API Summary

| Operation | Method | Parameters | Returns |
|-----------|--------|-----------|---------|
| Get All | `getAllReminders()` | None | `List<Map>` |
| Add | `addReminder(timeOfDay)` | `String` | `Map` |
| Update | `updateReminderStatus(id, isActive)` | `String, bool` | `void` |
| Delete | `deleteReminder(id)` | `String` | `void` |
| Delete All | `deleteAllReminders()` | None | `void` |
| Stream | `streamReminders()` | None | `Stream<List>` |

---

## ✅ Verification Checklist

- [ ] SQL schema created in Supabase
- [ ] RLS policies enabled and configured
- [ ] `supabase_config.dart` updated with credentials
- [ ] `main.dart` initializes Supabase
- [ ] `reminder_service.dart` created
- [ ] Notifications permissions added to manifests
- [ ] User is authenticated before accessing reminders
- [ ] Test add/edit/delete operations

---

**Your reminders will now be properly saved to Supabase! 🎉**
