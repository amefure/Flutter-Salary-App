/// CSVエクスポートで共通利用する表示文言。
///
/// 現在はアプリの既存ローカライズ方式に合わせた日本語定数として管理し、
/// 将来のローカライズ追加時に置き換えやすくする。
abstract final class SalaryExportLabels {
  static const fileSubject = '給料データ';
  static const successMessage = '給料データをCSVファイルとして共有できます。';
  static const errorMessage = 'CSVファイルの共有に失敗しました。';
}
