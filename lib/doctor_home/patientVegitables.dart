import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Patientvegitables extends StatefulWidget {
  final String patientId;
  final String patientName;

  const Patientvegitables({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<Patientvegitables> createState() => _PatientvegitablesState();
}

class _PatientvegitablesState extends State<Patientvegitables> {
  final TextEditingController _controller = TextEditingController();

  DocumentReference<Map<String, dynamic>> get docRef =>
      FirebaseFirestore.instance
          .collection("patients")
          .doc(widget.patientId)
          .collection("foodlists")
          .doc("vegetables");

  Future<void> _addItem() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final snap = await docRef.get();
    List items = snap.data()?["list"] ?? [];

    items.add(text);

    await docRef.set({
      "patientId": widget.patientId,
      "patientName": widget.patientName,
      "category": "vegetables",
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Add Vegetable"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Carrot / Cabbage / Spinach",
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
        title: Text("Vegetables - ${widget.patientName}"),
        actions: [
          IconButton(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add_circle_outline),
          )
        ],
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "No vegetables added yet",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final data = snapshot.data!.data();
          final List items = (data?['list'] as List<dynamic>?) ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                "No vegetables added yet",
                style: TextStyle(color: Colors.white70),
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
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item)),
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