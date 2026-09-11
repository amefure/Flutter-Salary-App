import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/feature/salary/export/application/salary_export_view_model.dart';
import 'package:salary/feature/salary/export/data/salary_share_service.dart';
import 'package:salary/feature/salary/export/domain/salary_export_access.dart';

import '../../../../helpers/dummy_data_helper.dart';

class MockLocalSalaryRepository extends Mock implements LocalSalaryRepository {}

class MockSalaryShareService extends Mock implements SalaryShareService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(const Rect.fromLTWH(0, 0, 1, 1));
  });

  group('SalaryExportAccess', () {
    test('全機能解放またはプレミアム機能解放なら利用できる', () {
      expect(
        SalaryExportAccess.isAllowed(
          PremiumFunctionState(isPremiumFullUnlocked: true),
        ),
        isTrue,
      );
      expect(
        SalaryExportAccess.isAllowed(
          PremiumFunctionState(isPremiumFeatureUnlocked: true),
        ),
        isTrue,
      );
    });

    test('どちらも未解放なら利用できない', () {
      expect(SalaryExportAccess.isAllowed(PremiumFunctionState()), isFalse);
    });
  });

  group('SalaryExportViewModel', () {
    late MockLocalSalaryRepository repository;
    late MockSalaryShareService shareService;

    setUp(() {
      repository = MockLocalSalaryRepository();
      shareService = MockSalaryShareService();
    });

    test('未解放の場合はデータ取得と共有を実行しない', () async {
      final viewModel = SalaryExportViewModel(
        localSalaryRepository: repository,
        shareService: shareService,
        readPremiumState: () => PremiumFunctionState(),
      );

      final result = await viewModel.export();

      expect(result, SalaryExportResult.locked);
      verifyNever(() => repository.fetchAll());
      verifyNever(
        () => shareService.share(
          any(),
          fileName: any(named: 'fileName'),
          sharePositionOrigin: any(named: 'sharePositionOrigin'),
        ),
      );
    });

    test('解放済みの場合はCSVを共有する', () async {
      final salary = fakeSalary(source: fakePaymentSource());
      when(() => repository.fetchAll()).thenReturn([salary]);
      Uint8List? sharedBytes;
      when(
        () => shareService.share(
          any(),
          fileName: any(named: 'fileName'),
          sharePositionOrigin: any(named: 'sharePositionOrigin'),
        ),
      ).thenAnswer((invocation) async {
        sharedBytes = invocation.positionalArguments.first as Uint8List;
      });

      final viewModel = SalaryExportViewModel(
        localSalaryRepository: repository,
        shareService: shareService,
        readPremiumState:
            () => PremiumFunctionState(isPremiumFeatureUnlocked: true),
      );

      final result = await viewModel.export();

      expect(result, SalaryExportResult.shared);
      expect(sharedBytes, isNotNull);
      expect(sharedBytes!.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
      verify(() => repository.fetchAll()).called(1);
      verify(
        () => shareService.share(
          any(),
          fileName: any(named: 'fileName'),
          sharePositionOrigin: any(named: 'sharePositionOrigin'),
        ),
      ).called(1);
    });
  });
}
