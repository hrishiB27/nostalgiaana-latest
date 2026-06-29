import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import 'models/payment_order_response_model.dart';

/// Thin wrapper over `POST /api/payments/create-order`.
///
/// There is deliberately no `verifyPayment()` here: this backend's only
/// payment-confirmation path is `POST /api/payments/webhook`, a public,
/// HMAC-signature-verified endpoint that Razorpay calls server-to-server
/// on `order.paid` — not an endpoint the client posts
/// `razorpay_payment_id`/`razorpay_order_id`/`razorpay_signature` to.
/// [PaymentNotifier] accounts for this by polling `GET /api/user/me`
/// (via `AuthNotifier.refreshProfile`) after Razorpay's client-side
/// success callback, since that's the only way the app can learn the
/// webhook has landed.
class PaymentApi {
  const PaymentApi(this._dio);

  final Dio _dio;

  Future<PaymentOrderResponseModel> createOrder({required double amount, String? currency}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/payments/create-order',
      data: {
        'amount': amount,
        'currency': ?currency,
      },
    );
    return PaymentOrderResponseModel.fromJson(response.data!);
  }
}

final paymentApiProvider = Provider<PaymentApi>((ref) {
  return PaymentApi(ref.watch(dioProvider));
});
