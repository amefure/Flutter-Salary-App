import 'package:salary/core/models/salary.dart';

/// 実態：[PaymentRepositoryImpl]
abstract class CloudPaymentRepository {
  /// 取得
  Future<List<PaymentSource>> fetchAllUserList();


  /// 作成
  Future<void> create({
    required String id,
    required String name,
    required int themeColor,
    required String? memo,
    required bool isMain,
  });

  /// 更新
  Future<void> update({
    required String id,
    required String name,
    required int themeColor,
    required String? memo,
    required bool isMain,
  });

  /// 削除
  Future<void> delete(String id);


}
