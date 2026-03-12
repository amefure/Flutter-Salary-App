
abstract class CommonJsonKeys {
  static const ids = 'ids';
  static const data = 'data';
  static const user = 'user';
  static const profile = 'profile';
  static const salaries = 'salaries';
  static const paymentSources = 'payment_sources';
  static const accessToken = 'access_token';
  static const usersCount = 'users_count';
}

abstract class PageKeys {
  static const currentPage = 'current_page';
  static const lastPage = 'last_page';
  static const total = 'total';
}

abstract class SalaryJsonKeys {
  static const id = 'id';
  static const paymentAmount = 'payment_amount';
  static const deductionAmount = 'deduction_amount';
  static const netSalary = 'net_salary';
  static const paidAt = 'paid_at';
  static const isBonus = 'is_bonus';
  static const memo = 'memo';
  static const paymentItems = 'payment_items';
  static const deductionItems = 'deduction_items';
  static const paymentSource = 'payment_source';
  static const paymentSourceId = 'payment_source_id';
  static const publication = 'publication';
}

abstract class AmountItemJsonKeys {
  static const id = 'id';
  static const key = 'key';
  static const value = 'value';
}

abstract class PaymentSourceJsonKeys {
  static const id = 'id';
  static const name = 'name';
  // スペルミス
  static const themeColor = 'theme_color';
  static const memo = 'memo';
  static const isMain = 'is_main';
  static const userId = 'user_id';
  static const isPublicName = 'is_public_name';
  static const publicName = 'public_name';
}

abstract class AuthJsonKeys {
  static const id = 'id';
  static const name = 'name';
  static const email = 'email';
  static const password = 'password';
  static const passwordConfirmation = 'password_confirmation';
}

abstract class AuthProfileJsonKeys {
  static const region = 'region';
  static const birthday = 'birthday';
  static const ageRange = 'age_range';
  static const job = 'job';
  static const jobCategory = 'job_category';
  static const publishAgreedAt = 'publish_agreed_at';
  static const publishPolicyVersion = 'publish_policy_version';
}

abstract class ApiErrorJsonKeys {
  static const error = 'error';
  static const code = 'code';
  static const title = 'title';
  static const details = 'details';
  static const message = 'message';
}

abstract class PremiumQueryKeys {
  static const year = 'year';
  static const ageTo = 'age_to';
  static const ageFrom = 'age_from';
  static const region = 'region';
  static const job = 'job';
}