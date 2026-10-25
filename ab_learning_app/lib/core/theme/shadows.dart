import 'package:flutter/material.dart';

class AppShadows {
  /// Desktop login card: `0 10px 40px rgba(79,70,229,.12)`.
  static const authCard = [
    BoxShadow(color: Color(0x1F4F46E5), blurRadius: 40, offset: Offset(0, 10)),
  ];

  /// Interests card: `0 10px 40px rgba(15,23,42,.06)`.
  static const neutralCard = [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 40, offset: Offset(0, 10)),
  ];
}
