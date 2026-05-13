import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BeveragesPage extends StatelessWidget {
  final String patientId;
  final String patientName;

  const BeveragesPage({
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

            const Icon(Icons.local_drink, color: Colors.white, size: 70),

            const SizedBox(height: 10),

            Text(
              "Beverages for $patientName",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("patients")
                    .doc(patientId)
                    .collection("foodlists")
                    .doc("beverages")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (!snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        "No beverages added yet",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final List<dynamic> items = data["list"] ?? [];

                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        "No beverages available",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _listItem(items[index].toString(), index + 1);
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

  Widget _listItem(String text, int index) {
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
            backgroundColor: Colors.blue.shade900,
            child: Text(
              "$index",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
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