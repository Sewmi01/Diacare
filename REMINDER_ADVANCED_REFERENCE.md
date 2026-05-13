# 🔬 Advanced Reference Guide - Medicine Reminders

## Complete Implementation Examples

### Example 1: Advanced Reminder Screen with StreamBuilder
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
  final ReminderService _service = ReminderService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-time Reminders')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.streamReminders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final reminders = snapshot.data ?? [];

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Card(
                child: ListTile(
                  title: Text(reminder['time_of_day']),
                  subtitle: Text(
                    reminder['is_active'] ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: reminder['is_active']
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () => _editReminder(reminder['id']),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () =>
                            _service.deleteReminder(reminder['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _editReminder(String id) {
    // TODO: Implement edit functionality
  }
}
```

### Example 2: Reminder Statistics Dashboard
```dart
class ReminderStatsDashboard extends StatefulWidget {
  const ReminderStatsDashboard({super.key});

  @override
  State<ReminderStatsDashboard> createState() =>
      _ReminderStatsDashboardState();
}

class _ReminderStatsDashboardState extends State<ReminderStatsDashboard> {
  final ReminderService _service = ReminderService();
  int totalReminders = 0;
  int activeReminders = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final total = await _service.getAllReminders();
      final active = await _service.getActiveRemindersCount();

      setState(() {
        totalReminders = total.length;
        activeReminders = active;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminder Statistics')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatCard(
              title: 'Total Reminders',
              count: totalReminders,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildStatCard(
              title: 'Active Reminders',
              count: activeReminders,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            _buildStatCard(
              title: 'Inactive Reminders',
              count: totalReminders - activeReminders,
              color: Colors.orange,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Refresh Stats'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
```

### Example 3: Bulk Operations
```dart
class BulkReminderManager {
  final ReminderService _service = ReminderService();

  /// Disable all reminders at once
  Future<void> disableAllReminders() async {
    try {
      final reminders = await _service.getAllReminders();
      final ids = reminders.map((r) => r['id'] as String).toList();
      
      await _service.bulkUpdateStatus(ids, false);
      debugPrint('✅ All reminders disabled');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  /// Enable all reminders at once
  Future<void> enableAllReminders() async {
    try {
      final reminders = await _service.getAllReminders();
      final ids = reminders.map((r) => r['id'] as String).toList();
      
      await _service.bulkUpdateStatus(ids, true);
      debugPrint('✅ All reminders enabled');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  /// Export all reminders as JSON
  Future<void> exportReminders() async {
    try {
      final json = await _service.exportRemindersAsJson();
      debugPrint('✅ Exported: $json');
      // Could save to file here
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  /// Delete all reminders
  Future<void> deleteAllReminders() async {
    try {
      await _service.deleteAllReminders();
      debugPrint('✅ All reminders deleted');
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }
}
```

### Example 4: Reminder Scheduling with Patterns
```dart
class SmartReminderScheduler {
  final ReminderService _service = ReminderService();

  /// Create morning medicine reminders (common pattern)
  Future<void> scheduleMorningRegimen() async {
    final times = ['06:00 AM', '08:00 AM', '10:00 AM'];
    
    for (String time in times) {
      await _service.addReminder(time);
    }
    debugPrint('✅ Morning regimen scheduled');
  }

  /// Create daily medicine routine (3 times a day)
  Future<void> scheduleDailyRoutine() async {
    final times = ['08:00 AM', '01:00 PM', '08:00 PM'];
    
    for (String time in times) {
      await _service.addReminder(time);
    }
    debugPrint('✅ Daily routine scheduled');
  }

  /// Create custom schedule
  Future<void> scheduleCustom(List<String> times) async {
    for (String time in times) {
      final exists = await _service.reminderExistsAtTime(time);
      if (!exists) {
        await _service.addReminder(time);
      }
    }
    debugPrint('✅ Custom schedule created');
  }

  /// Get next reminder time
  Future<String?> getNextReminderTime() async {
    try {
      final reminders = await _service.getActiveRemindersCount() > 0
          ? await _service.getRemindersByStatus(true)
          : [];

      if (reminders.isEmpty) return null;

      // Sort by time (should already be sorted, but just in case)
      reminders.sort((a, b) =>
          a['time_of_day'].compareTo(b['time_of_day']));

      return reminders.first['time_of_day'];
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }
}
```

### Example 5: User-Friendly Time Input Dialog
```dart
Future<void> showAdvancedTimePicker(BuildContext context) async {
  TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0B0F3B),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child ?? const SizedBox(),
      );
    },
  );

  if (picked != null) {
    final timeString = picked.format(context);
    
    // Show confirmation dialog
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Reminder?'),
          content: Text('Set reminder for $timeString?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add reminder logic here
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }
}
```

### Example 6: Error Recovery Pattern
```dart
class ReminderErrorHandler {
  final ReminderService _service = ReminderService();

  /// Safe add reminder with automatic retry
  Future<Map<String, dynamic>?> safeAddReminder(
    String timeOfDay, {
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final reminder = await _service.addReminder(timeOfDay);
        return reminder;
      } on SocketException {
        debugPrint('Network error, retrying... (${i + 1}/$maxRetries)');
        await Future.delayed(Duration(seconds: 2 * (i + 1)));
      } catch (e) {
        debugPrint('Error on attempt ${i + 1}: $e');
        if (i == maxRetries - 1) rethrow;
      }
    }
    return null;
  }

  /// Verify database integrity
  Future<bool> verifyDatabaseIntegrity() async {
    try {
      return await _service.verifyConnection();
    } catch (e) {
      debugPrint('❌ Database verification failed: $e');
      return false;
    }
  }

  /// Get diagnostic info
  Future<String> getDiagnosticInfo() async {
    try {
      final isConnected = await verifyConnection();
      final reminders = await _service.getAllReminders();
      final activeCount = await _service.getActiveRemindersCount();

      return '''
Diagnostic Report:
- Database Connected: $isConnected
- Total Reminders: ${reminders.length}
- Active Reminders: $activeCount
- Last Update: ${DateTime.now()}
      ''';
    } catch (e) {
      return 'Error: $e';
    }
  }
}

import 'dart:io';
```

---

## 🧬 Advanced Patterns

### Pattern 1: Dependency Injection
```dart
class ReminderModule {
  static late ReminderService _reminderService;

  static void initialize() {
    _reminderService = ReminderService();
  }

  static ReminderService getService() => _reminderService;
}

// Usage
void main() {
  ReminderModule.initialize();
}

// In widgets
final service = ReminderModule.getService();
```

### Pattern 2: State Management with ChangeNotifier
```dart
class ReminderProvider extends ChangeNotifier {
  final ReminderService _service = ReminderService();
  List<Map<String, dynamic>> _reminders = [];

  List<Map<String, dynamic>> get reminders => _reminders;

  Future<void> loadReminders() async {
    try {
      _reminders = await _service.getAllReminders();
      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> addReminder(String timeOfDay) async {
    await _service.addReminder(timeOfDay);
    await loadReminders();
  }

  Future<void> deleteReminder(String id) async {
    await _service.deleteReminder(id);
    await loadReminders();
  }
}

// Usage in widget
Consumer<ReminderProvider>(
  builder: (context, provider, _) {
    return ListView.builder(
      itemCount: provider.reminders.length,
      itemBuilder: (context, index) {
        final reminder = provider.reminders[index];
        return ListTile(title: Text(reminder['time_of_day']));
      },
    );
  },
)
```

### Pattern 3: Repository Pattern
```dart
abstract class ReminderRepository {
  Future<List<Map<String, dynamic>>> getAllReminders();
  Future<void> addReminder(String timeOfDay);
  Future<void> deleteReminder(String id);
}

class SupabaseReminderRepository implements ReminderRepository {
  final ReminderService _service = ReminderService();

  @override
  Future<List<Map<String, dynamic>>> getAllReminders() =>
      _service.getAllReminders();

  @override
  Future<void> addReminder(String timeOfDay) =>
      _service.addReminder(timeOfDay);

  @override
  Future<void> deleteReminder(String id) =>
      _service.deleteReminder(id);
}

// Usage
final ReminderRepository repository = SupabaseReminderRepository();
final reminders = await repository.getAllReminders();
```

---

## 📊 Performance Optimization

### Caching Strategy
```dart
class CachedReminderService {
  final ReminderService _service = ReminderService();
  List<Map<String, dynamic>> _cache = [];
  DateTime _lastFetch = DateTime(2000);

  Future<List<Map<String, dynamic>>> getAllReminders({
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    final now = DateTime.now();
    
    if (_cache.isNotEmpty &&
        now.difference(_lastFetch).inSeconds <
            cacheDuration.inSeconds) {
      return _cache;
    }

    _cache = await _service.getAllReminders();
    _lastFetch = now;
    return _cache;
  }

  void invalidateCache() {
    _cache = [];
    _lastFetch = DateTime(2000);
  }
}
```

---

## 🔍 Monitoring & Logging

```dart
class ReminderLogger {
  static void logReminderAction(
    String action,
    Map<String, dynamic> data,
  ) {
    final timestamp = DateTime.now();
    debugPrint('''
┌─────────────────────────────────────┐
│ Reminder Action: $action
├─────────────────────────────────────┤
│ Timestamp: $timestamp
│ Data: $data
└─────────────────────────────────────┘
    ''');
  }

  static void logError(String error, StackTrace? stack) {
    debugPrint('''
❌ ERROR: $error
Stack: ${stack ?? 'N/A'}
    ''');
  }
}
```

---

**For more information, see:**
- REMINDER_QUICK_START.md
- SUPABASE_REMINDERS_SETUP.md
