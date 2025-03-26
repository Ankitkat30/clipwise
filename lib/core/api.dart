import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// API Class
class Api {
  final Dio _dio = Dio();

  static const baseUrl = "https://api.groq.com/openai";
  static const accessToken = "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";

  final Map<String, dynamic> headers = {
    "Content-type": "application/json",
    "Authorization": "Bearer $accessToken"
  };

  Api() {
    _dio.options.baseUrl = "$baseUrl/v1";
    _dio.options.headers = headers;
    _dio.interceptors.add(PrettyDioLogger(requestBody: true));
    _dio.interceptors.add(RetryInterceptor(dio: _dio, retries: 3, retryDelays: [
      const Duration(seconds: 1),
      const Duration(seconds: 2),
      const Duration(seconds: 3)
    ]));
  }

  Dio get sendRequest => _dio;
}

// API Response Model
class ApiResponse {
  bool success;
  Object? data;
  String message;

  ApiResponse({required this.success, this.data, required this.message});

  /// Parse API response for questions
  factory ApiResponse.fromResponse(Response response) {
    try {
      // Extract the "content" field inside "choices"
      final String content = response.data["choices"][0]["message"]["content"];
      
      // Parse JSON string into a Dart object
      final Map<String, dynamic> jsonData = json.decode(content);

      return ApiResponse(
        success: true,
        data: jsonData, // Contains the parsed questions
        message: "Success",
      );
    } catch (e) {
      return ApiResponse(success: false, message: "Parsing Error: $e");
    }
  }
}

