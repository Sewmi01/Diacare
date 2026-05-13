import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ReportViewerPage extends StatefulWidget {
  final String reportUrl;
  final String title;

  const ReportViewerPage({
    super.key,
    required this.reportUrl,
    required this.title,
  });

  @override
  State<ReportViewerPage> createState() => _ReportViewerPageState();
}

class _ReportViewerPageState extends State<ReportViewerPage> {
  bool isLoading = false;

  bool get isPdf {
    final url = widget.reportUrl.toLowerCase();
    return url.contains(".pdf");
  }

  Future<void> openFile() async {
    final uri = Uri.parse(widget.reportUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> downloadFile() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(widget.reportUrl));

      final dir = await getApplicationDocumentsDirectory();
      final fileName = widget.reportUrl.split('/').last;
      final file = File("${dir.path}/$fileName");

      await file.writeAsBytes(response.bodyBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Saved: $fileName")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Download failed")),
        );
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2A5E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2A5E),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: isLoading ? null : downloadFile,
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          const Icon(Icons.description, color: Colors.white, size: 70),

          const SizedBox(height: 10),

          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: isPdf ? _pdfView() : _imageView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pdfView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.picture_as_pdf, color: Colors.red, size: 80),

        const SizedBox(height: 20),

        ElevatedButton.icon(
          onPressed: openFile,
          icon: const Icon(Icons.open_in_new),
          label: const Text("Open PDF"),
        ),

        const SizedBox(height: 10),

        ElevatedButton.icon(
          onPressed: isLoading ? null : downloadFile,
          icon: const Icon(Icons.download),
          label: Text(isLoading ? "Downloading..." : "Download"),
        ),
      ],
    );
  }

  Widget _imageView() {
    return Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Image.network(
              widget.reportUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Text("Could not load image"),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        ElevatedButton.icon(
          onPressed: isLoading ? null : downloadFile,
          icon: const Icon(Icons.download),
          label: Text(isLoading ? "Downloading..." : "Download Image"),
        ),
      ],
    );
  }
}