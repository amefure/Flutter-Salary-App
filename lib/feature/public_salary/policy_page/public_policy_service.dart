import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/auth/auth_state_notifier.dart';
import 'package:salary/core/providers/global_error_provider.dart';

final publicPolicyProvider = Provider.autoDispose<PublicPolicyService>((ref) {
  return PublicPolicyService(ref);
});

/// Stateは持つ必要がないのでService
/// runWithGlobalHandlingがUIから直接WidgetRefでは呼び出せずRefからしか呼び出せないため
class PublicPolicyService {
  final Ref _ref;

  PublicPolicyService(this._ref);

  Future<bool> updatePolicyProfile() async {
    return _ref.runWithGlobalHandling(() async {
      await _ref.read(authStateProvider.notifier).updatePolicyProfile();
    });
  }
}
