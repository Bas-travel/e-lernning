/// Demo data for the Profile sub-pages.
/// TODO(api): `GET /wallet`, `GET /wallet/transactions`, `GET /certificates`,
/// `GET /portfolio` (see 05-openapi.yaml).
class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.date,
    required this.amount,
  });

  final String title;
  final String date;

  /// Signed: negative = spent, positive = received.
  final int amount;
}

class CertificateItem {
  const CertificateItem({
    required this.course,
    required this.issued,
    required this.code,
  });

  final String course;
  final String issued;
  final String code;
}

class PortfolioItem {
  const PortfolioItem({
    required this.title,
    required this.summary,
    required this.tags,
  });

  final String title;
  final String summary;
  final List<String> tags;
}

class ProfileSampleData {
  static const walletBalance = 1250;

  static const transactions = <WalletTransaction>[
    WalletTransaction(title: 'เติมเงินผ่าน PromptPay', date: '12 ต.ค. 2026', amount: 2000),
    WalletTransaction(title: 'ซื้อคอร์ส Prompt Engineering', date: '10 ต.ค. 2026', amount: -1490),
    WalletTransaction(title: 'โบนัสเรียนต่อเนื่อง 14 วัน', date: '2 ต.ค. 2026', amount: 100),
    WalletTransaction(title: 'ซื้อคอร์ส SQL Masterclass', date: '28 ก.ย. 2026', amount: -1290),
    WalletTransaction(title: 'เติมเงินผ่านบัตร', date: '27 ก.ย. 2026', amount: 1930),
  ];

  static const certificates = <CertificateItem>[
    CertificateItem(course: 'Go Backend Masterclass', issued: '5 ต.ค. 2026', code: 'AB-GO-20261005'),
    CertificateItem(course: 'SQL Masterclass', issued: '18 ก.ย. 2026', code: 'AB-SQL-20260918'),
    CertificateItem(course: 'Prompt Engineering', issued: '1 ก.ย. 2026', code: 'AB-PE-20260901'),
  ];

  static const portfolio = <PortfolioItem>[
    PortfolioItem(
      title: 'ระบบจองคิวร้านอาหาร',
      summary: 'REST API ด้วย Go + MySQL พร้อม JWT และเอกสาร OpenAPI',
      tags: ['Go', 'MySQL', 'JWT'],
    ),
    PortfolioItem(
      title: 'Dashboard วิเคราะห์ยอดขาย',
      summary: 'สรุปยอดขายรายสัปดาห์ด้วย SQL และ Python',
      tags: ['SQL', 'Python'],
    ),
  ];
}

/// "1,250" style thousands separator without pulling in `intl`.
String formatBaht(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}฿$buffer';
}
