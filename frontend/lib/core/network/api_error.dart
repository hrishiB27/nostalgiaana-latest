import 'package:dio/dio.dart';

// The backend's GlobalExceptionHandler wraps every business-rule failure
// (bad password, wrong OTP, etc.) as {"error": "<message>", ...} with a 400.
String messageFor(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
  }
  return 'Something went wrong. Please try again.';
}
