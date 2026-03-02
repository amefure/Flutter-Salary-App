import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/common/components/domain/step_item.dart';
import 'package:salary/core/config/public_policy_config.dart';
import 'package:salary/core/utils/number_utils.dart';
import 'package:salary/feature/public_salary/policy_page/public_policy_modal.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/domain/payment_icon_view.dart';
import 'package:salary/core/common/overlay/explanation_overlay.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/public_salary/public_salary_view_model.dart';

class PublicSalaryScreen extends ConsumerWidget {
  const PublicSalaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentSources = ref.watch(publicSalaryProvider.select((s) => s.paymentSources));
    final isMainPublic = ref.watch(publicSalaryProvider.select((s) => s.isMainPublic));
    final viewModel = ref.read(publicSalaryProvider.notifier);
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: CupertinoNavigationBar(
        middle: const CustomText(
          text: '給料公開設定',
          fontWeight: FontWeight.bold,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.question_circle_fill,
            size: 28,
          ),
          onPressed: () {
            ExplanationOverlay.show(
              context: context,
              title: PublicSimplePolicyConfig.title,
              description: PublicSimplePolicyConfig.description,
            );
          },
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: paymentSources.length,
          itemBuilder: (context, index) {
            final source = paymentSources[index];

            final publicCheckResult = viewModel.canPublic(source);

            return _PublicSalaryItem(
              paymentSource: source,
              isPublic: source.isPublic,
              canPublic: publicCheckResult.canPublic,
              currentCount: publicCheckResult.count,
              currentTotal: publicCheckResult.totalAmount,
              isMainPublic: source.isMain ? true : isMainPublic,
              onChanged: (isPublic) async {
                final status = viewModel.checkPublicStatus(source, publicCheckResult, isPublic);

                switch (status) {
                  case PublicCheckStatus.blockedByLimit:
                    return;

                  case PublicCheckStatus.cannotUnPublicMain:
                    await AppDialog.show(
                      context: context,
                      message: '本業以外を公開している場合は\n本業を非公開にできません。',
                      type: DialogType.error,
                    );
                    break;

                  case PublicCheckStatus.policyRequired:
                    final agreed = await showPublicPolicyModal(context, showAgreeButton: true);
                    if (agreed == true) {
                      _confirmAlertPublic(context, ref, source, isPublic);
                    }
                    break;

                  case PublicCheckStatus.agreed:
                    _confirmAlertPublic(context, ref, source, isPublic);
                    break;
                }
              },
            );
          },
        ),
      ),
    );
  }

  void _confirmAlertPublic(
      BuildContext context,
      WidgetRef ref,
      PaymentSource source,
      bool isPublic
      ) async {
    /// isPublicは変化対象の値なのでtrueなら元は非公開ステータスのものになる
    final confirmMsg = !isPublic ? '非公開に戻しますか？' : 'この支払い元で登録している給料情報を公開しますか？';
    final positiveTitle = !isPublic ? '非公開にする' : '公開する';
    final result = await AppDialog.show(
        context: context,
        message: confirmMsg,
        type: DialogType.confirm,
        positiveTitle: positiveTitle,
        isPositiveNegativeType: !isPublic
    );
    if (result ?? false) {
      final viewModel = ref.read(publicSalaryProvider.notifier);
      final result = await viewModel.updatePaymentSource(source, isPublic);
      if (result) {
        final successMsg = !isPublic ? '給料情報を非公開にしました。' : 'ありがとうございます。\n給料情報を公開しました。';
        final _ = await AppDialog.show(
            context: context,
            message: successMsg,
            type: DialogType.success,
        );
      }
    }
  }
}

class _PublicSalaryItem extends StatelessWidget {
  const _PublicSalaryItem({
    required this.paymentSource,
    required this.isPublic,
    required this.canPublic,
    required this.onChanged,
    required this.currentCount,
    required this.currentTotal,
    required this.isMainPublic,
  });

