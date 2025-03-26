import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groq/common/functions/functions.dart';
import 'package:groq/common/preferences/preference.dart';
import 'package:groq/constants/constants.dart';
import 'package:groq/presentation/quiz/data/models/question_model.dart';
import 'package:groq/presentation/quiz/data/repository/quiz_repository.dart';
import 'package:groq/presentation/quiz/screens/quiz_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //--------------------locally used variable ---------------------------------//
  final QuizRepository _quizRepository = QuizRepository();
  late Future<void> _userDataFuture;
  String _userName = "Guest";
  int _bestScore = 0;
  bool _isFetchingQuestions = false;
  List<Map<String, dynamic>> recentScores = [];

  //--------------------locally used  methods----------------------------------//

  Future<void> _loadRecentScores() async {
    List<String>? storedResults = await SharedPrefHelper.getQuizResults();

    print("Stored Results in SharedPreferences: $storedResults");

    if (storedResults.isNotEmpty) {
      setState(() {
        recentScores = storedResults
            .map((e) {
              try {
                return Map<String, dynamic>.from(json.decode(e));
              } catch (error) {
                print("JSON Decode Error: $error for data: $e");
                return <String, dynamic>{}; // Skip invalid entries
              }
            })
            .where((element) => element.isNotEmpty)
            .toList();
      });

      print("Recent Scores List: $recentScores");
    }
  }

  // loading user name and score
  Future<void> _loadUserData() async {
    String name = await SharedPrefHelper.getUserName() ?? "Guest";
    int bestScore = await SharedPrefHelper.getBestScore();
    setState(() {
      _userName = name;
      _bestScore = bestScore;
    });
  }

//start quiz function for every category
  void _startQuiz(String category, String level) async {
    setState(() {
      _isFetchingQuestions = true;
    });

    try {
      List<Question> questions =
          await _quizRepository.fetchQuestion(category, level);
      if (questions.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              questions: questions,
              category: category,
            ),
          ),
        );
      } else {
        _showSnackbar("No questions found for this category!");
      }
    } catch (e) {
      _showSnackbar("Error fetching questions: $e");
    } finally {
      setState(() {
        _isFetchingQuestions = false;
      });
    }
  }

//snackbar to show snackbar
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  //--------------------init/dispose method----------------------------------//
  @override
  void initState() {
    super.initState();

    _userDataFuture = _loadUserData();
    _loadRecentScores();
  }

  //--------------------build method----------------------------------//
  @override
  Widget build(BuildContext context) {
    print("here $recentScores");
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello, $_userName 👋",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 5),
                const Text("Ready to test your knowledge?",
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoader();
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    "Failed to load data. Please try again!",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _userDataFuture = _loadUserData();
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isFetchingQuestions
                ? _buildShimmerLoader()
                : Constants.categories.isEmpty
                    ? _buildEmptyCategories()
                    : _buildMainContent(Constants.categories),
          );
        },
      ),
    );
  }

  //--------------------locally used widgets----------------------------------//

  Widget _buildEmptyCategories() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            "No categories available.",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildMainContent(List<Map<String, dynamic>> categories) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Best Score Card
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
            color: Colors.deepPurple,
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("🏆 Best Score",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text("$_bestScore",
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          /// Category Selection
          const Text("Select a category to start quiz",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          /// Category Grid
          GridView.builder(
            shrinkWrap: true, // Ensures GridView doesn't take unlimited height
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _showDifficultyDialog(context, categories[index]["title"]!);
                },
                // onTap: () => _startQuiz(categories[index]["title"]!),
                child: Container(
                  decoration: BoxDecoration(
                    color: categories[index]["color"],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(categories[index]["icon"],
                          size: 50, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        categories[index]["title"]!,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          _buildRecentScores(),
        ],
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose Difficulty",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                _buildDifficultyOption(context, "Easy", Colors.green,
                    Icons.emoji_emotions, category),
                _buildDifficultyOption(context, "Medium", Colors.orange,
                    Icons.trending_up, category),
                _buildDifficultyOption(context, "Hard", Colors.red,
                    Icons.local_fire_department, category),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifficultyOption(BuildContext context, String level, Color color,
      IconData icon, String category) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _startQuiz(category, level);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Text(
              level,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  /// Improved Recent Scores List
  Widget _buildRecentScores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📋 Recent Scores",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        recentScores.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sentiment_dissatisfied,
                        size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "No recent scores yet!",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentScores.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> scoreData = recentScores[index];
                  int score = scoreData["score"] ?? 0; // Get score from map
                  String category =
                      scoreData["category"] ?? "Unknown"; // Get category
                  String time = CommonFunction.formatDate(
                      scoreData["timestamp"]); // Get time

                  Color cardColor = score >= 80
                      ? Colors.green.shade300
                      : score >= 50
                          ? Colors.orange.shade300
                          : Colors.red.shade300;

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      leading: CircleAvatar(
                        backgroundColor: cardColor,
                        child:
                            const Icon(Icons.emoji_events, color: Colors.white),
                      ),
                      title: Text(
                        "Score: $score",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Category: $category | Time: $time"),
                    ),
                  );
                },
              ),
      ],
    );
  }

  /// Build shimmer loader when fetching data
  Widget _buildShimmerLoader() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.deepPurple.shade300,
        highlightColor: Colors.deepPurple.shade100,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 60, color: Colors.white),
            SizedBox(height: 12),
            Text(
              "Loading...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
