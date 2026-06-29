/// Response body of `POST /api/payments/create-order`
/// (`CreateOrderResponse` on the backend). `keyId` is Razorpay's public
/// key — safe to use client-side — and is read from here rather than
/// duplicated as a hardcoded constant in the app, so frontend and backend
/// can never end up pointing at different Razorpay accounts/modes.
class PaymentOrderResponseModel {
  const PaymentOrderResponseModel({
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  final String razorpayOrderId;
  final double amount;
  final String currency;
  final String keyId;

  factory PaymentOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderResponseModel(
      razorpayOrderId: json['razorpayOrderId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      keyId: json['keyId'] as String,
    );
  }
}
