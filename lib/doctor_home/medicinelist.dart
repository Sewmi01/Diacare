import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Medicinelist1 extends StatefulWidget {
  final String patientId;
  final String patientName;

  const Medicinelist1({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<Medicinelist1> createState() => _Medicinelist1State();
}

class _Medicinelist1State extends State<Medicinelist1> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _addNote() async {
    if (_controller.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection("patients")
        .doc(widget.patientId)
        .collection("medicineNotes")
        .add({
      "note": _controller.text.trim(),
      "createdAt": Timestamp.now(),
    });

    _controller.clear();
    Navigator.pop(context);
  }

  Future<void> _deleteNote(String docId) async {
    await FirebaseFirestore.instance
        .collection("patients")
        .doc(widget.patientId)
        .collection("medicineNotes")
        .doc(docId)
        .delete();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Medicine"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Enter medicine note...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _addNote,
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete note?"),
        content: const Text("This will remove the medicine note."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _deleteNote(id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
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
        title: Text("Medicine - ${widget.patientName}"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("patients")
            .doc(widget.patientId)
            .collection("medicineNotes")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data!.docs;

          if (notes.isEmpty) {
            return const Center(
              child: Text(
                "No medicine added yet",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final data = notes[index];
              final note = data["note"];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medication, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        note,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(data.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}