import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Patientbeverages extends StatefulWidget {
  final String patientId;
  final String patientName;

  const Patientbeverages({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<Patientbeverages> createState() => _PatientbeveragesState();
}

class _PatientbeveragesState extends State<Patientbeverages> {
  final TextEditingController _controller = TextEditingController();

  late final DocumentReference<Map<String, dynamic>> docRef;

  @override
  void initState() {
    super.initState();
    docRef = FirebaseFirestore.instance
        .collection("patients")
        .doc(widget.patientId)
        .collection("foodlists")
        .doc("beverages");
  }

  Future<void> _addItem() async {
    if (_controller.text.trim().isEmpty) return;

    final snap = await docRef.get();
    List items = snap.data()?["list"] ?? [];

    items.add(_controller.text.trim());

    await docRef.set({
      "patientId": widget.patientId,
      "patientName": widget.patientName,
      "category": "beverages",
      "list": items,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    _controller.clear();
    Navigator.pop(context);
  }

  Future<void> _deleteItem(String value) async {
    final snap = await docRef.get();
    List items = snap.data()?["list"] ?? [];

    items.remove(value);

    await docRef.update({
      "list": items,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Add Beverage"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "e.g. Water / Juice / Milk",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _addItem,
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F3B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F3B),
        title: Text("Beverages - ${widget.patientName}"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final List items = data?["list"] ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_drink, size: 80, color: Colors.white54),
                  SizedBox(height: 10),
                  Text(
                    "No beverages added yet",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Dismissible(
                key: Key(item + index.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _deleteItem(item),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_drink, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Icon(Icons.swipe_left, size: 18, color: Colors.grey),
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
}