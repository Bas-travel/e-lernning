import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/format/baht.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/typography.dart';
import '../../../data/mock/mock_repository.dart';
import '../../../data/mock/models.dart';
import '../../catalog/data/catalog_models.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../checkout/data/orders_repository.dart';

enum _PaymentMethod { promptPay, card, mobileBanking, abWallet }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.courseId, this.courseTitle});

  final String courseId;
  final String? courseTitle;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  _PaymentMethod _selectedMethod = _PaymentMethod.promptPay;
  bool _isProcessing = false;

  /// Server course for a numeric id; null means the bundled demo flow.
  CatalogCourse? _apiCourse;
  bool _loadingCourse = false;

  /// Reused by every tap of "pay", so a retry never creates a second order.
  final String _idempotencyKey = _newIdempotencyKey();

  static String _newIdempotencyKey() {
    final r = Random.secure();
    final hex = List.generate(16, (_) => r.nextInt(16).toRadixString(16));
    return 'app-${hex.join()}';
  }

  @override
  void initState() {
    super.initState();
    final catalog = AppDependencies.catalogRepository;
    if (!catalog.bundledOnly &&
        ApiCatalogRepository.numericId(widget.courseId) != null) {
      _loadingCourse = true;
      _loadCourse(catalog);
    }
  }

  Future<void> _loadCourse(CatalogRepository catalog) async {
    final course = await catalog.course(widget.courseId);
    if (!mounted) return;
    setState(() {
      _apiCourse = course;
      _loadingCourse = false;
    });
  }

  /// The server only supports PromptPay and card; the other tiles belong to
  /// the demo flow.
  List<_MethodDetails> get _availableMethods => _apiCourse == null
      ? _methods
      : [
          for (final m in _methods)
            if (m.method == _PaymentMethod.promptPay ||
                m.method == _PaymentMethod.card)
              m,
        ];

  static const _methods = [
    _MethodDetails(
      method: _PaymentMethod.promptPay,
      title: 'พร้อมเพย์',
      subtitle: 'สแกน QR ผ่านแอปธนาคาร',
      icon: Icons.qr_code_2,
      tag: 'แนะนำ',
    ),
    _MethodDetails(
      method: _PaymentMethod.card,
      title: 'บัตรเครดิต / เดบิต',
      subtitle: 'Visa, Mastercard และ JCB',
      icon: Icons.credit_card_outlined,
    ),
    _MethodDetails(
      method: _PaymentMethod.mobileBanking,
      title: 'โมบายแบงก์กิ้ง',
      subtitle: 'เชื่อมต่อแอปธนาคารของคุณ',
      icon: Icons.account_balance_outlined,
    ),
    _MethodDetails(
      method: _PaymentMethod.abWallet,
      title: 'AB Wallet',
      subtitle: 'ชำระด้วยยอดเงินในกระเป๋า',
      icon: Icons.account_balance_wallet_outlined,
    ),
  ];

  String get _selectedMethodLabel =>
      _methods.firstWhere((item) => item.method == _selectedMethod).title;

  /// What the order summary and the pay button show, from either source.
  _Summary _summary(Course course, String title) {
    final api = _apiCourse;
    if (api == null) {
      return _Summary(
        title: title,
        instructor: course.instructor,
        priceLabel: course.priceLabel,
        originalPriceLabel: course.originalPriceLabel,
        colorHex: course.coverColorHex,
      );
    }
    final discounted =
        api.discountPrice != null && api.discountPrice! < api.price;
    return _Summary(
      title: widget.courseTitle ?? api.title,
      instructor: api.instructorName,
      priceLabel: formatBaht(api.effectivePrice),
      originalPriceLabel: discounted ? formatBaht(api.price) : null,
      colorHex: '4F46E5',
    );
  }

  /// Real purchase through the API (sandbox gateway).
  Future<void> _payWithApi(CatalogCourse api) async {
    setState(() => _isProcessing = true);
    final result = await AppDependencies.ordersRepository.payForCourse(
      api.id,
      method: _selectedMethod == _PaymentMethod.card ? 'card' : 'promptpay',
      idempotencyKey: _idempotencyKey,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    final order = result.order;
    if (order == null) {
      final message = switch (result.failure) {
        CheckoutFailure.alreadyOwned => 'คุณมีคอร์สนี้อยู่แล้ว',
        CheckoutFailure.unavailable => 'ไม่สามารถซื้อคอร์สนี้ได้ในขณะนี้',
        _ => 'ชำระเงินไม่สำเร็จ กรุณาลองใหม่อีกครั้ง',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      if (result.failure == CheckoutFailure.alreadyOwned) {
        context.go('/course/${api.id}/curriculum');
      }
      return;
    }
    await _showSuccess(api.title, order.code);
  }

  Future<void> _pay(Course course) async {
    final api = _apiCourse;
    if (api != null) {
      await _payWithApi(api);
      return;
    }
    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _isProcessing = false);

    MockRepository.enrollInCourse(course.id);
    await _showSuccess(
      course.title,
      'AB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      demo: true,
    );
  }

  Future<void> _showSuccess(
    String courseTitle,
    String orderCode, {
    bool demo = false,
  }) async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon:
            const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('ชำระเงินสำเร็จ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ลงทะเบียน $courseTitle เรียบร้อยแล้ว'),
            const SizedBox(height: 12),
            Text('ช่องทาง: $_selectedMethodLabel',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('เลขที่คำสั่งซื้อ: $orderCode',
                style: AppTypography.micro
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            const Text(
                'รายการนี้เป็นการชำระเงินตัวอย่าง ยังไม่มีการตัดเงินจริง',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('เริ่มเรียนเลย'),
            ),
          ),
        ],
      ),
    );
    if (shouldContinue == true && mounted) {
      context.go('/course/${widget.courseId}/curriculum');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingCourse) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final Course course = MockRepository.courseById(widget.courseId);
    final String title = widget.courseTitle ?? course.title;
    final summary = _summary(course, title);
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ชำระเงิน'),
        leading: IconButton(
          tooltip: 'กลับ',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('เลือกวิธีชำระเงิน',
                    style:
                        AppTypography.h1.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('ชำระเงินอย่างปลอดภัยเพื่อเริ่มเรียนได้ทันที',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 22),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildPaymentMethods()),
                      const SizedBox(width: 20),
                      SizedBox(
                          width: 330, child: _buildOrderSummary(summary)),
                    ],
                  )
                else ...[
                  _buildOrderSummary(summary),
                  const SizedBox(height: 24),
                  _buildPaymentMethods(),
                ],
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: Color(0xFF92400E)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'โหมดตัวอย่าง: ระบบจะแสดงผลการชำระสำเร็จและลงทะเบียนให้ แต่จะไม่มีการตัดเงินจริง',
                          style: TextStyle(
                              color: Color(0xFF78350F),
                              fontSize: 12,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.cardBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : () => _pay(course),
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.lock_outline),
                  label: Text(_isProcessing
                      ? 'กำลังดำเนินการ...'
                      : 'ชำระเงิน ${summary.priceLabel}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              const Text('🔒 ข้อมูลการชำระเงินได้รับการปกป้อง',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ช่องทางการชำระเงิน', style: AppTypography.h2),
        const SizedBox(height: 10),
        for (final details in _availableMethods) ...[
          _PaymentMethodTile(
            details: details,
            selected: _selectedMethod == details.method,
            onTap: () => setState(() => _selectedMethod = details.method),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildOrderSummary(_Summary summary) {
    final currentPrice = _priceValue(summary.priceLabel);
    final originalPrice = summary.originalPriceLabel == null
        ? null
        : _priceValue(summary.originalPriceLabel!);
    final savings = originalPrice == null ? 0 : originalPrice - currentPrice;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('สรุปรายการ', style: AppTypography.h2),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color:
                      Color(int.parse('FF${summary.colorHex}', radix: 16))
                          .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Icon(Icons.school_outlined,
                    color: Color(
                        int.parse('FF${summary.colorHex}', radix: 16))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(summary.instructor,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          _SummaryRow(
            label: 'ราคาคอร์ส',
            value: summary.originalPriceLabel ?? summary.priceLabel,
            valueColor: summary.originalPriceLabel == null
                ? null
                : AppColors.textSecondary,
          ),
          if (savings > 0) ...[
            const SizedBox(height: 10),
            _SummaryRow(
                label: 'ส่วนลด',
                value: '- ฿${_formatNumber(savings)}',
                valueColor: AppColors.success),
          ],
          const Divider(height: 24),
          _SummaryRow(
              label: 'ยอดชำระทั้งหมด',
              value: summary.priceLabel,
              emphasize: true),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.all_inclusive, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Expanded(
                  child: Text('เรียนได้ตลอดชีพ',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }

  int _priceValue(String value) =>
      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  String _formatNumber(int value) => value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
}

class _Summary {
  const _Summary({
    required this.title,
    required this.instructor,
    required this.priceLabel,
    required this.originalPriceLabel,
    required this.colorHex,
  });

  final String title;
  final String instructor;
  final String priceLabel;
  final String? originalPriceLabel;
  final String colorHex;
}

class _MethodDetails {
  const _MethodDetails({
    required this.method,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.tag,
  });

  final _PaymentMethod method;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? tag;
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile(
      {required this.details, required this.selected, required this.onTap});

  final _MethodDetails details;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          selected ? AppColors.primary.withValues(alpha: 0.045) : Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.cardBorder,
                width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Icon(details.icon,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                            child: Text(details.title,
                                style: AppTypography.body
                                    .copyWith(fontWeight: FontWeight.w600))),
                        if (details.tag != null) ...[
                          const SizedBox(width: 8),
                          Text(details.tag!,
                              style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(details.subtitle,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400)),
        Text(value,
            style: AppTypography.body.copyWith(
                color: valueColor ??
                    (emphasize ? AppColors.primary : AppColors.text),
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
