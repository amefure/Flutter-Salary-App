import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/custom_elevated_button.dart';
import 'package:salary/core/common/components/custom_text_field_view.dart';
import 'package:salary/core/common/components/custom_text_view.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/feature/auth/application/register_account_state.dart';
import 'package:salary/feature/auth/application/register_account_view_model.dart';
import 'package:salary/core/utils/custom_colors.dart';

class RegisterAccountView extends StatelessWidget {
  const RegisterAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation(context),
        navigationBar: const CupertinoNavigationBar(
            middle: CustomText(
              text: '新規アカウント作成',
              fontWeight: FontWeight.bold,
            )
        ),
        child: const SafeArea(
            child: Padding(
                padding: EdgeInsets.all(16),
                child: _BodyWidget()
            )
        ),
    );
  }
}

class _BodyWidget extends ConsumerStatefulWidget {
  const _BodyWidget();

  @override
  ConsumerState<_BodyWidget> createState() => _Body();
}


class _Body extends ConsumerState<_BodyWidget> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passWordController = TextEditingController();
  final TextEditingController _passWordConfirmController = TextEditingController();
  late final ProviderSubscription<RegisterAccountState> _subscription;

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
    _subscription = ref.listenManual<RegisterAccountState>(
      registerAccountProvider,
      fireImmediately: true,
          (prev, next) {
        _syncController(_nameController, next.name);
        _syncController(_emailController, next.email);
        _syncController(_passWordController, next.password);
        _syncController(_passWordConfirmController, next.passwordConfirm);
      },
    );
  }

  /// TextEditingController =>(変化) ViewModel.Stateと同期
  void _bindControllersToState() {
    final vm = ref.read(registerAccountProvider.notifier);
    // 入力されたらViewModelに反映
    _nameController.addListener(() {
      vm.updateName(_nameController.text);
    });
    _emailController.addListener(() {
      vm.updateEmail(_emailController.text);
    });
    _passWordController.addListener(() {
      vm.updatePassWord(_passWordController.text);
    });
    _passWordConfirmController.addListener(() {
      vm.updatePassWordConfirm(_passWordConfirmController.text);
    });
  }

  @override
  void dispose() {
    _subscription.close();
    _emailController.dispose();
    _passWordController.dispose();
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
    final state = ref.watch(registerAccountProvider);
    final viewModel = ref.read(registerAccountProvider.notifier);
    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        children: [

          /// アカウント名
          CustomTextField(
            controller: _nameController,
            labelText: 'アカウント名',
            prefixIcon: CupertinoIcons.person_crop_square_fill,
            keyboardType: TextInputType.name,
          ),

          /// メールアドレス入力ボックス
          CustomTextField(
            controller: _emailController,
            labelText: 'メールアドレス',
            prefixIcon: CupertinoIcons.mail_solid,
            keyboardType: TextInputType.emailAddress,
          ),

          Column(
            children: [
              /// パスワード入力ボックス
              CustomTextField(
                controller: _passWordController,
                labelText: 'パスワード',
                prefixIcon: CupertinoIcons.lock_fill,
                keyboardType: TextInputType.visiblePassword,
              ),

              const SizedBox(height: 24),

              /// パスワード確認用入力ボックス
              CustomTextField(
                controller: _passWordConfirmController,
                labelText: 'パスワード確認用',
                prefixIcon: CupertinoIcons.lock_fill,
                keyboardType: TextInputType.visiblePassword,
              ),

              const CustomText(
                text: 'パスワードは8文字以上で、英数字を混載したものを使用してください',
                textSize: TextSize.SS,
                maxLines: 2,
              )
            ],
          ),

          /// 都道府県
          _rowTile(
            title: '都道府県',
            value: state.region,
            onTap: () =>
                _showPrefecturePicker(
                  context,
                  state.region,
                  viewModel.updateRegion,
                ),
          ),

          /// 生年月日
          _rowTile(
              title: '生年月日',
              value: _formatDate(state.birthday),
              onTap: () {
                final date = state.birthday ?? ProfileConfig.defaultDateTime;

                viewModel.updateBirthday(date);

                _showBirthdayPicker(
                  context,
                  date,
                  viewModel.updateBirthday,
                );
              }
          ),

          /// 職業
          _rowTile(
            title: '職業',
            value: state.job,
            onTap: () =>
                _showJobPicker(
                  context,
                  state.job,
                  viewModel.updateJob,
                ),
          ),

          CustomElevatedButton(
              text: '登録する',
              backgroundColor: state.isCompleted ? ThemaColor.blue.color : ThemaColor.gray.color,
              onPressed: () {
                viewModel.registerAccount();
              }
          )
        ],
      ),
    );
  }

  Widget _rowTile({
    required String title,
    required String value,
    required VoidCallback onTap
  }) {
    return Row(
      children: [

        if (value == ProfileConfig.undefined)
          const Icon(
            CupertinoIcons.check_mark_circled,
            size: 28,
          ),

        if (value != ProfileConfig.undefined)
          const Icon(
            CupertinoIcons.check_mark_circled_solid,
            size: 28,
          ),

        const SizedBox(width: 8),

        CustomText(
          text: title,
          fontWeight: FontWeight.bold,
        ),

        const Spacer(),

        TextButton(
          onPressed: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: 140,
            decoration: BoxDecoration(
              color: value == ProfileConfig.undefined ? ThemaColor.gray.color : ThemaColor.blue.color,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                CustomText(
                  text: value,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  textSize: TextSize.S,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),

      ],
    );
  }

  void _showPrefecturePicker(
      BuildContext context,
      String current,
      void Function(String) onSelected,
      ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          color: CustomColors.foundation(context),
          child: CupertinoPicker(
            itemExtent: 36,
            scrollController: FixedExtentScrollController(
              initialItem: ProfileConfig.prefectures.indexOf(current),
            ),
            onSelectedItemChanged: (index) {
              onSelected(ProfileConfig.prefectures[index]);
            },
            children: ProfileConfig.prefectures.map(Text.new).toList(),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return ProfileConfig.undefined;
    return '${date.year}年${date.month.toString()}月${date.day.toString()}日';
  }
  void _showBirthdayPicker(
      BuildContext context,
      DateTime current,
      void Function(DateTime) onSelected,
      ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          color: CustomColors.foundation(context),
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: current,
            maximumDate: DateTime.now(),
            minimumYear: 1900,
            onDateTimeChanged: onSelected,
          ),
        );
      },
    );
  }

  void _showJobPicker(
      BuildContext context,
      String current,
      void Function(String) onSelected,
      ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          color: CustomColors.foundation(context),
          child: CupertinoPicker(
            itemExtent: 36,
            scrollController: FixedExtentScrollController(
              initialItem: ProfileConfig.jobs.indexOf(current),
            ),
            onSelectedItemChanged: (index) {
              onSelected(ProfileConfig.jobs[index]);
            },
            children: ProfileConfig.jobs.map(Text.new).toList(),
          ),
        );
      },
    );
  }

}

abstract class ProfileConfig {

  static const empty = '';
  static const undefined = '未設定';
  static final defaultDateTime = DateTime(2026, 1, 1);

  static const List<String> prefectures = [
    '北海道','青森県','岩手県','宮城県','秋田県','山形県','福島県',
    '茨城県','栃木県','群馬県','埼玉県','千葉県','東京都','神奈川県',
    '新潟県','富山県','石川県','福井県','山梨県','長野県',
    '岐阜県','静岡県','愛知県','三重県',
    '滋賀県','京都府','大阪府','兵庫県','奈良県','和歌山県',
    '鳥取県','島根県','岡山県','広島県','山口県',
    '徳島県','香川県','愛媛県','高知県',
    '福岡県','佐賀県','長崎県','熊本県','大分県','宮崎県','鹿児島県',
    '沖縄県',
  ];

  static const List<String> jobs = [
    '会社員',
    '自営業',
    '公務員',
    '学生',
    '主婦・主夫',
    '農業',
    'フリーランス',
    '無職',
    'その他',
  ];
}
