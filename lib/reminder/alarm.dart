// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> init() async {
//     const AndroidInitializationSettings androidInit =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings iOSInit = DarwinInitializationSettings(
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//       requestAlertPermission: true,
//     );

//     const InitializationSettings settings = InitializationSettings(
//       android: androidInit,
//       iOS: iOSInit,
//     );

//     await notificationsPlugin.initialize(
//       settings: settings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         debugPrint('Notification tapped: ${response.payload}');
//       },
//     );

//     // Request permission 
//     await notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.requestNotificationsPermission();
//   }

//   // Schedule DAILY reminder
//   static Future<void> scheduleNotification(
//     int id,
//     String title,
//     String body,
//     DateTime scheduledTime,
//   ) async {
//     try {
//       await notificationsPlugin.zonedSchedule(
//         id: id,
//         title: title,
//         body: body,
//         scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
//         notificationDetails: const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'med_channel',
//             'Medicine Reminder',
//             importance: Importance.max,
//             priority: Priority.high,
//             enableVibration: true,
//           ),
//           iOS: DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         matchDateTimeComponents: DateTimeComponents.time,
//       );
//       debugPrint(
//         ' Notification scheduled: $title at ${scheduledTime.hour}:${scheduledTime.minute}',
//       );
//     } catch (e) {
//       debugPrint(' Error scheduling notification: $e');
//     }
//   }

//   //  Cancel notification
//   static Future<void> cancelNotification(int id) async {
//     await notificationsPlugin.cancel(id: id);
//   }
// }

// class alarmpage1 extends StatefulWidget {
//   const alarmpage1({super.key});

//   @override
//   State<alarmpage1> createState() => _AlarmPageState();
// }

// class _AlarmPageState extends State<alarmpage1> {
  

//   final _supabase = Supabase.instance.client;
//   List<ReminderModel> reminders = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     tz.initializeTimeZones();
//     _loadReminders();
//   }

//   //  Load reminders from Supabase
//   Future<void> _loadReminders() async {
//     setState(() => isLoading = true);

//     try {
//       final user = _supabase.auth.currentUser;
//       if (user == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text(' User not authenticated')),
//           );
//         }
//         return;
//       }

//       final data = await _supabase
//           .from('medicine_reminders')
//           .select()
//           .eq('user_id', user.id)
//           .order('time_of_day', ascending: true);

//       if (mounted) {
//         setState(() {
//           reminders = (data as List)
//               .map((item) => ReminderModel.fromMap(item))
//               .toList();
//           isLoading = false;
//         });
//       }

//       debugPrint(' Loaded ${reminders.length} reminders');
//     } catch (e) {
//       debugPrint(' Error loading reminders: $e');
//       if (mounted) {
//         setState(() => isLoading = false);
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error loading reminders: $e')));
//       }
//     }
//   }

//   //  Save reminder to Supabase
//   Future<void> _saveReminder(String timeOfDay) async {
//     try {
//       final user = _supabase.auth.currentUser;
//       if (user == null) throw Exception('User not authenticated');

//       final response = await _supabase.from('medicine_reminders').insert({
//         'user_id': user.id,
//         'time_of_day': timeOfDay,
//         'is_active': true,
//       }).select();

//       if (response.isNotEmpty) {
//         final newReminder = ReminderModel.fromMap(response[0]);

