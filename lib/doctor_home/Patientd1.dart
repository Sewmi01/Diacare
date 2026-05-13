import 'package:diecare_app/doctor_home/medicinelist.dart';
import 'package:diecare_app/doctor_home/patientBeverages.dart';
import 'package:diecare_app/doctor_home/patientFruits.dart';
import 'package:diecare_app/doctor_home/patientReport.dart';
import 'package:diecare_app/doctor_home/patientSnacks.dart';
import 'package:diecare_app/doctor_home/patientVegitables.dart';
import 'package:flutter/material.dart';

class Patientd1 extends StatelessWidget {
  final String patientId;
  final String patientName;

  const Patientd1({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F3B),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Top header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Image.asset("assets/icons/dia 1.png", height: 40),
                  const SizedBox(width: 10),
                  const Text(
                    "Patient Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Greeting card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Hello, $patientName",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Food categories (image cards)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                  children: [
                    _card(
                      context,
                      "Vegetables",
                      "assets/images/vegetable.png",
                      Colors.green,
                      Patientvegitables(
                        patientId: patientId,
                        patientName: patientName,
                      ),
                    ),
                    _card(
                      context,
                      "Fruits",
                      "assets/images/fruits.png",
                      Colors.red,
                      Patientfruits(
                        patientId: patientId,
                        patientName: patientName,
                      ),
                    ),
                    _card(
                      context,
                      "Beverages",
                      "assets/images/beverage.png",
                      Colors.blue,
                      Patientbeverages(
                        patientId: patientId,
                        patientName: patientName,
                      ),
                    ),
                    _card(
                      context,
                      "Snacks",
                      "assets/images/snacks.png",
                      Colors.orange,
                      Patientsnacks(
                        patientId: patientId,
                        patientName: patientName,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _button(
                    context,
                    "Medicine List",
                    Icons.medication,
                    Medicinelist1(
                      patientId: patientId,
                      patientName: patientName,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _button(
                    context,
                    "Patient Reports",
                    Icons.picture_as_pdf,
                    ReportPage(patientId: patientId, patientName: patientName),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String title,
    String img,
    Color color,
    Widget page,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
            ),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.bottomLeft,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 5, color: Colors.black)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _button(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        icon: Icon(icon),
        label: Text(title),
      ),
    );
  }
}
