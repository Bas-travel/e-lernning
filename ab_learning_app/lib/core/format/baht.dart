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

/// Exact money for balances and ledgers: `฿0`, `฿1,250`, `฿1,250.50`,
/// `-฿40`. Unlike [formatBaht], zero is a number, never "free".
String formatBahtExact(double amount) {
  final cents = (amount.abs() * 100).round();
  final digits = (cents ~/ 100).toString();
  final whole = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final frac = cents % 100;
  final fraction = frac == 0 ? '' : '.${frac.toString().padLeft(2, '0')}';
  return '${amount < 0 && cents > 0 ? '-' : ''}฿$whole$fraction';
}
