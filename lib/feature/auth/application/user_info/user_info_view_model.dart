
import 'package:salary/core/utils/date_time_utils.dart';



class UserInfoViewModel {

  String displayDate(DateTime date) {
    return DateTimeUtils.format(dateTime: date, pattern: 'yyyy年M月d日');
  }
}