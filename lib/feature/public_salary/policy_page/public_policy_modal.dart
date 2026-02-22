import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/config/public_policy_config.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/public_salary/policy_page/public_policy_service.dart';

Future<bool?> showPublicPolicyModal(
    BuildContext context, {
      bool showAgreeButton = false,
    }) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    builder: (_) => PublicPolicyModal(
      showAgreeButton: showAgreeButton,
    ),
  );
}


class PublicPolicyModal extends StatefulWidget {
  final bool showAgreeButton;

  const PublicPolicyModal({
    super.key,
    this.showAgreeButton = false,
  });

  @override
  State<PublicPolicyModal> createState() => _PublicPolicyModalState();
}


class _PublicPolicyModalState extends State<PublicPolicyModal> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 20) {
        if (!_hasScrolledToBottom) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = _hasScrolledToBottom && _isChecked;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          /// タイトル
          const Padding(
            padding: EdgeInsets.all(16),
            child: CustomText(
              text: PublicPolicyConfig.title,
              textSize: TextSize.ML,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Divider(height: 1),

          /// 規約本文
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: _buildPolicyContent(),
            ),
          ),

          if (widget.showAgreeButton)...[
            const Divider(height: 1),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
                CustomText(
                  text: _isChecked == true && _hasScrolledToBottom == false ? '最後までスクロールして内容を確認してください。' : '上記内容を確認し、同意します。' ,
                  textSize: TextSize.S,
                )
              ],
            ),

            /// 同意ボタン
            Consumer(
                builder: (context, ref, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomElevatedButton(
                      text: '同意して公開する',
                      backgroundColor: isEnabled ? CustomColors.thema : CustomColors.themaBlack.withAlpha(70),
                      onPressed: () async {
                        if (isEnabled) {
                          final result = await ref.read(publicPolicyProvider).updatePolicyProfile();
                          if (result) {
                            // ポリシー規約に同意し、サーバー情報も更新成功したのでtrueで戻る
                            Navigator.of(context).pop(true);
                          }
                        }
                      },
                    ),
                  );
                }
            )
          ]
        ],
      ),
    );
  }

  Widget _buildPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(
          'バージョン',
          'バージョン: ${PublicPolicyConfig.version}\n'
              '制定日: ${PublicPolicyConfig.effectiveDate}',
        ),
        _section('公開対象データ',
            PublicPolicyConfig.publishScopeDescription),
        _section('個人特定リスク',
            PublicPolicyConfig.identificationRiskClause),
        _section('利用者の責任',
            PublicPolicyConfig.userResponsibilityClause),
        _section('禁止事項',
            PublicPolicyConfig.prohibitedActionsClause),
        _section('第三者利用制限',
            PublicPolicyConfig.thirdPartyUseRestriction),
        _section('データ保持・削除',
            PublicPolicyConfig.retentionPolicy),
        _section('削除権',
            PublicPolicyConfig.deletionRightClause),
        _section('責任制限',
            PublicPolicyConfig.liabilityLimitationClause),
        _section('サービス変更',
            PublicPolicyConfig.serviceModificationClause),
        _section('改定',
            PublicPolicyConfig.revisionClause),
        _section('反社会的勢力',
            PublicPolicyConfig.antiSocialForcesClause),
        _section('準拠法・管轄',
            PublicPolicyConfig.governingLawClause),
      ],
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            textSize: TextSize.MS,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: content,
            textSize: TextSize.S,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
