import 'package:flutter/material.dart';
import 'patient2register.dart';

class PatientRegisterPage1 extends StatefulWidget {
  const PatientRegisterPage1({super.key});

  @override
  State<PatientRegisterPage1> createState() => _PatientRegisterPage1State();
}

class _PatientRegisterPage1State extends State<PatientRegisterPage1> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  void nextPage() {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientRegisterPage2(
          name: nameController.text,
          mobile: mobileController.text,
          email: emailController.text,
          password: passwordController.text,
        ),
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    TextInputType? type,
    bool obscure = false,
    VoidCallback? toggle,
    bool showToggle = false,
    bool isVisible = false,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
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
          suffixIcon: showToggle
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                  onPressed: toggle,
                )
              : null,
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
        title: const Text("Create Account",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.person_add_alt_1,
                size: 80,
                color: Colors.white,
              ),

              const SizedBox(height: 10),

              const Text(
                "Register Patient",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              inputField(
                controller: nameController,
                label: "Full Name",
                icon: Icons.person,
              ),

              inputField(
                controller: mobileController,
                label: "Mobile Number",
                type: TextInputType.phone,
                icon: Icons.phone,
              ),

              inputField(
                controller: emailController,
                label: "Email Address",
                type: TextInputType.emailAddress,
                icon: Icons.email,
              ),

              inputField(
                controller: passwordController,
                label: "Password",
                obscure: !showPassword,
                showToggle: true,
                isVisible: showPassword,
                icon: Icons.lock,
                toggle: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
              ),

              inputField(
                controller: confirmPasswordController,
                label: "Confirm Password",
                obscure: !showConfirmPassword,
                showToggle: true,
                isVisible: showConfirmPassword,
                icon: Icons.lock_outline,
                toggle: () {
                  setState(() {
                    showConfirmPassword = !showConfirmPassword;
                  });
                },
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Next Step",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}