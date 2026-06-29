import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../application/payment_notifier.dart';

/// "Go Premium" bottom sheet — opened reactively when a LISTENER hits a
/// premium-gated item, and proactively from the dashboard.
class PremiumUpgradeSheet extends ConsumerStatefulWidget {
  const PremiumUpgradeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumUpgradeSheet(),
    );
  }

  @override
  ConsumerState<PremiumUpgradeSheet> createState() => _PremiumUpgradeSheetState();
}

class _PremiumUpgradeSheetState extends ConsumerState<PremiumUpgradeSheet> {
  @override
  void initState() {
    super.initState();
    // Always start a freshly-opened sheet from a clean slate, even if a
    // previous attempt in this session ended in failure.
    Future.microtask(() => ref.read(paymentNotifierProvider.notifier).reset());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PaymentState>(paymentNotifierProvider, (previous, next) {
      if (next.status == PaymentStatus.success && previous?.status != PaymentStatus.success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.charcoal,
            content: Text(
              'Welcome to Premium! Enjoy unlimited high-fidelity streaming.',
              style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }
    });

    final state = ref.watch(paymentNotifierProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Icon(Icons.workspace_premium, color: AppColors.gold, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Go Premium',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'One-time upgrade — yours to keep, no recurring charges.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                const _BenefitRow(
                  icon: Icons.high_quality,
                  label: 'Unlimited high-fidelity streaming',
                ),
                const SizedBox(height: 14),
                const _BenefitRow(
                  icon: Icons.lock_open,
                  label: 'Exclusive access to premium audio content',
                ),
                const SizedBox(height: 14),
                const _BenefitRow(
                  icon: Icons.block_flipped,
                  label: 'No more premium-content lockouts',
                ),
                const SizedBox(height: 28),
                Text(
                  '₹${premiumUpgradePriceInr.toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.status == PaymentStatus.failure && state.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: state.isBusy
                      ? null
                      : () => ref.read(paymentNotifierProvider.notifier).startUpgrade(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.charcoal,
                    disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.4),
                  ),
                  child: state.isBusy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.charcoal),
                        )
                      : const Text('Upgrade Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.teal, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.offWhite))),
      ],
    );
  }
}
