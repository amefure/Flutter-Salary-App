import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:salary/core/repository/domain/local_payment_source_repository.dart';
import 'package:salary/feature/payment_source/list/list_payment_source_view_model.dart';

import '../../helpers/dummy_data_helper.dart';

class MockLocalPaymentSourceRepository extends Mock implements LocalPaymentSourceRepository {}

void main() {
  late MockLocalPaymentSourceRepository mockRepo;
  late ListPaymentSourceViewModel viewModel;

  setUp(() {
    mockRepo = MockLocalPaymentSourceRepository();
  });

  group('ListPaymentSourceViewModel テスト', () {
    test('初期化時に fetchSortedAllPaymentSources が呼ばれ、状態が更新されること', () {
      final dummyData = [
        fakePaymentSource(id: '1', isMain: true),
        fakePaymentSource(id: '2', isMain: false),
      ];

      when(() => mockRepo.fetchSortedAllPaymentSources()).thenReturn(dummyData);

      viewModel = ListPaymentSourceViewModel(mockRepo);

      expect(viewModel.state.paymentSources.length, 2);
      expect(viewModel.state.paymentSources.first.id, '1');
      verify(() => mockRepo.fetchSortedAllPaymentSources()).called(1);
    });

    test('delete: 削除メソッドが呼ばれた後、再取得(fetchAll)が行われること', () {
      final target = fakePaymentSource(id: 'target_id');
      when(() => mockRepo.fetchSortedAllPaymentSources()).thenReturn([]);
      when(() => mockRepo.deleteById(any())).thenReturn(null);

      viewModel = ListPaymentSourceViewModel(mockRepo);

      viewModel.delete(target);

      verify(() => mockRepo.deleteById('target_id')).called(1);
      // 初期化時 + 削除後 = 合計2回
      verify(() => mockRepo.fetchSortedAllPaymentSources()).called(2);
    });

    test('updateExpanded: 指定したIDの展開フラグが反転すること', () {
      when(() => mockRepo.fetchSortedAllPaymentSources()).thenReturn([]);
      viewModel = ListPaymentSourceViewModel(mockRepo);

      const testId = 'payment_001';

      expect(viewModel.state.expandedMap[testId], isNull);

      viewModel.updateExpanded(testId, false);
      expect(viewModel.state.expandedMap[testId], isTrue);

      viewModel.updateExpanded(testId, true);
      expect(viewModel.state.expandedMap[testId], isFalse);
    });
  });
}