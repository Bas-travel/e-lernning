import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/format/baht.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/sub_page_scaffold.dart';
import '../../wallet/data/wallet_repository.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const _topupChoices = <int>[100, 500, 1000];

  WalletSnapshot? _snapshot;
  bool _loading = true;
  bool _failed = false;
  bool _busy = false;

  /// Kept until a top-up succeeds, so a retry after a dropped connection
  /// cannot credit the wallet twice.
  String _topupKey = newWalletIdempotencyKey();

  WalletRepository get _repo => AppDependencies.walletRepository;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final snapshot = await _repo.load();
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } on Object catch (e) {
      debugPrint('wallet failed to load: $e');
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _topup(int baht) async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await _repo.topup(baht, idempotencyKey: _topupKey);
    if (!mounted) return;
    setState(() => _busy = false);
    final messenger = ScaffoldMessenger.of(context);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('เติมเงินไม่สำเร็จ ลองอีกครั้ง')),
      );
      return;
    }
    _topupKey = newWalletIdempotencyKey();
    final label = formatBahtExact(baht.toDouble());
    messenger.showSnackBar(
      SnackBar(content: Text('เติมเงิน $label แล้ว')),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return SubPageScaffold(
      title: 'Wallet',
      children: [
        if (_loading && snapshot == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_failed && snapshot == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Text(
                  'โหลดข้อมูล Wallet ไม่สำเร็จ',
                  style: AppTypography.base(
                    13,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextButton(onPressed: _load, child: const Text('ลองใหม่')),
              ],
            ),
          )
        else if (snapshot != null) ...[
          _BalanceCard(balance: snapshot.balance),
          if (!_repo.bundledOnly) ...[
            const SectionLabel('เติมเงินทดสอบ (Sandbox)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final baht in _topupChoices)
                  AppButton.secondary(
                    label: '+${formatBahtExact(baht.toDouble())}',
                    loading: _busy,
                    onPressed: _busy ? null : () => _topup(baht),
                  ),
              ],
            ),
          ],
          const SectionLabel('รายการล่าสุด'),
          if (snapshot.entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'ยังไม่มีรายการ',
                style: AppTypography.base(13, color: AppColors.textSecondary),
              ),
            ),
          for (final t in snapshot.entries) ...[
            _EntryRow(entry: t),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppGradients.brand,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ยอดคงเหลือ',
            style: AppTypography.base(12, color: AppColors.whiteA85),
          ),
          const SizedBox(height: 4),
          Text(
            formatBahtExact(balance),
            style: AppTypography.base(
              28,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final WalletEntry entry;

  @override
  Widget build(BuildContext context) {
    final positive = entry.amount > 0;
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: AppTypography.base(13, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.date,
                  style: AppTypography.base(
                    11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${positive ? '+' : ''}${formatBahtExact(entry.amount)}',
            style: AppTypography.base(
              13,
              weight: FontWeight.w700,
              color: positive ? AppColors.pillSuccessFg : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
