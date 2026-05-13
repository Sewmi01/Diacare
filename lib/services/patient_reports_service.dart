import 'package:supabase_flutter/supabase_flutter.dart';

class PatientReportsService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> watchReports(String patientId) {
    return _client
        .from("patient_reports")
        .stream(primaryKey: ["id"])
        .eq("patient_id", patientId)
        .map((data) {
          final list = List<Map<String, dynamic>>.from(data);

          list.sort((a, b) {
            final aTime = a["uploaded_at"] ?? "";
            final bTime = b["uploaded_at"] ?? "";
            return bTime.toString().compareTo(aTime.toString());
          });

          return list;
        });
  }

  Future<void> createReport({
    required String patientId,
    required String patientName,
    required String imageUrl,
    String? uploadedByDoctorId,
  }) async {
    await _client.from("patient_reports").insert({
      "patient_id": patientId,
      "patient_name": patientName,
      "title": "Doctor Report",
      "image_url": imageUrl,
      "storage_provider": "supabase",
      "uploaded_by_doctor_id": uploadedByDoctorId,
      "uploaded_at": DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> deleteReport(dynamic reportId) async {
    await _client
        .from("patient_reports")
        .delete()
        .eq(
          "id",
          reportId.toString(), // 🔥 FIX int → string crash
        );
  }
}
