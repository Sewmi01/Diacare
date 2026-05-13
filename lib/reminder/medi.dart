import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MediPlanPage extends StatelessWidget {
  final String patientId;
  final String patientName;

  const MediPlanPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2A5E),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(Icons.medication, color: Colors.redAccent, size: 70),

            const SizedBox(height: 10),

            Text(
              "Medicine Plan - $patientName",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("patients")
                    .doc(patientId)
                    .collection("medicineNotes")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  final notes = snapshot.data!.docs;

                  if (notes.isEmpty) {
                    return const Center(
                      child: Text(
                        "No medicines added yet",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final data = notes[index].data() as Map<String, dynamic>;
                      final note = data["note"] ?? "";

                      return _medicineCard(note, index + 1);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicineCard(String note, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.redAccent,
            child: Text(
              "$index",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}