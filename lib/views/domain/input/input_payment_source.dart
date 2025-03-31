import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/viewmodels/payment_source_viewmodel.dart';
import 'package:salary/views/components/custom_elevated_button.dart';
import 'package:salary/views/components/custom_label_view.dart';
import 'package:salary/views/components/custom_text_field_view.dart';

class InputPaymentSourceView extends StatefulWidget {
  const InputPaymentSourceView({super.key, this.paymentSource});

  final PaymentSource? paymentSource;

  @override
  State<InputPaymentSourceView> createState() => _InputPaymentSourceViewState();
}

class _InputPaymentSourceViewState extends State<InputPaymentSourceView> {
  final TextEditingController _nameController = TextEditingController();
  ThemaColor selectedColor = ThemaColor.gray;

  @override
  void initState() {
    if (widget.paymentSource case PaymentSource paymentSource) {
      _nameController.text = paymentSource.name;
      selectedColor = paymentSource.themaColorEnum;
    }
    ;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// エラーダイアログを表示
  void _showErrorDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("名称を入力してください。"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: CustomColors.foundation,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation,
        navigationBar: CupertinoNavigationBar(
          middle:
              widget.paymentSource == null
                  ? const Text("支払い元登録画面")
                  : const Text("支払い元更新画面"),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  labelText: "名称",
                  prefixIcon: CupertinoIcons.signature,
                  keyboardType: TextInputType.text,
                ),

                const SizedBox(height: 20),

                const CustomLabelView(labelText: "カラー"),

                _ThemaColorPicker(
                  selectedColor: selectedColor,
                  onColorSelected: (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                ),

                const SizedBox(height: 20),

                CustomElevatedButton(
                  text: widget.paymentSource == null ? "追加" : "更新",
                  onPressed: () {
                    String name = _nameController.text;
                    if (name.isNotEmpty) {
                      if (widget.paymentSource
                          case PaymentSource paymentSource) {
                        context.read<PaymentSourceViewModel>().update(
                          paymentSource.id,
                          name,
                          selectedColor,
                        );
                      } else {
                        final payment = PaymentSource(
                          Uuid.v4().toString(),
                          name,
                          selectedColor.value,
                        );
                        context.read<PaymentSourceViewModel>().add(payment);
                      }

                      Navigator.of(context).pop();
                    } else {
                      _showErrorDialog(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// カラーピッカー UI
class _ThemaColorPicker extends StatefulWidget {
  // 選択済みカラー
  final ThemaColor selectedColor;
  // カラー選択後のアクション
  final Function(ThemaColor) onColorSelected;

  const _ThemaColorPicker({
    this.selectedColor = ThemaColor.blue,
    required this.onColorSelected,
  });

  @override
  _ThemaColorPickerState createState() => _ThemaColorPickerState();
}

class _ThemaColorPickerState extends State<_ThemaColorPicker> {
  late ThemaColor selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ThemaColor>(
      value: selectedColor,
      items:
          ThemaColor.values.map((color) {
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
          }).toList(),
      onChanged: (color) {
        if (color != null) {
          setState(() {
            selectedColor = color;
          });
          widget.onColorSelected(color);
        }
      },
    );
  }
}
