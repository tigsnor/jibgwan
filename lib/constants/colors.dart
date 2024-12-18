// lib/constants/colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // 주요 색상
  static const Color primary = Color(0xFF2980B9); // 메인 파란색
  static const Color secondary = Color(0xFF1ABC9C); // 보조 초록색
  static const Color accent = Color(0xFFE74C3C); // 강조 빨간색

  // 배경 색상
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // 텍스트 색상
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);

  // 상태 색상
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF1C40F);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // 구분선 색상
  static const Color divider = Color(0xFFECF0F1);

  // 그림자 색상
  static const Color shadow = Color(0x1A000000);

  // 버튼 색상
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = Color(0xFFBDC3C7);

  // 입력 필드 색상
  static const Color inputBackground = Color(0xFFF5F6FA);
  static const Color inputBorder = Color(0xFFBDC3C7);
  static const Color inputFocused = primary;

  // 상태바 색상
  static const Color statusBarColor = primary;

  // 바텀 네비게이션 바 색상
  static const Color bottomNavBackground = Color(0xFFFFFFFF);
  static const Color bottomNavSelected = primary;
  static const Color bottomNavUnselected = Color(0xFF95A5A6);

  // 앱바 색상
  static const Color appBarBackground = Color(0xFFFFFFFF);
  static const Color appBarForeground = textPrimary;

  // 탭바 색상
  static const Color tabBarSelected = primary;
  static const Color tabBarUnselected = Color(0xFF95A5A6);
  static const Color tabBarBackground = Color(0xFFFFFFFF);

  // 스낵바 색상
  static const Color snackBarBackground = Color(0xFF323232);
  static const Color snackBarText = Color(0xFFFFFFFF);

  // 다이얼로그 색상
  static const Color dialogBackground = Color(0xFFFFFFFF);
  static const Color dialogShadow = shadow;

  // 캘린더 색상
  static const Color calendarToday = primary;
  static const Color calendarSelected = secondary;
  static const Color calendarWeekend = accent;
}
