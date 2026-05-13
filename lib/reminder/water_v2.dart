// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import '../services/reminder_service.dart';

// /// Enhanced Notification Service with better error handling
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
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

//     await _notificationsPlugin.initialize(
//       settings: settings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         debugPrint(' Notification tapped: ${response.payload}');
//       },
//     );

//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.requestNotificationsPermission();

//     // Request iOS permissions if available
//     try {
//       await _notificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin
//           >()
//           ?.requestPermissions(alert: true, badge: true, sound: true);
//     } catch (_) {
//       // iOS permissions handled automatically
//     }
//   }

//   /// Schedule a daily reminder at specific time
//   static Future<void> scheduleReminder(
//     int id,
//     String title,
//     String body,
//     DateTime scheduledTime,
//   ) async {
//     try {
//       await _notificationsPlugin.zonedSchedule(
//         id: id,
//         title: title,
//         body: body,
//         scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
//         notificationDetails: const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'med_channel',
//             'Medicine Reminder',
//             channelDescription: 'Reminders for medicine intake',
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
//         ' Notification scheduled at ${scheduledTime.hour}:${scheduledTime.minute}',
//       );
//     } catch (e) {
//       debugPrint(' Error scheduling notification: $e');
//     }
//   }

//   /// Cancel a specific notification
//   static Future<void> cancelReminder(int id) async {
//     try {
//       await _notificationsPlugin.cancel(id: id);
//       debugPrint(' Notification canceled: $id');
//     } catch (e) {
//       debugPrint(' Error canceling notification: $e');
//     }
//   }

//   /// Cancel all notifications
//   static Future<void> cancelAllReminders() async {
//     try {
//       await _notificationsPlugin.cancelAll();
//       debugPrint(' All notifications canceled');
//     } catch (e) {
//       debugPrint(' Error canceling all notifications: $e');
//     }
//   }
// }

// /// Enhanced Alarm Page with ReminderService integration
// class AlarmPage extends StatefulWidget {
//   const AlarmPage({super.key});

//   @override
//   State<AlarmPage> createState() => _AlarmPageState();
// }

// class _AlarmPageState extends State<AlarmPage> {
//   final ReminderService _reminderService = ReminderService();
//   List<Map<String, dynamic>> reminders = [];
//   bool isLoading = false;
//   bool isError = false;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAlarm();
//   }

//   Future<void> _initializeAlarm() async {
//     tz.initializeTimeZones();
//     await NotificationService.init();
//     await _loadReminders();
//   }

//   ///  Load reminders from Supabase
//   Future<void> _loadReminders() async {
//     setState(() {
//       isLoading = true;
//       isError = false;
//       errorMessage = null;
//     });

//     try {
//       // Verify user is authenticated
//       final user = Supabase.instance.client.auth.currentUser;
//       if (user == null) {
//         throw Exception('User not authenticated. Please log in first.');
//       }

//       final loadedReminders = await _reminderService.getAllReminders();

//       if (mounted) {
//         setState(() {
//           reminders = loadedReminders;
//           isLoading = false;
//         });
//       }

//       debugPrint(' Loaded ${reminders.length} reminders');
//     } catch (e) {
//       debugPrint(' Error loading reminders: $e');
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//           isError = true;
//           errorMessage = e.toString();
//         });
//       }
//     }
//   }

//   /// Pick time and save reminder
//   Future<void> _pickTimeAndSetReminder() async {
//     try {
//       // STRICT: Verify user is authenticated AND session is valid
//       final currentUser = Supabase.instance.client.auth.currentUser;
//       final session = Supabase.instance.client.auth.currentSession;

//       if (currentUser == null || session == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 ' Not logged in. Please sign in to save reminders.',
//               ),
//               backgroundColor: Colors.red,
//               duration: Duration(seconds: 3),
//             ),
//           );
//         }
//         return;
//       }

//       debugPrint(
//         ' User authenticated: ${currentUser.email} | Session active: ${session.user.id}',
//       );

//       TimeOfDay? picked = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );

//       if (picked != null) {
//         final timeString = picked.format(context);

//         try {
//           // Re-verify auth after time picker (in case user took time to pick)
//           if (Supabase.instance.client.auth.currentUser == null) {
//             throw Exception('Session lost. Please log in again.');
//           }

//           // Schedule local notification
//           final now = DateTime.now();
//           DateTime scheduledTime = DateTime(
//             now.year,
//             now.month,
//             now.day,
//             picked.hour,
//             picked.minute,
//           );

//           if (scheduledTime.isBefore(now)) {
//             scheduledTime = scheduledTime.add(const Duration(days: 1));
//           }

//           // Check if reminder already exists
//           final exists = await _reminderService.reminderExistsAtTime(
//             timeString,
//           );
//           if (exists) {
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text(' Reminder already exists at this time'),
//                   backgroundColor: Colors.orange,
//                 ),
//               );
//             }
//             return;
//           }

