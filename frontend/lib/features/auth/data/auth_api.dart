import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/network/dio_client.dart';
import 'models/auth_response_model.dart';
import 'models/otp_challenge_response.dart';
import 'models/signup_request.dart';

/// Thin wrapper over the `/api/auth/**` endpoints. No state lives here —
/// see [AuthNotifier] for the stateful login/OTP flow built on top of this.
class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  // The backend's signup endpoint consumes multipart/form-data (it also
  // accepts an optional profilePicture part, which this form doesn't collect
  // yet), so the JSON body has to travel as a "data" part with an explicit
  // application/json content-type rather than as the request body itself.
  Future<AuthResponseModel> signup(SignupRequest request) async {
    final formData = FormData.fromMap({
      'data': MultipartFile.fromString(
        jsonEncode(request.toJson()),
        contentType: MediaType('application', 'json'),
      ),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/signup',
      data: formData,
    );
    return AuthResponseModel.fromJson(response.data!);
  }

  Future<OtpChallengeResponse> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'identifier': identifier, 'password': password},
    );
    return OtpChallengeResponse.fromJson(response.data!);
  }

  Future<AuthResponseModel> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      data: {'identifier': identifier, 'otp': otp},
    );
    return AuthResponseModel.fromJson(response.data!);
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(dioProvider));
});
