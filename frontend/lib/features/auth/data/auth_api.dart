import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import 'models/auth_response_model.dart';
import 'models/otp_challenge_response.dart';
import 'models/signup_request.dart';

/// Thin wrapper over the `/api/auth/**` endpoints. No state lives here —
/// see [AuthNotifier] for the stateful login/OTP flow built on top of this.
class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  Future<AuthResponseModel> signup(SignupRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/signup',
      data: request.toJson(),
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