//           // Schedule notification
//           await NotificationService.scheduleReminder(
//             picked.hashCode,
//             '💊 Medicine Time',
//             'Time to take your medicine!',
//             scheduledTime,
//           );

//           // Save to Supabase
//           await _reminderService.addReminder(timeString);

//           // Reload reminders
//           await _loadReminders();

//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(' Reminder saved at $timeString'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           }
//         } catch (e) {
//           debugPrint(' Error setting reminder: $e');
//           if (mounted) {
//             final errorMsg = e.toString().toLowerCase();
//             final isAuthError =
//                 errorMsg.contains('authenticated') ||
//                 errorMsg.contains('unauthorized') ||
//                 errorMsg.contains('session');

//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   isAuthError
//                       ? ' Login session expired. Please sign in again.'
//                       : ' Error: $e',
//                 ),
//                 backgroundColor: Colors.red,
//                 duration: const Duration(seconds: 3),
//               ),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint(' Unexpected error in _pickTimeAndSetReminder: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(' Unexpected error: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   ///  Delete reminder
//   Future<void> _deleteReminder(String reminderId, String timeOfDay) async {
//     try {
//       // Cancel notification
//       await NotificationService.cancelReminder(timeOfDay.hashCode);

//       // Delete from Supabase
//       await _reminderService.deleteReminder(reminderId);

//       // Reload reminders
//       await _loadReminders();

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(' Reminder deleted'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint(' Error deleting reminder: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     }
//   }

//   ///  Toggle reminder active/inactive
//   Future<void> _toggleReminder(String reminderId, bool isActive) async {
//     try {
//       await _reminderService.updateReminderStatus(reminderId, !isActive);

//       setState(() {
//         final index = reminders.indexWhere((r) => r['id'] == reminderId);
//         if (index != -1) {
//           reminders[index]['is_active'] = !isActive;
//         }
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               !isActive ? ' Reminder activated' : '⏸ Reminder paused',
//             ),
//             backgroundColor: !isActive ? Colors.green : Colors.orange,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint(' Error toggling reminder: $e');
//       await _loadReminders(); // Reload to sync state
//     }
//   }

//   ///  Refresh reminders
//   Future<void> _refreshReminders() async {
//     await _loadReminders();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('💊 Medicine Reminders'),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _refreshReminders,
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color.fromARGB(255, 209, 209, 215), Color.fromARGB(255, 210, 211, 223)],
//           ),
//         ),
//         child: _buildContent(),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     // Show loading
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     // Show error
//     if (isError) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 80, color: Colors.red),
//             const SizedBox(height: 16),
//             Text(
//               'Error: $errorMessage',
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.white, fontSize: 14),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loadReminders,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     // Show reminders list or empty state
//     return Column(
//       children: [
//         Expanded(
//           child: reminders.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.alarm_off,
//                         size: 100,
//                         color: Colors.white30,
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'No reminders set yet',
//                         style: TextStyle(
//                           color: Colors.white30,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'Tap the button below to add your first reminder',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.2),
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: reminders.length,
//                   itemBuilder: (context, index) {
//                     final reminder = reminders[index];
//                     final isActive = reminder['is_active'] ?? true;

//                     return Card(
//                       color: isActive
//                           ? Colors.white.withOpacity(0.1)
//                           : Colors.white.withOpacity(0.05),
//                       margin: const EdgeInsets.only(bottom: 12),
//                       child: ListTile(
//                         leading: Icon(
//                           isActive ? Icons.alarm : Icons.alarm_off,
//                           color: isActive ? Colors.green : Colors.grey,
//                           size: 28,
//                         ),
//                         title: Text(
//                           'Reminder at ${reminder['time_of_day']}',
//                           style: TextStyle(
//                             color: isActive ? Colors.white : Colors.white54,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         subtitle: Text(
//                           isActive ? 'Active' : 'Inactive',
//                           style: TextStyle(
//                             color: isActive ? Colors.green : Colors.grey,
//                             fontSize: 12,
//                           ),
//                         ),
//                         trailing: SizedBox(
//                           width: 120,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Switch(
//                                 value: isActive,
//                                 onChanged: (val) =>
//                                     _toggleReminder(reminder['id'], isActive),
//                                 activeColor: Colors.green,
//                                 inactiveThumbColor: Colors.grey,
//                               ),
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.delete,
//                                   color: Colors.red,
//                                   size: 20,
//                                 ),
//                                 onPressed: () => _deleteReminder(
//                                   reminder['id'],
//                                   reminder['time_of_day'],
//                                 ),
//                                 tooltip: 'Delete',
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(20),
//           child: ElevatedButton.icon(
//             onPressed: _pickTimeAndSetReminder,
//             icon: const Icon(Icons.add_alarm, size: 24),
//             label: const Text(
//               'Add Reminder',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 2,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
