import 'dart:async';
import 'package:flutter/material.dart';
import 'package:groq/presentation/quiz/data/models/question_model.dart';
import 'package:groq/presentation/result_screen/screens/result_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String category;
  const QuizScreen(
      {super.key, required this.questions, required this.category});

  @override
  // ignore: library_private_types_in_public_api
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  //--------------------locally used variables----------------------------------//
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool? _isCorrect;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;
  int _remainingTime = 30; // Timer starts at 30 seconds

  //--------------------init/dispose method----------------------------------//

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _startTimer();
    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cleanup timer
    _animationController.dispose();
    super.dispose();
  }

  //--------------------locally used method----------------------------------//

  void _startTimer() {
    _timer?.cancel(); // Cancel previous timer if any
    setState(() => _remainingTime = 30);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _timer?.cancel();
        _moveToNextQuestion(); // Move to next if time runs out
      }
    });
  }

  void _checkAnswer(String selectedAnswer) {
    setState(() {
      _selectedAnswer = selectedAnswer;
      _isCorrect =
          selectedAnswer == widget.questions[_currentIndex].correctAnswer;
      if (_isCorrect!) _score++;
      _timer?.cancel(); // Stop the timer once answered
    });
  }

  void _moveToNextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _animationController.reset();
        _currentIndex++;
        _selectedAnswer = null;
        _isCorrect = null;
        _startTimer(); // Restart timer for next question
        _animationController.forward();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: _score,
            total: widget.questions.length,
            category: widget.category,
          ),
        ),
      );
    }
  }

  //--------------------build method----------------------------------//
  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz",
            style:
                GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: bodyWidget(question),
    );
  }

  //--------------------locally used widget--------------------------------//

  Padding bodyWidget(Question question) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Progress Bar & Timer
            progressBarTimerWidget(),
            const SizedBox(height: 20),

            // Question Card with Animation
            questionCardWidget(question),
            const SizedBox(height: 20),

            // Answer Options
            ...question.options.map((option) {
              bool isSelected = option == _selectedAnswer;
              bool isCorrectAnswer = option == question.correctAnswer;

              return answerOptionWidget(option, isSelected, isCorrectAnswer);
            }),

            if (_selectedAnswer != null) ...[
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _isCorrect!
                      ? "🎉 Correct Answer!"
                      : "❌ Wrong! Correct: ${question.correctAnswer}",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isCorrect! ? Colors.green : Colors.red),
                ),
              ),
              const SizedBox(height: 20),

              // Next Button
              Center(
                child: ElevatedButton(
                  onPressed: _moveToNextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentIndex == widget.questions.length - 1
                        ? "View Result"
                        : "Next Question",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  GestureDetector answerOptionWidget(
      String option, bool isSelected, bool isCorrectAnswer) {
    return GestureDetector(
      onTap: _selectedAnswer == null ? () => _checkAnswer(option) : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _selectedAnswer == null
              ? Colors.white
              : isSelected
                  ? (_isCorrect! ? Colors.green.shade400 : Colors.red.shade400)
                  : isCorrectAnswer
                      ? Colors.green.shade400
                      : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color:
                    _isCorrect! ? Colors.green.shade300 : Colors.red.shade300,
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
          border: Border.all(
            color: isSelected
                ? (_isCorrect! ? Colors.green : Colors.red)
                : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? (_isCorrect!
                      ? FontAwesomeIcons.check
                      : FontAwesomeIcons.times)
                  : FontAwesomeIcons.circle,
              color: isSelected
                  ? (_isCorrect! ? Colors.white : Colors.white)
                  : Colors.grey.shade600,
              size: 18,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SlideTransition questionCardWidget(Question question) {
    return SlideTransition(
      position: _slideAnimation,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Question ${_currentIndex + 1} of ${widget.questions.length}",
                style:
                    GoogleFonts.poppins(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 10),
              Text(
                question.question,
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row progressBarTimerWidget() {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.questions.length,
            backgroundColor: Colors.grey[300],
            color: Colors.blueAccent,
            minHeight: 8,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 10),
        // Timer UI
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _remainingTime <= 10 ? Colors.redAccent : Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          child: Text(
            "$_remainingTime",
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
