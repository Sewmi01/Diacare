import 'dart:io';

import 'package:diecare_app/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  Future<String> uploadPatientReport({
    required File file,
    required String patientId,
    String? originalFileName,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception(
        "Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY in .env",
      );
    }

    final bucket = SupabaseConfig.reportsBucket;
    final extension = _detectExtension(originalFileName ?? file.path);
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";
    final filePath = "patients/$patientId/reports/$fileName";
    final contentType = _contentTypeForExtension(extension);

    await Supabase.instance.client.storage.from(bucket).upload(
          filePath,
          file,
          fileOptions: FileOptions(
            cacheControl: "3600",
            upsert: false,
            contentType: contentType,
          ),
        );

    // This expects the bucket to be public.
    return Supabase.instance.client.storage.from(bucket).getPublicUrl(filePath);
  }

  String _detectExtension(String fileNameOrPath) {
    final normalized = fileNameOrPath.toLowerCase();
    final dotIndex = normalized.lastIndexOf(".");
    if (dotIndex == -1 || dotIndex == normalized.length - 1) {
      return "jpg";
    }
    final ext = normalized.substring(dotIndex + 1);
    switch (ext) {
      case "jpg":
      case "jpeg":
      case "png":
      case "pdf":
        return ext;
      default:
        return "jpg";
    }
  }

  String _contentTypeForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case "pdf":
        return "application/pdf";
      case "png":
        return "image/png";
      case "jpeg":
      case "jpg":
      default:
        return "image/jpeg";
    }
  }
}
