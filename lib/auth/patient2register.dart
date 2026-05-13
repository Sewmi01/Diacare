import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diecare_app/patientHome/home1.dart';

class PatientRegisterPage2 extends StatefulWidget {
  final String name;
  final String mobile;
  final String email;
  final String password;

  const PatientRegisterPage2({
    super.key,
    required this.name,
    required this.mobile,
    required this.email,
    required this.password,
  });

  @override
  State<PatientRegisterPage2> createState() => _PatientRegisterPage2State();
}

class _PatientRegisterPage2State extends State<PatientRegisterPage2> {
  final ageController = TextEditingController();
  final conditionController = TextEditingController();

  bool isLoading = false;

  Future<void> registerPatient() async {
    if (ageController.text.isEmpty || conditionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      await FirebaseFirestore.instance
          .collection("patients")
          .doc(userCredential.user!.uid)
          .set({
        "name": widget.name,
        "mobile": widget.mobile,
        "email": widget.email,
        "age": ageController.text,
        "condition": conditionController.text,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            patientId: userCredential.user!.uid,
            patientName: widget.name,
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    TextInputType? type,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.white70)
              : null,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F3B),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Complete Registration",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.health_and_safety,
                size: 80,
                color: Colors.white,
              ),

              const SizedBox(height: 10),

              const Text(
                "Step 2",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Medical Information",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 30),

              inputField(
                controller: ageController,
                label: "Age",
                type: TextInputType.number,
                icon: Icons.cake,
              ),

              inputField(
                controller: conditionController,
                label: "Medical Condition",
                icon: Icons.medical_information,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Complete Registration"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}