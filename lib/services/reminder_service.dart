import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Colombo'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidInit);

    await notificationsPlugin.initialize(settings: settings);

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> addReminder(String title, String desc, DateTime time) async {
    final user = auth.currentUser;

    if (user == null) return;

    final docRef = await firestore.collection('reminders').add({
      'userId': user.uid,
      'title': title,
      'description': desc,
      'time': time,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _scheduleNotification(docRef.id, title, desc, time);
  }

  Future<List<QueryDocumentSnapshot>> getReminders() async {
    final user = auth.currentUser;
    if (user == null) return [];

    final snapshot = await firestore
        .collection('reminders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('time')
        .get();

    return snapshot.docs;
  }

  Future<void> deleteReminder(String docId) async {
    await firestore.collection('reminders').doc(docId).delete();
    await notificationsPlugin.cancel(id: docId.hashCode);
  }

  Future<void> _scheduleNotification(
    String id,
    String title,
    String body,
    DateTime time,
  ) async {
    final tzTime = tz.TZDateTime.from(time, tz.local);

    await notificationsPlugin.zonedSchedule(
      id: id.hashCode,
      title: title,
      body: body,
      scheduledDate: tzTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Medicine Reminders',
          channelDescription: 'Used for medicine alarms',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
