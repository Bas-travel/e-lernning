/// Formats a Thai-baht amount for display: `฿2,990`, or `ฟรี` when there is
/// nothing to pay (or no price at all).
String formatBaht(double? amount) {
  if (amount == null || amount <= 0) return 'ฟรี';
  final digits = amount.round().toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '฿$grouped';
}
