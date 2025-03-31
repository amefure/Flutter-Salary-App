import 'package:flutter/material.dart';
import 'package:salary/utilitys/custom_colors.dart';

// フォントサイズのサイズを管理するEnum
enum TextSize { SS, S, MS, M, ML, L }

class CustomText extends StatelessWidget {
  final String text; // 表示するテキスト
  final TextSize textSize; // サイズを指定
  final Color color; // テキストカラー
  final FontWeight fontWeight; // フォントの太さ
  final int? maxLines; // 行数

  const CustomText({
    Key? key,
    required this.text,
    this.textSize = TextSize.M,
    this.color = CustomColors.text,
    this.fontWeight = FontWeight.normal,
    this.maxLines = 1
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // サイズによってフォントサイズを設定
    double fontSize;
    switch (textSize) {
      case TextSize.SS:
        fontSize = 12.0;
        break;
      case TextSize.S:
        fontSize = 14.0;
        break;
      case TextSize.MS:
        fontSize = 15.0;
        break;
      case TextSize.M:
        fontSize = 17.0;
        break;
      case TextSize.ML:
        fontSize = 18.0;
        break;
      case TextSize.L:
        fontSize = 20.0;
        break;
    }

    return Text(
      text,
      // 最大行数
      maxLines: maxLines,
      // 文字溢れ時の挙動
      overflow: TextOverflow.ellipsis,
      // 改行するか否か
      softWrap: false,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }
}
