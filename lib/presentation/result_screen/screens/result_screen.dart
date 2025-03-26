import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groq/common/preferences/preference.dart';
import 'package:groq/presentation/home/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String category;

  const ResultScreen(
      {super.key,
      required this.score,
      required this.total,
      required this.category});

  @override
  // ignore: library_private_types_in_public_api
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  //--------------------locally used variables----------------------------------//
  late double percentage;
  bool isSaving = false;

  //--------------------locally used method----------------------------------//

  Future<void> _saveResult() async {
    setState(() => isSaving = true);

    List<String> results = await SharedPrefHelper.getQuizResults();

    // Create a new result object
    Map<String, dynamic> newResult = {
      'category': widget.category,
      'score': widget.score,
      'timestamp':
          DateTime.now().toIso8601String(), // Use ISO format for consistency
    };

    // Add new result at the start (Correctly convert to JSON)
    results.insert(0, json.encode(newResult));

    // Keep only the latest 5 results
    if (results.length > 5) {
      results = results.sublist(0, 5);
    }

    print("Saving Results: $results");
    await SharedPrefHelper.saveQuizResult(results);

    // Check for best score and update if necessary
    int bestScore = await SharedPrefHelper.getBestScore();

    if (widget.score > bestScore) {
      await SharedPrefHelper.saveBestScore(widget.score);
    }

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Result saved successfully! ✅"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  //--------------------init/dispose method----------------------------------//

  @override
  void initState() {
    super.initState();
    percentage = (widget.score / widget.total) * 100;
  }

  //--------------------build method----------------------------------//
  @override
  Widget build(BuildContext context) {
    bool isPassed = percentage >= 50;

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPassed
                ? [Colors.blueAccent, Colors.greenAccent]
                : [Colors.redAccent, Colors.orangeAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              isPassed
                  ? "assets/animations/happy.json"
                  : "assets/animations/sad.json",
              width: 200,
              height: 200,
              repeat: false,
            ),
            const SizedBox(height: 20),
            Text(
              isPassed ? "🎉 Congratulations!" : "😢 Better Luck Next Time!",
              style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "Category: ${widget.category}",
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70),
            ),
            Text(
              "Your Score: ${widget.score} / ${widget.total}",
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70),
            ),
            Text(
              "Percentage: ${percentage.toStringAsFixed(1)}%",
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70),
            ),
            const SizedBox(height: 30),
            saveResultButton(),
            const SizedBox(height: 20),
            goToHomeAndRetryButtonRow(context),
          ],
        ),
      ),
    );
  }

  //--------------------locally used widget----------------------------------//

  ElevatedButton saveResultButton() {
    return ElevatedButton.icon(
      onPressed: isSaving ? null : _saveResult,
      icon: isSaving
          ? const CircularProgressIndicator()
          : const Icon(FontAwesomeIcons.solidSave, size: 18),
      label: Text("Save Result",
          style:
              GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Row goToHomeAndRetryButtonRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const HomeScreen()), // Replace with your home screen widget
              (route) =>
                  false, // This removes all previous routes from the stack
            );
          },
          icon: const Icon(FontAwesomeIcons.arrowLeft),
          label: Text("Go Home", style: GoogleFonts.poppins(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, "retry"),
          icon: const Icon(FontAwesomeIcons.redo),
          label: Text("Retry Quiz", style: GoogleFonts.poppins(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
