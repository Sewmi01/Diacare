//import 'package:diecare_app/chatBot/chatbot.dart';
import 'package:diecare_app/chatBot/chatbot2.dart';
import 'package:diecare_app/patientHome/home1.dart';
import 'package:diecare_app/patientHome/report_viewer_page.dart';
import 'package:diecare_app/reminder/reminder1.dart';
import 'package:diecare_app/services/patient_reports_service.dart';
import 'package:flutter/material.dart';

class DietPlanPage extends StatelessWidget {
  final String patientId;
  final String patientName;

  const DietPlanPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  static final PatientReportsService _patientReportsService =
      PatientReportsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0F3B), Color(0xFF040627)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [Image.asset("assets/icons/dia 1.png", height: 40)],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Doctor Uploaded Reports for $patientName",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _patientReportsService.watchReports(patientId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final reports = snapshot.data!;
                    if (reports.isEmpty) {
                      return const Center(
                        child: Text(
                          "No reports uploaded yet",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final data = reports[index];
                        final reportUrl =
                            ((data["image_url"] ?? data["imageUrl"]) ?? "")
                                .toString();
                        final title = ((data["title"] ?? "Report") as Object)
                            .toString();
                        final isPdf = _looksLikePdf(reportUrl);

                        if (reportUrl.isEmpty) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.black26,
                            ),
                            child: const Center(
                              child: Text(
                                "Report unavailable",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportViewerPage(
                                  reportUrl: reportUrl,
                                  title: title,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              image: isPdf
                                  ? null
                                  : DecorationImage(
                                      image: NetworkImage(reportUrl),
                                      fit: BoxFit.cover,
                                    ),
                              color: isPdf ? Colors.white : null,
                            ),
                            child: isPdf
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: Colors.white,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.picture_as_pdf,
                                        size: 72,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomePage(
                      patientId: patientId,
                      patientName: patientName,
                    ),
                  ),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.notifications, size: 28),
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
              icon: const Icon(Icons.person, size: 28),
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
    );
  }

  bool _looksLikePdf(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith(".pdf") || lower.contains(".pdf?");
  }
}
