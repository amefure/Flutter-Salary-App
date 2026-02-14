
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_controller.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/utils/date_time_utils.dart';
import 'package:salary/feature/auth/application/user_info/user_info_state.dart';
import 'package:salary/feature/auth/domain/auth_user.dart';
import 'package:salary/feature/auth/presentation/register_account_screen.dart';


final userInfoProvider =
StateNotifierProvider.autoDispose<UserInfoViewModel, UserInfoState>((ref) {
  final state = ref.read(authControllerProvider);
  final authController = ref.read(authControllerProvider.notifier);
  return UserInfoViewModel(ref, state.user, authController);
});

class UserInfoViewModel extends StateNotifier<UserInfoState>{

  UserInfoViewModel(
      this._ref,
      AuthUser? initialUser,
      this._authController,
      ): super(UserInfoState.initial()) {
    _setUpUserInfo(initialUser);
  }

  final Ref _ref;
  final AuthController _authController;

  void _setUpUserInfo(AuthUser? initialUser) {
    state = state.copyWith(
        name: initialUser?.name,
        email: initialUser?.email,
        region: initialUser?.region,
        birthday: initialUser?.birthday,
        job: initialUser?.job,
    );
  }

  /// 日付表示用整形
  String displayDate(DateTime? date) {
    if (date == null) return ProfileConfig.undefined;
    return DateTimeUtils.format(dateTime: date, pattern: 'yyyy年M月d日');
  }

  Future<bool> updateUserInfo() async {
    return await _ref.runWithGlobalHandling(() async {
      await _authController.updateProfile(
        region: state.region,
        birthday: state.birthday!,
        job: state.job,
      );
    });
  }

  void updateRegion(String value) {
    final isCompleted = _isAllValidation(region: value);
    state = state.copyWith(
        region: value,
        isCompleted: isCompleted
    );
  }

  void updateBirthday(DateTime value) {
    final isCompleted = _isAllValidation(birthday: value);
    state = state.copyWith(
        birthday: value,
        isCompleted: isCompleted
    );
  }

  void updateJob(String value) {
    final isCompleted = _isAllValidation(job: value);
    state = state.copyWith(
        job: value,
        isCompleted: isCompleted
    );
  }

  /// バリデーション(登録ボタンの活性判定に使用)
  /// バリデーションの通らない値はそもそも送信できない設計になっている
  bool _isAllValidation({
    String? name,
    String? region,
    DateTime? birthday,
    String? job,
  }) {
    final currentName = name ?? state.name;
    final currentRegion = region ?? state.region;
    final currentBirthday = birthday ?? state.birthday;
    final currentJob = job ?? state.job;

    /// アカウント名
    final hasName = currentName.isNotEmpty;

    final hasRegion = currentRegion != ProfileConfig.undefined;
    final hasBirthday = currentBirthday != null;
    final hasJob = currentJob != ProfileConfig.undefined;
    return hasName && hasRegion && hasBirthday && hasJob;
  }
}