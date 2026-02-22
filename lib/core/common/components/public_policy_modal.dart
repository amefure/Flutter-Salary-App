import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/config/public_policy_config.dart';
import 'package:salary/core/utils/custom_colors.dart';

Future<bool?> showPublicPolicyModal(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    builder: (_) => const PublicPolicyModal(),
  );
}

class PublicPolicyModal extends StatefulWidget {
  const PublicPolicyModal({super.key});

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
              maxLines: null,
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child:  CustomElevatedButton(
              text: '同意して公開する',
              backgroundColor: isEnabled ? CustomColors.thema : CustomColors.themaBlack.withAlpha(70),
              onPressed: () {
                isEnabled
                    ? () => Navigator.pop(context, true)
                    : null;
              },
            ),
          )

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
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            textSize: TextSize.MS,
            fontWeight: FontWeight.bold,
            maxLines: null,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: content,
            textSize: TextSize.S,
            maxLines: null,
          ),
        ],
      ),
    );
  }
}
