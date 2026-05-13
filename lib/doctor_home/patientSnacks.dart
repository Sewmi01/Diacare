import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Patientsnacks extends StatefulWidget {
  final String patientId;
  final String patientName;

  const Patientsnacks({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<Patientsnacks> createState() => _PatientsnacksState();
}

class _PatientsnacksState extends State<Patientsnacks> {
  final TextEditingController _controller = TextEditingController();

  DocumentReference<Map<String, dynamic>> get docRef => FirebaseFirestore
      .instance
      .collection("patients")
      .doc(widget.patientId)
      .collection("foodlists")
      .doc("snacks");

  Future<void> _addItem() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final snap = await docRef.get();
    List items = snap.data()?["list"] ?? [];

    items.add(text);

    await docRef.set({
      "patientId": widget.patientId,
      "patientName": widget.patientName,
      "category": "snacks",
      "list": items,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    _controller.clear();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteItem(String value) async {
    final snap = await docRef.get();
    List items = snap.data()?["list"] ?? [];

    if (items.contains(value)) {
      items.remove(value);
    }

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
        title: const Text("Add Snack"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "e.g. Biscuits / Chips / Cake",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _controller.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(onPressed: _addItem, child: const Text("Add")),
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
        title: Text("Snacks - ${widget.patientName}"),
        actions: [
          IconButton(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final List items = data?["list"] ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fastfood, size: 80, color: Colors.white54),
                  SizedBox(height: 10),
                  Text(
                    "No snacks added yet",
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
                  margin: const EdgeInsets.only(bottom: 12),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
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
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fastfood, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item, style: const TextStyle(fontSize: 16)),
                      ),
                      const Icon(
                        Icons.swipe_left,
                        size: 18,
                        color: Colors.grey,
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
}
