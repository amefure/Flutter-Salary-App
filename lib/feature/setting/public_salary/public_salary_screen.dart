import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/app_dialog.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/core/common/components/payment_icon_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/setting/public_salary/public_salary_view_model.dart';

class PublicSalaryScreen extends ConsumerWidget {
  const PublicSalaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentSources = ref.watch(publicSalaryProvider.select((s) => s.paymentSources));
    final viewModel = ref.read(publicSalaryProvider.notifier);
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: '給料公開設定',
          fontWeight: FontWeight.bold,
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: paymentSources.length,
          itemBuilder: (context, index) {
            final source = paymentSources[index];

            final canPublic = viewModel.canPublic(source);

            return _PublicSalaryItem(
              paymentSource: source,
              isPublic: source.isPublic,
              canPublic: canPublic,
              onChanged: (isPublic) {
                if (!canPublic) return;
                // ViewModelに通知（後で実装）
                _confirmAlertPublic(context, ref, source, isPublic);
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
    final msg = !isPublic ? '非公開に戻しますか？' : 'この支払い元で登録している給料情報を公開しますか？';
    final positiveTitle = !isPublic ? '非公開にする' : '公開する';
    final result = await AppDialog.show(
        context: context,
        message: msg,
        type: DialogType.confirm,
        positiveTitle: positiveTitle,
        isPositiveNegativeType: !isPublic
    );
    if (result ?? false) {
      final viewModel = ref.read(publicSalaryProvider.notifier);
      viewModel.updatePaymentSource(source, isPublic);
    }
  }
}

class _PublicSalaryItem extends StatelessWidget {
  const _PublicSalaryItem({
    required this.paymentSource,
    required this.isPublic,
    required this.canPublic,
    required this.onChanged,
  });

  final PaymentSource paymentSource;
  final bool isPublic;
  final bool canPublic;
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
              : _canNotPublicStatus(),
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
  Widget _canNotPublicStatus() {
    return Container(
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
    );
  }
}