  final PaymentSource paymentSource;
  final bool isPublic;
  final bool canPublic;
  final int currentCount;
  final int currentTotal;
  final bool isMainPublic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final baseColor = CustomColors.background(context);
    final disabledColor = CustomColors.text(context).withAlpha(90);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: canPublic ? baseColor : baseColor.withAlpha(95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
            CupertinoColors.systemGrey.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [

          /// アイコン
          PaymentIconWrapView(paymentSource: paymentSource),

          const SizedBox(width: 14),

          /// タイトル
          CustomText(
            text: paymentSource.name,
            fontWeight: FontWeight.bold,
            color: canPublic
                ? null
                : disabledColor,
          ),

          const Spacer(),

          /// ステータスボタン
          canPublic
              ? _publicStateButton()
              : _canNotPublicStatus(context, currentCount, currentTotal, isMainPublic),
        ],
      ),
    );
  }

  /// 公開 / 非公開ステータスボタン
  Widget _publicStateButton() {
    return GestureDetector(
      onTap: () => onChanged(!isPublic),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isPublic
              ? CustomColors.themaBlue.withAlpha(20)
              : CustomColors.negative.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPublic
                ? CustomColors.themaBlue
                : CustomColors.negative,
            width: 1,
          ),
        ),
        child: CustomText(
          text: isPublic ? '公開中' : '非公開',
          textSize: TextSize.S,
          fontWeight: FontWeight.bold,
          color: isPublic
              ? CustomColors.themaBlue
              : CustomColors.negative,
        ),
      ),
    );
  }

  /// 条件未達成ステータス
  Widget _canNotPublicStatus(
      BuildContext context,
      int currentCount,
      int currentTotal,
      bool isMainPublic,
      ) {
    return GestureDetector(
      onTap: () => {
        _showPublicConditionModal(
          context,
          currentCount: currentCount,
          currentTotal: currentTotal,
          requiredCount: PublicSalaryViewModel.minSalaryCountForPublic,
          requiredTotal: PublicSalaryViewModel.minTotalPaymentAmountForPublic,
          isMainPublic: isMainPublic
        )
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: CustomColors.themaOrange.withAlpha(40),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.lock_fill,
              size: 14,
              color: CustomColors.themaOrange,
            ),
            SizedBox(width: 4),
            CustomText(
              text: '条件未達',
              color: CustomColors.themaOrange,
              fontWeight: FontWeight.bold,
              textSize: TextSize.SS,
            ),
          ],
        ),
      )
    );
  }

  void _showPublicConditionModal(
      BuildContext context, {
        required int currentCount,
        required int currentTotal,
        required int requiredCount,
        required int requiredTotal,
        required bool isMainPublic
      }) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return _PublicConditionModal(
            currentCount: currentCount,
            currentTotal: currentTotal,
            requiredCount: requiredCount,
            requiredTotal: requiredTotal,
            isMainPublic: isMainPublic
        );
      },
    );
  }

}


class _PublicConditionModal extends StatelessWidget {
  const _PublicConditionModal({
    required this.currentCount,
    required this.currentTotal,
    required this.requiredCount,
    required this.requiredTotal,
    required this.isMainPublic,
  });

  final int currentCount;
  final int currentTotal;
  final int requiredCount;
  final int requiredTotal;
  final bool isMainPublic;

  @override
  Widget build(BuildContext context) {
    final countProgress =
    (currentCount / requiredCount).clamp(0.0, 1.0);

    final amountProgress =
    (currentTotal / requiredTotal).clamp(0.0, 1.0);

    return CupertinoPopupSurface(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const CustomText(
              text: '支払い元公開条件',
              fontWeight: FontWeight.bold,
              textSize: TextSize.L,
            ),

            const SizedBox(height: 20),

            StepItem(
                number: 1,
                title: '本業の支払い元を公開',
                isCompleted: isMainPublic
            ),

            const CustomText(
              text: '本業以外の情報を公開するには本業を公開している必要があります。',
              textSize: TextSize.SS,
            ),

            const SizedBox(height: 16),

            StepItem(
                number: 2,
                title: '給料登録件数',
                isCompleted: currentCount >= requiredCount
            ),
            _ConditionProgress(
              current: currentCount,
              required: requiredCount,
              progress: countProgress,
            ),

            const SizedBox(height: 16),

            StepItem(
                number: 3,
                title: '合計金額',
                isCompleted: currentTotal >= requiredTotal
            ),
            _ConditionProgress(
              current: currentTotal,
              required: requiredTotal,
              progress: amountProgress,
              isMoney: true,
            ),

            const SizedBox(height: 20),

            CupertinoButton(
              child: const CustomText(
                text: '閉じる',
                color: CustomColors.themaBlue,
                fontWeight: FontWeight.bold,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionProgress extends StatelessWidget {
  const _ConditionProgress({
    required this.current,
    required this.required,
    required this.progress,
    this.isMoney = false,
  });

  final int current;
  final int required;
  final double progress;
  final bool isMoney;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor:
            CupertinoColors.systemGrey.withAlpha(60),
            valueColor: const AlwaysStoppedAnimation(
                CustomColors.thema),
          ),
        ),

        const SizedBox(height: 4),

        CustomText(
          text: isMoney
              ? '¥${NumberUtils.formatWithComma(current)} / ¥${NumberUtils.formatWithComma(required)}'
              : '$current / $required 件',
          textSize: TextSize.S,
        ),
      ],
    );
  }
}

