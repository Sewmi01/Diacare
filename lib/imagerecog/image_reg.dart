import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ScanFruits extends StatefulWidget {
  const ScanFruits({super.key});

  @override
  State<ScanFruits> createState() => _FruitScannerState();
}

class _FruitScannerState extends State<ScanFruits> {
  File? image;

  String result = "";
  String confidence = "";

  Interpreter? interpreter;
  List<String> labels = [];

  bool isModelLoaded = false;
  String status = "Loading model...";

  // ✅ Sugar Data
  Map<String, String> sugarData = {
    "apple": "10g",
    "avocado": "0.7g",
    "banana": "12g",
    "barbadine": "11g",
    "camu_camu": "2g",
    "chenet": "14g",
    "cherimoya": "13g",
    "chokeberry": "4g",
    "cranberry": "4g",
    "custard_apple": "10g",
    "damson": "10g",
    "dragonfruit": "8g",
    "durian": "27g",
    "emblic": "6g",
    "grape": "16g",
    "guava": "5g",
    "jackfruit": "19g",
    "kaffir_lime": "1.7g",
    "malay_apple": "8g",
    "orange": "9g",
    "mango": "14g",
    "mangosteen": "13g",
    "otaheite_apple": "7g",
    "papaya": "8g",
    "passion_fruit": "11g",
    "pineapple": "10g",
    "pomegranate": "14g",
    "rambutan": "13g",
    "yali_pear": "10g",
  };

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    await loadModel();
    await loadLabels();

    if (!mounted) return;

    setState(() {
      isModelLoaded = true;
      status = "Model Ready ✅";
    });
  }

  // ✅ Load Model
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(
        "assets/model.tflite",
      );

      print("Model Loaded ✅");
    } catch (e) {
      print("Model Error: $e");

      setState(() {
        status = "Model load failed ❌";
      });
    }
  }

  // ✅ Load Labels
  Future<void> loadLabels() async {
    final data = await rootBundle.loadString(
      "assets/labels.txt",
    );

    labels = data
        .split("\n")
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();

    print(labels);
  }

  // ✅ Pick Image
  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
    );

    if (picked != null) {
      setState(() {
        image = File(picked.path);
        result = "";
        confidence = "";
      });
    }
  }

  // ✅ Run AI Model
  Future<void> runModel() async {
    if (image == null || interpreter == null) {
      return;
    }

    try {
      var bytes = await image!.readAsBytes();

      img.Image? originalImage =
          img.decodeImage(bytes);

      if (originalImage == null) return;

      img.Image resized = img.copyResize(
        originalImage,
        width: 224,
        height: 224,
      );

      var input = List.generate(
        1,
        (_) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) {
              final pixel = resized.getPixel(x, y);

              return [
                pixel.r / 255.0,
                pixel.g / 255.0,
                pixel.b / 255.0,
              ];
            },
          ),
        ),
      );

      var outputShape =
          interpreter!.getOutputTensor(0).shape;

      int numClasses = outputShape[1];

      var output = List.generate(
        1,
        (_) => List.filled(numClasses, 0.0),
      );

      interpreter!.run(input, output);

      List<double> probs = output[0];

      int maxIndex = 0;
      int secondIndex = 1;

      for (int i = 0; i < probs.length; i++) {
        if (probs[i] > probs[maxIndex]) {
          secondIndex = maxIndex;
          maxIndex = i;
        } else if (i != maxIndex &&
            probs[i] > probs[secondIndex]) {
          secondIndex = i;
        }
      }

      double maxVal = probs[maxIndex];
      double secondVal = probs[secondIndex];

      String detected = labels[maxIndex];

      // ✅ Smart Detection
      double threshold = 0.65;
      double margin = 0.20;

      setState(() {
        if (detected == "others" ||
            maxVal < threshold ||
            (maxVal - secondVal) < margin) {
          result = "Not a fruit ❌";
        } else {
          result = detected.replaceAll("_", " ");
        }

        confidence =
            "${(maxVal * 100).toStringAsFixed(2)}%";
      });

      print("Detected: $result");
    } catch (e) {
      print("Run Model Error: $e");

      setState(() {
        result = "Error ❌";
        confidence = "";
      });
    }
  }

  @override
  void dispose() {
    interpreter?.close();
    super.dispose();
  }

  // ✅ Custom Button
  Widget customButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color buttonColor = const Color(0xFF0B0F3B),
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String cleanResult = result
        .trim()
        .toLowerCase()
        .replaceAll(" ", "_");

    // ✅ Sugar Value
    String sugar =
        sugarData[cleanResult] ?? "0g";

    double sugarValue = double.tryParse(
          sugar.replaceAll("g", ""),
        ) ??
        0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF4F7FC),
        title: const Text(
          "Fruit Scanner 🍎",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            children: [

              // ✅ Image Card
              Container(
                width: double.infinity,
                height: 280,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),

                child: image == null
                    ? Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.image_outlined,
                            size: 100,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No Image Selected",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(24),

                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),

              const SizedBox(height: 25),

              // ✅ Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Text(
                  status,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ✅ Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0B0F3B),
                      Color(0xFF1B256B),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B0F3B)
                          .withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    const Text(
                      "Detection Result",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      result.isEmpty ? "-" : result,

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Confidence : ${confidence.isEmpty ? '-' : confidence}",

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      cleanResult == "not_a_fruit_❌"
                          ? "This is not a fruit"
                          : "Sugar : ${sugarData[cleanResult] ?? '-'}",

                      style: TextStyle(
                        color: sugarValue > 10
                            ? Colors.redAccent
                            : Colors.white,

                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ✅ Camera Button
              customButton(
                title: "Open Camera",
                icon: Icons.camera_alt,
                onTap: () {
                  pickImage(ImageSource.camera);
                },
              ),

              const SizedBox(height: 15),

              // ✅ Gallery Button
              customButton(
                title: "Open Gallery",
                icon: Icons.photo,
                onTap: () {
                  pickImage(ImageSource.gallery);
                },
              ),

              const SizedBox(height: 15),

              // ✅ Analyze Button
              customButton(
                title: isModelLoaded
                    ? "Analyze Fruit"
                    : "Loading Model...",
                icon: Icons.analytics,
                buttonColor: const Color(0xFFFF6B35),
                onTap: isModelLoaded
                    ? runModel
                    : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}