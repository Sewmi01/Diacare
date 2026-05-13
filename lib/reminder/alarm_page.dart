import 'package:flutter/material.dart';
import '../services/reminder_service.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final ReminderService service = ReminderService();
  List reminders = [];

  @override
  void initState() {
    super.initState();
    service.init();
    loadData();
  }

  Future<void> loadData() async {
    final data = await service.getReminders();
    setState(() {
      reminders = data as List<dynamic>;
    });
  }

  Future<void> deleteReminder(String id) async {
    await service.deleteReminder(id);
    loadData();
  }

  void showAddDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedTime = DateTime.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Reminder"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (time != null) {
                    selectedTime = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      time.hour,
                      time.minute,
                    );
                  }
                }
              },
              child: const Text("Pick Date & Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await service.addReminder(
                titleController.text,
                descController.text,
                selectedTime,
              );
              Navigator.pop(context);
              loadData();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2A5E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2A5E),
        title: const Text("Medicine Reminders"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),

      body: reminders.isEmpty
          ? const Center(
              child: Text(
                "No reminders set",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final r = reminders[index].data();
                final id = reminders[index].id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alarm, color: Colors.blue),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(r['description'] ?? ''),
                            const SizedBox(height: 4),
                            Text(
                              formatDate(r['time'].toDate()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteReminder(id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}