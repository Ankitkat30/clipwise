import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String _quizResultsKey = 'quiz_results';
  static const String _userNameKey = 'user_name';
  static const String _bestScoreKey = 'best_score';

  /// Save quiz result
  static Future<void> saveQuizResult(List<String> results) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_quizResultsKey, results);
  }

  /// Get all saved quiz results
  static Future<List<String>> getQuizResults() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_quizResultsKey) ?? [];
  }

  /// Clear all stored quiz results
  static Future<void> clearQuizResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_quizResultsKey);
  }

  /// Save user name
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  /// Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Save best score
  static Future<void> saveBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, score);
  }

  /// Get best score
  static Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey) ?? 0;
  }

  //for using when clearing the preference ignore this method
  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all data
    print("All SharedPreferences data cleared!");
  }
}
