import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/common/components/custom_text_view.dart';
import 'package:salary/domain/input_payment_source/input_payment_source_state.dart';
import 'package:salary/domain/input_payment_source/input_payment_source_view_model.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';
import 'package:salary/utilities/custom_colors.dart';
import 'package:salary/common/components/custom_elevated_button.dart';
import 'package:salary/common/components/custom_label_view.dart';
import 'package:salary/common/components/custom_text_field_view.dart';

class InputPaymentSourceView extends StatelessWidget {

  const InputPaymentSourceView({super.key, this.paymentSource});
  // 引数で支払い元情報を受け取る
  // nullでない場合は更新処理へ
  final PaymentSource? paymentSource;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: CustomColors.foundation(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation(context),
        navigationBar: CupertinoNavigationBar(
          middle: paymentSource == null ? const Text('支払い元登録画面') : const Text('支払い元更新画面'),
        ),
        child: _BodyWidget(paymentSource: paymentSource),
      ),
    );
  }
}


class _BodyWidget extends ConsumerStatefulWidget {
  final PaymentSource? paymentSource;
  const _BodyWidget({required this.paymentSource});

  @override
  ConsumerState<_BodyWidget> createState() => _Body();
}


class _Body extends ConsumerState<_BodyWidget> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  late final ProviderSubscription<InputPaymentSourceState> _subscription;

  @override
  void initState() {
    super.initState();
    // TextEditingController =>(変化) ViewModel.Stateと同期
    _bindControllersToState();
    // ViewModel.State =>(変化) TextEditingControllerと同期
    _bindStateToControllers();
  }

  /// ViewModel.State =>(変化) TextEditingControllerと同期
  void _bindStateToControllers() {
    _subscription = ref.listenManual<InputPaymentSourceState>(
      inputPaymentSourceProvider(widget.paymentSource),
      fireImmediately: true,
          (prev, next) {
        _syncController(_nameController, next.name);
        _syncController(_memoController, next.memo);
      },
    );
  }

  /// TextEditingController =>(変化) ViewModel.Stateと同期
  void _bindControllersToState() {
    final vm = ref.read(inputPaymentSourceProvider(widget.paymentSource).notifier);
    // 入力されたらViewModelに反映
    _nameController.addListener(() {
      vm.updateName(_nameController.text);
    });
    _memoController.addListener(() {
      vm.updateMemo(_memoController.text);
    });
  }

  @override
  void dispose() {
    _subscription.close();
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _syncController(
      TextEditingController controller,
      String newValue,
      ) {
    if (controller.text == newValue) return;

    // build外 & フレーム後に安全に更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.text = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 名称入力ボックス
                CustomTextField(
                  controller: _nameController,
                  labelText: '名称',
                  prefixIcon: CupertinoIcons.signature,
                  keyboardType: TextInputType.text,
                ),

                const SizedBox(height: 20),

                const CustomLabelView(labelText: '本業フラグ(設定できるのは1つまでです)'),

                const SizedBox(height: 8),

                _ToggleIsMainSwitch(paymentSource: widget.paymentSource),

                const SizedBox(height: 20),

                CustomTextField(
                  controller: _memoController,
                  labelText: 'MEMO',
                  prefixIcon: Icons.comment,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),

                const SizedBox(height: 20),

                const CustomLabelView(labelText: 'カラー'),
                // カラーピッカー
                _ThemaColorPicker(paymentSource: widget.paymentSource),

                const SizedBox(height: 20),

                // 追加 / 更新ボタン
                _SubmitButton(paymentSource: widget.paymentSource),
              ],
            ),
          )
      ),
    );
  }

}

/// 本業フラグSwitch
class _ToggleIsMainSwitch extends ConsumerWidget {

  const _ToggleIsMainSwitch({required this.paymentSource});

  final PaymentSource? paymentSource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMain = ref.watch(inputPaymentSourceProvider(paymentSource).select((s) => s.isMain));
    final isMainEnabled = ref.watch(inputPaymentSourceProvider(paymentSource).select((s) => s.isMainEnabled));
    final vm = ref.read(inputPaymentSourceProvider(paymentSource).notifier);
    return Column(
        children: [

          if (!isMainEnabled)
            const CustomText(
              text: '既に別のデータで設定済みです',
              textSize: TextSize.MS,
              fontWeight: FontWeight.bold,
            ),

          if (isMainEnabled)
            Row(
              children: [
                const Spacer(),
                CupertinoSwitch(
                  activeTrackColor: CustomColors.thema,
                  value: isMain,
                  onChanged: isMainEnabled ? (bool value) {
                    vm.updateIsMain(value);
                  } : null,
                ),
              ]
            )
        ]
    );
  }
}

/// カラーピッカー
class _ThemaColorPicker extends ConsumerWidget {

  const _ThemaColorPicker({required this.paymentSource});

  final PaymentSource? paymentSource;

  List<DropdownMenuItem<ThemaColor>> _createItems() {
    return ThemaColor.values.map((color) {
      return DropdownMenuItem(
        value: color,
        child: Row(
          children: [
            Container(width: 20, height: 20, color: color.color),
            const SizedBox(width: 8),
            Text(color.toName()),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedColor = ref.watch(inputPaymentSourceProvider(paymentSource).select((s) => s.selectedColor));
    final vm = ref.read(inputPaymentSourceProvider(paymentSource).notifier);
    return DropdownButton<ThemaColor>(
      value: selectedColor,
      items: _createItems(),
      onChanged: (color) {
        vm.updateColor(color);
      },
    );
  }
}

class _SubmitButton extends ConsumerWidget {
  const _SubmitButton({required this.paymentSource});

  final PaymentSource? paymentSource;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(inputPaymentSourceProvider(paymentSource).notifier);
    return  // 追加 / 更新ボタン
      CustomElevatedButton(
        text: paymentSource == null ? '追加' : '更新',
        onPressed: () {
          vm.createOrUpdate(
              onComplete: (){
                Navigator.of(context).pop();
              },
              onError: (){
                _showErrorDialog(context);
              }
          );
        },
      );
  }

  /// エラーダイアログを表示
  void _showErrorDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('名称を入力してください。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}