// フォントサイズのサイズを管理するEnum
import 'package:flutter/material.dart';
import 'package:salary/utilities/custom_colors.dart';

enum ThemaColor {
  red(CustomColors.negative, 0, 'クリムゾンレッド'),
  blue(CustomColors.thema, 1, 'オーシャンブルー'),
  green(CustomColors.themaGreen, 2, 'エメラルドグリーン'),
  purple(CustomColors.themaPurple, 3, 'ロイヤルパープル'),
  yellow(CustomColors.themaYellow, 4, 'サンフラワーイエロー'),
  orange(CustomColors.themaOrange, 5, 'タンジェリンオレンジ'),
  black(CustomColors.themaBlack, 6, 'チャコールブラック'),
  gray(CustomColors.themaGray, 7, 'ストーングレー');

  final Color color;
  final int value;
  final String displayName; // 色の名称を追加

  const ThemaColor(this.color, this.value, this.displayName);

  Color toColor() => color;
  int toValue() => value;
  String toName() => displayName; // 名称を取得するメソッド

  // int から ThemaColor を取得
  static ThemaColor fromValue(int value) {
    return ThemaColor.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ThemaColor.blue, // デフォルト
    );
  }
}
