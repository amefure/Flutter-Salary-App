import 'package:flutter_riverpod/flutter_riverpod.dart';

final globalLoadingProvider =
StateNotifierProvider<GlobalLoadingNotifier, GlobalLoadingState>(
      (ref) => GlobalLoadingNotifier(),
);

class GlobalLoadingState {
  final int loadingCount;

  const GlobalLoadingState({
    required this.loadingCount,
  });

  bool get isLoading => loadingCount > 0;

  GlobalLoadingState copyWith({
    int? loadingCount,
  }) {
    return GlobalLoadingState(
      loadingCount: loadingCount ?? this.loadingCount,
    );
  }
}

class GlobalLoadingNotifier extends StateNotifier<GlobalLoadingState> {
  GlobalLoadingNotifier()
      : super(const GlobalLoadingState(loadingCount: 0));

  void show() {
    state = state.copyWith(
      loadingCount: state.loadingCount + 1,
    );
  }

  void hide() {
    final newCount = state.loadingCount - 1;

    state = state.copyWith(
      loadingCount: newCount < 0 ? 0 : newCount,
    );
  }

  void reset() {
    state = const GlobalLoadingState(loadingCount: 0);
  }
}


extension LoadingExtension<T> on Future<T> {
  Future<T> withLoading(Ref ref) async {
    final notifier = ref.read(globalLoadingProvider.notifier);
    try {
      notifier.show();
      return await this;
    } finally {
      notifier.hide();
    }
  }
}