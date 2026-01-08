import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// カスタムカラーを定義
class CustomColors {

  /// バックグラウンドカラー
  static Color background(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? Colors.black : Colors.white;
  }

  /// テキストカラー
  static Color text(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? Colors.white : const Color(0xFF333333);
  }

  /// テーマ(ベース)カラー
  static const Color thema = Color(0xFF276bb1);

  /// ファンデーションカラー
  static Color foundation(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? const Color(0xFF3333333) : const Color(0xFFF2F2F7);
  }

  /// ネガティブ
  static const Color negative = Color(0xFFB12729);

  /// =============== テーマカラー =====================

  /// 青
  static const Color themaBlue = Color(0xFF276bb1);

  /// 緑
  static const Color themaGreen = Color(0xFF26b19a);

  /// 紫
  static const Color themaPurple = Color(0xFF8526b1);

  /// 黄色
  static const Color themaYellow = Color(0xFFb1ab26);

  /// オレンジ
  static const Color themaOrange = Color(0xFFb16926);

  /// 黒
  static const Color themaBlack = Color(0xFF333333);

  /// 灰色
  static const Color themaGray = Color(0xFF90a2aa);
}
