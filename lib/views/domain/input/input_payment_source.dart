import 'package:flutter/cupertino.dart';
import 'package:salary/utilitys/custom_colors.dart';
import 'package:salary/views/components/custom_text_field_view.dart';

class InputPaymentSourceView extends StatefulWidget {
  const InputPaymentSourceView({super.key});

  @override
  State<InputPaymentSourceView> createState() => _InputPaymentSourceViewState();
}

class _InputPaymentSourceViewState extends State<InputPaymentSourceView> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: CustomColors.foundation,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      child: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation,
        navigationBar: CupertinoNavigationBar(middle: Text("支払い元登録画面")),
        child: SafeArea(
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: "項目名",
                prefixIcon: CupertinoIcons.signature,
                keyboardType: TextInputType.text,
              ),

              CupertinoButton(
                child: const Text("完了"),
                onPressed: () {
                  // _showPicker(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
