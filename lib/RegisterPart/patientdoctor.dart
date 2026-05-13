//import '../../auth/doctorregister.dart';
import '../../auth/patient1register.dart';
import 'package:flutter/material.dart';

class LoginRolePage1 extends StatelessWidget {
  const LoginRolePage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A2A5E), Color(0xFF123B7A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const Spacer(),

              // Logo
              SizedBox(
                height: 140,
                child: Image.asset("assets/icons/dia 1.png"),
              ),

              const SizedBox(height: 20),

              const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // const Text(
              //   "Select your role to register",
              //   style: TextStyle(
              //     color: Colors.white70,
              //     fontSize: 14,
              //   ),
              // ),
              const SizedBox(height: 50),

              // Patient Register Button
              _roleButton(
                context,
                title: "Patient",
                icon: Icons.person,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientRegisterPage1(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Doctor Register Button
              // _roleButton(
              //   context,
              //   title: "Doctor",
              //   icon: Icons.local_hospital,
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const DoctorRegisterPage(),
              //       ),
              //     );
              //   },
              // ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: onTap,
      ),
    );
  }
}
