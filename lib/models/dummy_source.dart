
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';

class DummySource {
  static const String ALL_TITLE = 'ALL';
  static const String UNSET_TITLE = '未設定';
  /// "全て" を表すダミーの PaymentSource を作成
  static final PaymentSource allDummySource = PaymentSource(
      Uuid.v4().toString(),
      ALL_TITLE,
      ThemaColor.blue.value,
      false
  );

  /// "未設定" を表すダミーの PaymentSource を作成
  static final PaymentSource unSetDummySource = PaymentSource(
      Uuid.v4().toString(),
      UNSET_TITLE,
      ThemaColor.blue.value,
      false
  );
}