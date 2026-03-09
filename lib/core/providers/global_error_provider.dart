import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/api/api_exception.dart';
import 'package:salary/core/providers/global_loading_provider.dart';
import 'package:salary/core/utils/logger.dart';

final globalErrorProvider =
StateNotifierProvider<GlobalErrorNotifier, String?>(
      (ref) => GlobalErrorNotifier(),
);

class GlobalErrorNotifier extends StateNotifier<String?> {
  GlobalErrorNotifier() : super(null);

  void show(String message) {
    state = message;
  }

  void clear() {
    state = null;
  }
}


/// ローディングとエラー表示ハンドリング
extension AsyncHandlingExtension on Ref {
  Future<bool> runWithGlobalHandling(
      Future<void> Function() action,
      ) async {
    final loading = read(globalLoadingProvider.notifier);
    final error = read(globalErrorProvider.notifier);

    try {
      loading.show();
      await action();
      return true;

    } on ApiException catch (e) {
      error.show(_mapApiExceptionToMessage(e));
      return false;

    } catch (e, stackTrace) {
      logger('======= ❌ Error Other Response =======');
      logger(e);
      logger('StackTrace: $stackTrace');
      logger('======= ❌ Error Other Response =======');
      error.show('予期せぬエラーが発生しました');
      return false;

    } finally {
      loading.hide();
    }
  }


  String _mapApiExceptionToMessage(ApiException e) {
    switch (e.type) {
      case ApiErrorType.validation:
        return e.message;

      case ApiErrorType.unauthorized:
        return '認証に失敗しました。再度ログインしてください。';

      case ApiErrorType.forbidden:
        return '更新権限のないユーザーです。何度も発生するようであれば一度ログアウトして再度ログインしてください。';

      case ApiErrorType.notFound:
        return '対象のデータが見つかりません。';

      case ApiErrorType.server:
        // メッセージはサーバーが返すものに準ずる
        return e.message;
        // return 'サーバーエラーが発生しました。時間をおいて再度お試しください。';

      case ApiErrorType.unknown:
        return e.message;
    }
  }
}