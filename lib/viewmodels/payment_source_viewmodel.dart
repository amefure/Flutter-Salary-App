import 'package:flutter/material.dart';
import 'package:salary/models/thema_color.dart';
import 'package:salary/repository/realm_repository.dart';
import '../models/salary.dart';

/// PaymentSourceを操作するViewModel
/// [ChangeNotifier]で状態管理
/// main.dartにて[MultiProvider]で設定
class PaymentSourceViewModel extends ChangeNotifier {
  /// 引数でRepositoryをセット
  final RealmRepository _repository;

  /// PaymentSource リスト
  List<PaymentSource> paymentSources = [];

  /// 引数付きコンストラクタ
  PaymentSourceViewModel(this._repository) {
    // 初期化時に全データを取得
    fetchAll();
  }

  /// PaymentSourceの全データ取得
  void fetchAll() {
    paymentSources = _repository.fetchAll<PaymentSource>();
    notifyListeners();
  }

  /// 追加
  void add(PaymentSource paymentSource) {
    _repository.add<PaymentSource>(paymentSource);
    fetchAll();
  }

  /// 更新
  void update(String id, String name, ThemaColor color) {
    // 更新処理
    _repository.updateById(id, (PaymentSource paymentSource) {
      // 名称
      paymentSource.name = name;
      // カラー
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
