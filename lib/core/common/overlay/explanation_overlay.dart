import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';

class ExplanationOverlay extends StatelessWidget {
  final String title;
  final String description;

  const ExplanationOverlay({
    super.key,
    required this.title,
    required this.description,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return ExplanationOverlay(
          title: title,
          description: description,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [

          /// 背景ぼかし
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8,
                sigmaY: 8,
              ),
              child: Container(
                color: Colors.black.withAlpha(20),
              ),
            ),
          ),

          Center(
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 250),
              tween: Tween(begin: 0.9, end: 1.0),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [

                  /// カード
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground
                          .resolveFrom(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomText(
                          text: title,
                          textSize: TextSize.L,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 16),
                        CustomText(
                          text: description,
                          textSize: TextSize.M,
                          maxLines: 20,
                        ),
                      ],
                    ),
                  ),

                  /// × ボタン
                  Positioned(
                    top: -14,
                    right: -14,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: CupertinoColors.systemGrey,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          CupertinoIcons.clear,
                          size: 16,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