//         setState(() {
//           reminders.add(newReminder);
//           reminders.sort((a, b) => a.timeOfDay.compareTo(b.timeOfDay));
//         });

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(' Reminder saved successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }

//         debugPrint(' Reminder saved to Supabase: $timeOfDay');
//       }
//     } catch (e) {
//       debugPrint(' Error saving reminder: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error saving reminder: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   //  Delete reminder from Supabase
//   Future<void> _deleteReminder(String reminderId) async {
//     try {
//       await _supabase.from('medicine_reminders').delete().eq('id', reminderId);

//       setState(() {
//         reminders.removeWhere((r) => r.id == reminderId);
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(' Reminder deleted!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }

//       debugPrint(' Reminder deleted from Supabase');
//     } catch (e) {
//       debugPrint(' Error deleting reminder: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error deleting reminder: $e')));
//       }
//     }
//   }

//   //  Pick time & set reminder
//   Future<void> _pickTimeAndSetReminder() async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );

//     if (picked != null) {
//       final timeString = picked.format(context);

//       // Schedule local notification (daily at this time)
//       final now = DateTime.now();
//       DateTime scheduledTime = DateTime(
//         now.year,
//         now.month,
//         now.day,
//         picked.hour,
//         picked.minute,
//       );

//       if (scheduledTime.isBefore(now)) {
//         scheduledTime = scheduledTime.add(const Duration(days: 1));
//       }

//       // Schedule notification
//       await NotificationService.scheduleNotification(
//         picked.hashCode,
//         "💊 Medicine Reminder",
//         "Time to take your medicine!",
//         scheduledTime,
//       );

//       // Save to Supabase
//       await _saveReminder(timeString);
//     }
//   }

//   //  Toggle reminder active/inactive
//   Future<void> _toggleReminder(String reminderId, bool newStatus) async {
//     try {
//       await _supabase
//           .from('medicine_reminders')
//           .update({'is_active': newStatus})
//           .eq('id', reminderId);

//       setState(() {
//         final index = reminders.indexWhere((r) => r.id == reminderId);
//         if (index != -1) {
//           reminders[index] = reminders[index].copyWith(isActive: newStatus);
//         }
//       });

//       debugPrint(' Reminder toggled: $newStatus');
//     } catch (e) {
//       debugPrint(' Error toggling reminder: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("💊 Medicine Reminders"),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: const Color.fromARGB(255, 228, 228, 234),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color.fromARGB(255, 228, 228, 236), Color.fromARGB(255, 227, 228, 239)],
//           ),
//         ),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//                 children: [
//                   Expanded(
//                     child: reminders.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: const [
//                                 Icon(
//                                   Icons.alarm_off,
//                                   size: 80,
//                                   color: Color.fromARGB(137, 21, 20, 20),
//                                 ),
//                                 SizedBox(height: 15),
//                                 Text(
//                                   "No reminders set",
//                                   style: TextStyle(
//                                     color: Color.fromARGB(137, 23, 23, 23),
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : ListView.builder(
//                             padding: const EdgeInsets.all(16),
//                             itemCount: reminders.length,
//                             itemBuilder: (context, index) {
//                               final reminder = reminders[index];
//                               return Card(
//                                 color: Colors.white10,
//                                 margin: const EdgeInsets.only(bottom: 12),
//                                 child: ListTile(
//                                   leading: Icon(
//                                     reminder.isActive
//                                         ? Icons.alarm
//                                         : Icons.alarm_off,
//                                     color: reminder.isActive
//                                         ? Colors.green
//                                         : Colors.grey,
//                                   ),
//                                   title: Text(
//                                     "Reminder at ${reminder.timeOfDay}",
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   subtitle: Text(
//                                     reminder.isActive ? "Active" : "Inactive",
//                                     style: TextStyle(
//                                       color: reminder.isActive
//                                           ? Colors.green
//                                           : Colors.grey,
//                                     ),
//                                   ),
//                                   trailing: SizedBox(
//                                     width: 100,
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         Switch(
//                                           value: reminder.isActive,
//                                           onChanged: (val) =>
//                                               _toggleReminder(reminder.id, val),
//                                           activeColor: Colors.green,
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(
//                                             Icons.delete,
//                                             color: Colors.red,
//                                           ),
//                                           onPressed: () =>
//                                               _deleteReminder(reminder.id),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: ElevatedButton.icon(
//                       onPressed: _pickTimeAndSetReminder,
//                       icon: const Icon(Icons.add_alarm),
//                       label: const Text("Add Reminder"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 30,
//                           vertical: 15,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

// // 📦 Reminder Model
// class ReminderModel {
//   final String id;
//   final String userId;
//   final String timeOfDay;
//   final bool isActive;
//   final DateTime createdAt;

//   ReminderModel({
//     required this.id,
//     required this.userId,
//     required this.timeOfDay,
//     required this.isActive,
//     required this.createdAt,
//   });

//   factory ReminderModel.fromMap(Map<String, dynamic> map) {
//     return ReminderModel(
//       id: map['id'] as String,
//       userId: map['user_id'] as String,
//       timeOfDay: map['time_of_day'] as String,
//       isActive: map['is_active'] as bool? ?? true,
//       createdAt: DateTime.parse(map['created_at'] as String),
//     );
//   }

//   ReminderModel copyWith({
//     String? id,
//     String? userId,
//     String? timeOfDay,
//     bool? isActive,
//     DateTime? createdAt,
//   }) {
//     return ReminderModel(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       timeOfDay: timeOfDay ?? this.timeOfDay,
//       isActive: isActive ?? this.isActive,
//       createdAt: createdAt ?? this.createdAt,
//     );
//   }
// }
