import 'package:diecare_app/chatBot/chatbot2.dart';
import 'package:diecare_app/diatPlan/diatplan.dart';
import 'package:diecare_app/imagerecog/image_reg.dart';
import 'package:diecare_app/patientHome/beverage.dart';
import 'package:diecare_app/patientHome/fruit.dart';
import 'package:diecare_app/patientHome/snacks.dart';
import 'package:diecare_app/patientHome/vegetable.dart';
import 'package:diecare_app/reminder/reminder1.dart';
import 'package:diecare_app/start_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final String patientId;
  final String patientName;

  const HomePage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const StartPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2A5E),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/icons/dia 1.png", height: 40),
                  IconButton(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, color: Colors.white),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Hello $patientName 👋",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    categoryButton(
                      context,
                      "Vegetables",
                      "assets/images/vegetable.png",
                      VegetablesPage(
                        patientId: patientId,
                        patientName: patientName,
                      ),
                    ),
                    categoryButton(
                      context,
                      "Fruits",
                      "assets/images/fruits.png",
                      FruitsPage(
                        patientId: patientId,
                        patientName: patientName,
                      ),
                    ),
                    categoryButton(
                      context,
                      "Beverages",
                      "assets/images/beverage.png",
                      BeveragesPage(
                        patientId: patientId,
                        patientName: patientName,
                      ),
                    ),
                    categoryButton(
                      context,
                      "Snacks",
                      "assets/images/snacks.png",
                      Snacks1(patientId: patientId, patientName: patientName),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _actionButton(
                    context,
                    "Patient Report",
                    Icons.bar_chart,
                    DietPlanPage(
                      patientId: patientId,
                      patientName: patientName,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _actionButton(
                    context,
                    "Scan Fruits",
                    Icons.camera_alt,
                    ScanFruits(),
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.home, color: Colors.blue.shade900),
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReminderPage(
                            patientId: patientId,
                            patientName: patientName,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Chatbot2()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryButton(
    BuildContext context,
    String title,
    String imagePath,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withOpacity(0.3),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon),
        label: Text(title),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}
