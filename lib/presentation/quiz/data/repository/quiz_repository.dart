import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:groq/core/api.dart';
import 'package:groq/presentation/quiz/data/models/question_model.dart';

class QuizRepository {
  final _api = Api();

  Future<List<Question>> fetchQuestion(String category, String level) async {
    try {
      Response response = await _api.sendRequest.post(
        "/chat/completions",
        data: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "user",
              "content":
                  "Generate 5 multiple-choice questions on $category of $level. Each should have a question, 4 options, and the correct answer clearly marked. Return only valid JSON."
            }
          ],
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;

        // Extract JSON string from content
        String content = jsonData["choices"][0]["message"]["content"];
        content =
            content.replaceAll("```json", "").replaceAll("```", "").trim();

        // Parse JSON
        final quizData = json.decode(content);

        // Convert to List<Question>
        List<Question> questions = (quizData['questions'] as List)
            .map((q) => Question.fromJson(q))
            .toList();

        return questions;
      } else {
        throw "Failed to fetch questions. Status code: ${response.statusCode}";
      }
    } on DioException catch (ex) {
      if (ex.response != null) {
        throw "API Error: ${ex.response!.statusMessage}";
      } else {
        throw "Network error occurred while processing the request.";
      }
    } catch (ex) {
      throw "An unexpected error occurred: $ex";
    }
  }
}
