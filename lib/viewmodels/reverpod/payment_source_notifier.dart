import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';
import 'package:salary/repository/realm_repository.dart';

final paymentSourceProvider =
    StateNotifierProvider<PaymentSourceNotifier, List<PaymentSource>>((ref) {
      final repository = RealmRepository();
      return PaymentSourceNotifier(repository);
    });

/// Riverpod
/// PaymentSourceを操作するViewModel
/// [StateNotifier]で状態管理
class PaymentSourceNotifier extends StateNotifier<List<PaymentSource>> {
  /// 初期化
  PaymentSourceNotifier(this._repository) : super([]) {
    // 初期化時に全データを取得
    fetchAll();
  }

  /// 引数でRepositoryをセット
  final RealmRepository _repository;

  /// 全取得
  void fetchAll() {
    state = _repository.fetchAll<PaymentSource>();
  }

  /// 追加
  void add(PaymentSource paymentSource) {
    _repository.add<PaymentSource>(paymentSource);
    fetchAll();
  }

  /// 更新
  void update(String id, String name, ThemaColor color) {
    _repository.updateById(id, (PaymentSource paymentSource) {
      paymentSource.name = name;
      paymentSource.themaColor = color.value;
    });
    fetchAll();
  }

  /// 削除
  void delete(PaymentSource paymentSource) {
    _repository.delete<PaymentSource>(paymentSource);
    fetchAll();
  }
}
