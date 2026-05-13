import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:diecare_app/services/patient_reports_service.dart';
import 'package:diecare_app/services/supabase_storage_service.dart';

class ReportPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const ReportPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  File? _selectedFile;
  String? _selectedFileName;
  bool _isUploading = false;

  final SupabaseStorageService _storage = SupabaseStorageService();
  final PatientReportsService _service = PatientReportsService();

  Future<void> _pickFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["jpg", "jpeg", "png", "pdf"],
    );

    if (picked == null || picked.files.isEmpty) return;

    final file = picked.files.first;

    setState(() {
      _selectedFile = File(file.path!);
      _selectedFileName = file.name;
    });
  }

  Future<void> _uploadReport() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final url = await _storage.uploadPatientReport(
        file: _selectedFile!,
        patientId: widget.patientId,
        originalFileName: _selectedFileName,
      );

      await _service.createReport(
        patientId: widget.patientId,
        patientName: widget.patientName,
        imageUrl: url,
        uploadedByDoctorId: FirebaseAuth.instance.currentUser?.uid,
      );

      setState(() {
        _selectedFile = null;
        _selectedFileName = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report uploaded successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteReport(String id) async {
    await _service.deleteReport(id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F3B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F3B),
        title: Text("Reports - ${widget.patientName}"),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          // Upload box
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _selectedFile == null
                  ? const Icon(Icons.add, size: 60)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description,
                            color: Colors.blue, size: 50),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            _selectedFileName ?? "",
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: _isUploading ? null : _uploadReport,
            child: _isUploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Upload"),
          ),

          const SizedBox(height: 20),

          // LIST
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _service.watchReports(widget.patientId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reports = snapshot.data!;

                if (reports.isEmpty) {
                  return const Center(
                    child: Text(
                      "No reports yet",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final r = reports[index];

                    // 🔥 SAFE ID CONVERSION (FIX for int error)
                    final id = r["id"].toString();

                    final imageUrl = r["image_url"] ?? "";

                    return Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              r["title"] ?? "Doctor Report",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () {
                              // simple preview logic placeholder
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  content: Image.network(imageUrl),
                                ),
                              );
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReport(id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}