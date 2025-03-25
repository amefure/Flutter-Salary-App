import 'package:flutter/material.dart';
import 'package:salary/utilitys/custom_colors.dart';

// フォントサイズのサイズを管理するEnum
enum TextSize { small, medium, large }

class CustomText extends StatelessWidget {
  final String text; // 表示するテキスト
  final TextSize textSize; // サイズを指定
  final Color color; // テキストカラー
  final FontWeight fontWeight; // フォントの太さ

  const CustomText({
    Key? key,
    required this.text,
    this.textSize = TextSize.medium, 
    this.color = CustomColors.text, 
    this.fontWeight = FontWeight.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // サイズによってフォントサイズを設定
    double fontSize;
    switch (textSize) {
      case TextSize.small:
        fontSize = 14.0;
        break;
      case TextSize.medium:
        fontSize = 17.0;
        break;
      case TextSize.large:
        fontSize = 20.0;
        break;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }
}
