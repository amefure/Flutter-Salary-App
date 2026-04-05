import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/repository/biometrics_service.dart';
import 'package:salary/core/repository/password_repository.dart';
import 'package:salary/feature/app_lock/app_lock_setting_view_model.dart';

class MockPasswordRepository extends Mock implements PasswordRepository {}
class MockBiometricsService extends Mock implements BiometricsService {}

void main() {
  late MockPasswordRepository mockRepo;
  late MockBiometricsService mockBiometrics;
  late AppLockSettingViewModel viewModel;

  setUp(() async {
    mockRepo = MockPasswordRepository();
    mockBiometrics = MockBiometricsService();
    await Future.delayed(Duration.zero);
    // 生体認証のデフォルト挙動（コンストラクタで呼ばれる場合があるため先に定義）
    when(() => mockBiometrics.authenticateWithBiometrics())
        .thenAnswer((_) async => false);
  });

  group('AppLockSettingViewModel - 登録モード (isEntry = true)', () {
    setUp(() {
      // 登録モードで初期化
      viewModel = AppLockSettingViewModel(true, mockRepo, mockBiometrics);
    });

    test('addPassword: パスワードを4桁まで追加できること', () {
      viewModel.addPassword('1');
      viewModel.addPassword('2');
      viewModel.addPassword('3');
      viewModel.addPassword('4');
      viewModel.addPassword('5'); // 5桁目は無視されるはず

      expect(viewModel.state.inputPassword, ['1', '2', '3', '4']);
    });

    test('removeLast: 最後の文字が削除されること', () {
      viewModel.addPassword('1');
      viewModel.removeLast();
      expect(viewModel.state.inputPassword, isEmpty);
    });

    test('savePassword: 成功時にリポジトリに保存され、isAuthenticatedがtrueになること', () async {
      for (var key in ['1', '2', '3', '4']) { viewModel.addPassword(key); }
      when(() => mockRepo.setPassword(any())).thenAnswer((_) async => {});

      await viewModel.savePassword();

      verify(() => mockRepo.setPassword('1234')).called(1);
      expect(viewModel.state.isAuthenticated, isTrue);
    });
  });

  group('AppLockSettingViewModel - 認証モード (isEntry = false)', () {
    test('初期化時に生体認証が実行され、成功した場合に状態が更新されること', () async {
      when(() => mockBiometrics.authenticateWithBiometrics())
          .thenAnswer((_) async => true);

      viewModel = AppLockSettingViewModel(false, mockRepo, mockBiometrics);

      // Future.microtaskの完了を待つために少し待機
      await Future.delayed(Duration.zero);

      expect(viewModel.state.isAuthenticated, isTrue);
    });

    test('executeInputPassword: パスワード不一致でisFailedがtrueになること', () async {
      viewModel = AppLockSettingViewModel(false, mockRepo, mockBiometrics);
      for (var key in ['1', '2', '3', '4']) { viewModel.addPassword(key); }
      when(() => mockRepo.getPassword()).thenAnswer((_) async => '0000');

      await viewModel.executeInputPassword();

      expect(viewModel.state.isFailed, isTrue);
      // 失敗時はリセットされる
      expect(viewModel.state.inputPassword, isEmpty);
    });
  });
}