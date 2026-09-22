import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/models/annual_withholding.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/repository/domain/local_annual_withholding_repository.dart';
import 'package:salary/core/repository/domain/local_payment_source_repository.dart';
import 'package:salary/feature/annual_withholding/annual_withholding_view_model.dart';

class MockLocalAnnualWithholdingRepository extends Mock
    implements LocalAnnualWithholdingRepository {}

class MockLocalPaymentSourceRepository extends Mock
    implements LocalPaymentSourceRepository {}

void main() {
  late MockLocalAnnualWithholdingRepository annualRepository;
  late MockLocalPaymentSourceRepository paymentSourceRepository;

  setUp(() {
    annualRepository = MockLocalAnnualWithholdingRepository();
    paymentSourceRepository = MockLocalPaymentSourceRepository();
  });

  test('同じ年の同じ支払元には重複保存できないこと', () {
    final existing = AnnualWithholding(
      'existing-id',
      2026,
      'source-1',
      1000000,
      200000,
      300000,
      100000,
      'memo',
      DateTime(2026, 1, 10),
    );

    when(() => annualRepository.fetchAll()).thenReturn([existing]);
    when(
      () => paymentSourceRepository.fetchSortedAllPaymentSources(),
    ).thenReturn(const <PaymentSource>[]);
    when(
      () => annualRepository.findByYearAndPaymentSourceId(2026, 'source-1'),
    ).thenReturn(existing);

    final viewModel = AnnualWithholdingViewModel(
      annualRepository,
      paymentSourceRepository,
    );

    final duplicate = AnnualWithholding(
      'new-id',
      2026,
      'source-1',
      1200000,
      220000,
      350000,
      110000,
      'memo2',
      DateTime(2026, 2, 1),
    );

    expect(viewModel.save(item: duplicate), isFalse);
  });

  test('指定年の支払金額合計と源泉徴収税額合計を計算できること', () {
    when(
      () => annualRepository.totalPaymentAmountForYear(2026),
    ).thenReturn(2500000);
    when(
      () => annualRepository.totalIncomeTaxAmountForYear(2026),
    ).thenReturn(300000);
    when(() => annualRepository.fetchAll()).thenReturn(const <AnnualWithholding>[]);
    when(
      () => paymentSourceRepository.fetchSortedAllPaymentSources(),
    ).thenReturn([
      PaymentSource('source-1', '株式会社A', 1, true, false),
    ]);

    final viewModel = AnnualWithholdingViewModel(
      annualRepository,
      paymentSourceRepository,
    );

    expect(viewModel.totalPaymentAmountForYear(2026), 2500000);
    expect(viewModel.totalIncomeTaxAmountForYear(2026), 300000);
  });
}
