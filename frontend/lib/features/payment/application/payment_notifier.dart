import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/network/api_error.dart';
import '../../auth/application/auth_notifier.dart';
import '../../auth/data/models/user_role.dart';
import '../data/payment_api.dart';

/// One-time Premium upgrade price. There's no "plans" concept on the
/// backend — `CreateOrderRequest.amount` is fully caller-supplied — so this
/// is purely a frontend constant, shared between what's displayed and what
/// gets charged so they can't drift apart.
const double premiumUpgradePriceInr = 299;

enum PaymentStatus { idle, creatingOrder, awaitingCheckout, verifying, success, failure }

class PaymentState {
  const PaymentState({this.status = PaymentStatus.idle, this.errorMessage});

  final PaymentStatus status;
  final String? errorMessage;

  bool get isBusy =>
      status == PaymentStatus.creatingOrder ||
      status == PaymentStatus.awaitingCheckout ||
      status == PaymentStatus.verifying;

  PaymentState copyWith({PaymentStatus? status, String? errorMessage}) {
    return PaymentState(
      status: status ?? this.status,
      // Not chained with `??`: a fresh attempt should clear any stale error.
      errorMessage: errorMessage,
    );
  }
}

/// Drives the Premium upgrade flow. Razorpay's checkout only ever tells the
/// client "the user completed checkout" — actual confirmation happens when
/// Razorpay calls the backend's `/api/payments/webhook` server-to-server,
/// which is what actually flips `User.role` to PREMIUM. So after
/// [Razorpay.EVENT_PAYMENT_SUCCESS], this polls `GET /api/user/me` (via
/// [AuthNotifier.refreshProfile]) for a few seconds rather than trusting
/// the client-side event alone.
class PaymentNotifier extends Notifier<PaymentState> {
  late final Razorpay _razorpay;

  @override
  PaymentState build() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    ref.onDispose(_razorpay.clear);
    return const PaymentState();
  }

  Future<void> startUpgrade() async {
    state = state.copyWith(status: PaymentStatus.creatingOrder);
    try {
      final order = await ref
          .read(paymentApiProvider)
          .createOrder(amount: premiumUpgradePriceInr, currency: 'INR');
      final user = ref.read(authNotifierProvider).user;

      state = state.copyWith(status: PaymentStatus.awaitingCheckout);
      _razorpay.open({
        'key': order.keyId,
        'order_id': order.razorpayOrderId,
        'amount': (order.amount * 100).round(),
        'currency': order.currency,
        'name': 'Nostalgiaana',
        'description': 'Premium upgrade',
        if (user?.email != null) 'prefill': {'email': user!.email},
      });
    } catch (error) {
      state = state.copyWith(status: PaymentStatus.failure, errorMessage: messageFor(error));
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    state = state.copyWith(status: PaymentStatus.verifying);

    const maxAttempts = 6;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(const Duration(seconds: 1));
      await ref.read(authNotifierProvider.notifier).refreshProfile();
      if (ref.read(authNotifierProvider).user?.role == UserRole.premium) {
        state = state.copyWith(status: PaymentStatus.success);
        return;
      }
    }

    state = state.copyWith(
      status: PaymentStatus.failure,
      errorMessage:
          'Payment received — it can take a moment to confirm. Pull to refresh shortly if Premium doesn\'t '
          'unlock automatically.',
    );
  }

  void _onPaymentError(PaymentFailureResponse response) {
    state = state.copyWith(
      status: PaymentStatus.failure,
      errorMessage: response.message ?? 'Payment failed.',
    );
  }

  // Selecting an external wallet just redirects into that wallet's app —
  // the actual outcome still arrives via EVENT_PAYMENT_SUCCESS/ERROR
  // afterward, so this is informational only, not a terminal state.
  void _onExternalWallet(ExternalWalletResponse response) {}

  void reset() {
    state = const PaymentState();
  }
}

final paymentNotifierProvider = NotifierProvider<PaymentNotifier, PaymentState>(
  PaymentNotifier.new,
);
