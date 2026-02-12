import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/api/api_exception.dart';
import 'package:salary/core/providers/global_loading_provider.dart';

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
  Future<T?> runWithGlobalHandling<T>(
      Future<T> Function() action,
      ) async {
    final loading = read(globalLoadingProvider.notifier);
    final error = read(globalErrorProvider.notifier);

    try {
      loading.show();
      return await action();

    } on ApiException catch (e) {
      error.show(_mapApiExceptionToMessage(e));

    } catch (_) {
      error.show('予期せぬエラーが発生しました');
    } finally {
      loading.hide();
    }

    return null;
  }

  String _mapApiExceptionToMessage(ApiException e) {
    switch (e.type) {
      case ApiErrorType.validation:
        return e.message ?? '入力内容に誤りがあります';

      case ApiErrorType.unauthorized:
        return '認証に失敗しました。再度ログインしてください。';

      case ApiErrorType.forbidden:
        return '権限がありません。';

      case ApiErrorType.notFound:
        return '対象のデータが見つかりません。';

      case ApiErrorType.server:
        return 'サーバーエラーが発生しました。時間をおいて再度お試しください。';

      case ApiErrorType.unknown:
        return e.message ?? 'エラーが発生しました';
    }
  }

}

