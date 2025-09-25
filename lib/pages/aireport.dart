import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AiAnalyticsPage extends StatefulWidget {
  const AiAnalyticsPage({super.key});

  @override
  State<AiAnalyticsPage> createState() => _AiAnalyticsPageState();
}

class _AiAnalyticsPageState extends State<AiAnalyticsPage> {
  File? _image;
  Uint8List? _imageBytes; // For web
  bool _isLoading = false;
  Map<String, dynamic>? _aiResult;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _isLoading = true;
        });
        await _analyzeImageWeb(bytes);
      } else {
        setState(() {
          _image = File(pickedFile.path);
          _isLoading = true;
        });
        await _analyzeImage(_image!);
      }
    }
  }

  /// Dummy AI analysis for web
  Future<void> _analyzeImageWeb(Uint8List bytes) async {
    await Future.delayed(const Duration(seconds: 2));
    _loadDummyResult();
  }

  /// Dummy AI analysis for mobile
  Future<void> _analyzeImage(File image) async {
    await Future.delayed(const Duration(seconds: 2));
    _loadDummyResult();
  }

  /// Dummy Result with more data
  void _loadDummyResult() {
    final result = {
      "quality_score": 78,
      "defects": [
        {"type": "Scratch", "count": 3},
        {"type": "Dent", "count": 1},
        {"type": "Discoloration", "count": 2},
      ],
      "recommendation": "Replace damaged components and repaint",
      "inspection_history": [
        {"date": "2025-09-01", "status": "Passed", "remarks": "Minor scratches"},
        {"date": "2025-07-15", "status": "Failed", "remarks": "Dent detected"},
        {"date": "2025-05-20", "status": "Passed", "remarks": "No issues"},
      ],
      "reviews": [
        {"user": "Engineer A", "rating": 4, "comment": "Good overall"},
        {"user": "Inspector B", "rating": 3, "comment": "Needs repainting"},
      ],
      "strengths": {
        "tensile": 80,
        "compressive": 65,
        "fatigue": 55,
        "hardness": 70
      },
      "risk_level": "Medium"
    };

    setState(() {
      _aiResult = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Analytics"),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : _aiResult != null
                    ? _buildAiResult()
                    : const Text("Upload an image to see analysis"),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    Widget imageWidget;

    if (kIsWeb) {
      imageWidget = _imageBytes == null
          ? const Icon(Icons.add_a_photo, size: 50)
          : Image.memory(_imageBytes!, height: 180, fit: BoxFit.cover);
    } else {
      imageWidget = _image == null
          ? const Icon(Icons.add_a_photo, size: 50)
          : Image.file(_image!, height: 180, fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey[300],
        child: Center(child: imageWidget),
      ),
    );
  }

  Widget _buildAiResult() {
    final defects = _aiResult!["defects"] as List<dynamic>;
    final score = _aiResult!["quality_score"];
    final inspections = _aiResult!["inspection_history"] as List<dynamic>;
    final reviews = _aiResult!["reviews"] as List<dynamic>;
    final strengths = _aiResult!["strengths"] as Map<String, dynamic>;
    final riskLevel = _aiResult!["risk_level"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQualityScore(score),
        const SizedBox(height: 16),
        _buildDefectsChart(defects),
        const SizedBox(height: 16),
        _buildStrengthsChart(strengths),
        const SizedBox(height: 16),
        _buildInspectionHistory(inspections),
        const SizedBox(height: 16),
        _buildReviews(reviews),
        const SizedBox(height: 16),
        _buildRecommendation(riskLevel),
      ],
    );
  }

  Widget _buildQualityScore(int score) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Quality Score",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: score / 100,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              color: score >= 80
                  ? Colors.green
                  : score >= 50
                      ? Colors.orange
                      : Colors.red,
            ),
            const SizedBox(height: 8),
            Text("$score / 100",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildDefectsChart(List defects) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Defects",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: 5,
                  barGroups: defects.asMap().entries.map((entry) {
                    final index = entry.key;
                    final defect = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: defect["count"].toDouble(),
                          color: Colors.red,
                          width: 20,
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= defects.length) {
                            return const Text('');
                          }
                          return Text(defects[index]["type"]);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 1),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthsChart(Map<String, dynamic> strengths) {
    final entries = strengths.entries.toList();
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Material Strengths",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: 100,
                  barGroups: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final e = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.toDouble(),
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= entries.length) {
                            return const Text('');
                          }
                          return Text(entries[index].key);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionHistory(List inspections) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Inspection History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...inspections.map((ins) {
              return ListTile(
                leading: Icon(
                  ins["status"] == "Passed"
                      ? Icons.check_circle
                      : Icons.error,
                  color:
                      ins["status"] == "Passed" ? Colors.green : Colors.red,
                ),
                title: Text(ins["date"]),
                subtitle: Text(ins["remarks"]),
                trailing: Text(ins["status"]),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviews(List reviews) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...reviews.map((rev) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(rev["user"]),
                subtitle: Text(rev["comment"]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rev["rating"]
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation(String riskLevel) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("AI Recommendation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_aiResult!["recommendation"]),
            const SizedBox(height: 12),
            Text("Risk Level: $riskLevel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: riskLevel == "High"
                      ? Colors.red
                      : riskLevel == "Medium"
                          ? Colors.orange
                          : Colors.green,
                )),
          ],
        ),
      ),
    );
  }
}
